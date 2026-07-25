import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';
import '../../core/audit/audit_repository.dart';

class PoultryRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  PoultryRepository(this.apiClient, this.db);

  Future<List<LocalPoultryBatche>> getBatches() async {
    try {
      final response = await apiClient.dio.get('/poultry/batches');
      final list = response.data as List;
      await _syncBatches(list);
    } catch (_) {}
    return await db.select(db.localPoultryBatches).get();
  }

  Future<void> createBatch(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final batchNumber = data['batch_number'].toString();
    final houseName = data['house_name'].toString();
    final initialCount = int.parse(data['initial_count'].toString());
    final initialChickCost = double.parse(data['initial_chick_cost'].toString());
    final breed = data['breed'] ?? 'Broiler';
    final startDate = DateTime.parse(data['start_date'].toString());

    // Remote Sync
    final remoteData = {
      'id': uuid,
      'batch_type': data['batch_type'] ?? 'broiler',
      'breed': breed.toString().length > 50 ? breed.toString().substring(0, 50) : breed,
      'start_date': data['start_date'],
      'initial_count': initialCount,
      'current_count': initialCount,
      'initial_chick_cost': initialChickCost,
      'status': 'active',
      'location_id': '$batchNumber|$houseName',
    };

    try {
      await apiClient.dio.post('/poultry/batch', data: remoteData);

      // Local Insert
      await db.into(db.localPoultryBatches).insert(LocalPoultryBatchesCompanion.insert(
        id: uuid,
        batchNumber: batchNumber,
        houseName: houseName,
        initialCount: initialCount,
        currentCount: initialCount,
        startDate: startDate,
        status: 'active',
        acquisitionCost: Value(initialChickCost),
      ));

      sl<AuditRepository>().logAction(
        userName: 'Farm Manager',
        actionType: 'CREATE',
        moduleName: 'poultry',
        entityId: uuid,
        entityName: 'Poultry Batch #$batchNumber ($houseName)',
        description: 'Created poultry batch #$batchNumber with $initialCount birds ($breed)',
        details: remoteData,
      );

      if (initialChickCost > 0) {
        final txUuid = const Uuid().v4();
        await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
          id: txUuid,
          transactionType: 'expense',
          category: 'poultry_purchase',
          amount: initialChickCost,
          currency: const Value('NGN'),
          relatedEntityType: const Value('poultry'),
          relatedEntityId: Value(uuid),
          description: Value('Initial chick purchase: $initialCount $breed chicks for Batch #$batchNumber'),
          transactionDate: startDate,
          isReconciled: const Value(false),
        ));
      }
    } catch (e) {
      await db.into(db.localPoultryBatches).insert(LocalPoultryBatchesCompanion.insert(
        id: uuid,
        batchNumber: batchNumber,
        houseName: houseName,
        initialCount: initialCount,
        currentCount: initialCount,
        startDate: startDate,
        status: 'active',
        acquisitionCost: Value(initialChickCost),
      ));

      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/poultry/batch',
        method: 'POST',
        body: jsonEncode(remoteData),
        queuedAt: DateTime.now(),
      ));
      throw Exception('Saved locally. Will sync when connection is restored.');
    }
  }

  Future<Map<String, dynamic>> getBatchKpi(String batchId) async {
    Map<String, dynamic> remoteKpi = {};
    try {
      final response = await apiClient.dio.get('/poultry/batch/$batchId/kpi');
      remoteKpi = Map<String, dynamic>.from(response.data);
    } catch (_) {}

    // Local calculation (device's real-time logs)
    final logs = await (db.select(db.localPoultryLogs)..where((t) => t.batchId.equals(batchId))).get();
    var batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
    
    int localDead = 0;
    int localBags = 0;
    double localLatestWeight = 0.04;
    for (var l in logs) {
      localDead += l.mortality;
      localBags += l.feedBags;
      if (l.averageWeight != null && l.averageWeight! > localLatestWeight) {
        localLatestWeight = l.averageWeight!;
      }
    }

    // Confirm if the live count is accurate against mortality log, correct if not
    final expectedMaxCount = (batch.initialCount - localDead).clamp(0, batch.initialCount);
    if (batch.currentCount > expectedMaxCount) {
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(
        LocalPoultryBatchesCompanion(currentCount: Value(expectedMaxCount))
      );
      batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
      try {
        await apiClient.dio.patch('/poultry/batch/$batchId', data: {
          'current_count': expectedMaxCount,
        });
      } catch (_) {}
    }
    
    // Merge remote and local logs
    final double remoteFeed = double.tryParse((remoteKpi['total_feed_consumed_kg'] ?? 0.0).toString()) ?? 0.0;
    final double mergedFeed = remoteFeed > (localBags * 25.0) ? remoteFeed : (localBags * 25.0);

    final double remoteMortPercent = double.tryParse((remoteKpi['mortality_rate_percent'] ?? 0.0).toString()) ?? 0.0;
    final double localMortPercent = batch.initialCount > 0 ? (localDead / batch.initialCount * 100) : 0.0;
    final double mergedMortPercent = remoteMortPercent > localMortPercent ? remoteMortPercent : localMortPercent;

    final double remoteAvgWeight = double.tryParse((remoteKpi['average_weight_kg'] ?? 0.0).toString()) ?? 0.0;
    final double mergedAvgWeight = remoteAvgWeight > localLatestWeight ? remoteAvgWeight : localLatestWeight;

    final double mergedLiveWeight = mergedAvgWeight * batch.currentCount;
    final double initialWeight = batch.initialCount * 0.04;
    final double weightGain = (mergedLiveWeight - initialWeight).clamp(0.0, double.infinity);
    final double mergedFcr = weightGain > 0 ? (mergedFeed / weightGain) : 0.0;

    final double remoteRevenue = double.tryParse((remoteKpi['revenue'] ?? 0.0).toString()) ?? 0.0;
    final double remoteCosts = double.tryParse((remoteKpi['total_costs'] ?? 0.0).toString()) ?? 0.0;
    final double localCosts = mergedFeed * 200.0; // estimated
    final double mergedCosts = remoteCosts > localCosts ? remoteCosts : localCosts;

    final int remoteSoldCount = int.tryParse((remoteKpi['total_sold_count'] ?? 0).toString()) ?? 0;

    return {
      'mortality_rate_percent': mergedMortPercent,
      'total_feed_consumed_kg': mergedFeed,
      'feed_conversion_ratio': mergedFcr,
      'average_weight_kg': mergedAvgWeight,
      'live_weight_kg': mergedLiveWeight,
      'total_sold_count': remoteSoldCount,
      'revenue': remoteRevenue,
      'total_costs': mergedCosts,
      'cost_per_kg_sold': remoteKpi['cost_per_kg_sold'] ?? 0.0,
      'net_profit': remoteRevenue - mergedCosts,
      'alerts': {
        'high_mortality_alert': mergedMortPercent > 5.0,
        'poor_fcr_alert': mergedFcr > 2.2,
        'disease_outbreak_risk': mergedMortPercent > 10.0,
      }
    };
  }

  Future<void> logBatchEvent(String batchId, Map<String, dynamic> eventData) async {
    // Under local db, we log to localPoultryLogs:
    final changeType = eventData['event_type'].toString(); // feed, mortality, weight_sample
    final double qty = double.parse(eventData['quantity'].toString());
    
    // Remote sync
    final remoteData = {
      'id': const Uuid().v4(),
      'event_type': changeType,
      'event_date': DateTime.now().toIso8601String().substring(0, 10),
      'quantity': qty,
      'value_json': eventData['value_json'],
    };

    String displayType = changeType;
    if (changeType == 'mortality') displayType = 'mortality';
    if (changeType == 'feed') displayType = 'feed consumption';
    if (changeType == 'weight_sample') displayType = 'average weight sample';

    try {
      await apiClient.dio.post('/poultry/batch/$batchId/event', data: remoteData);
      
      if (changeType == 'mortality') {
        final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
        final newCount = (batch.currentCount - qty.toInt()).clamp(0, batch.initialCount);
        try {
          await apiClient.dio.patch('/poultry/batch/$batchId', data: {
            'current_count': newCount,
          });
        } catch (_) {}
      }

      await _writeEventLocally(batchId, changeType, qty);
      
      sl<NotificationService>().showLocalNotification(
        'Flock Log Registered',
        'Logged $displayType of ${qty.toStringAsFixed(1)} for batch.',
      );
    } catch (e) {
      if (changeType == 'mortality') {
        final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
        final newCount = (batch.currentCount - qty.toInt()).clamp(0, batch.initialCount);
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/poultry/batch/$batchId',
          method: 'PATCH',
          body: jsonEncode({'current_count': newCount}),
          queuedAt: DateTime.now(),
        ));
      }

      await _writeEventLocally(batchId, changeType, qty);

      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/poultry/batch/$batchId/event',
        method: 'POST',
        body: jsonEncode(remoteData),
        queuedAt: DateTime.now(),
      ));

      sl<NotificationService>().showLocalNotification(
        'Flock Log Saved Offline',
        'Offline: Logged $displayType of ${qty.toStringAsFixed(1)} (queued for sync).',
      );

      throw Exception('Saved locally. Will sync when connection is restored.');
    }
  }

  Future<void> _writeEventLocally(String batchId, String changeType, double qty) async {
    if (changeType == 'mortality') {
      final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
      final newCount = (batch.currentCount - qty.toInt()).clamp(0, batch.initialCount);
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(
        LocalPoultryBatchesCompanion(currentCount: Value(newCount))
      );
      await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
        batchId: batchId,
        logDate: DateTime.now(),
        mortality: Value(qty.toInt()),
      ));
    } else if (changeType == 'feed') {
      await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
        batchId: batchId,
        logDate: DateTime.now(),
        feedBags: Value(qty.toInt()),
      ));
    } else if (changeType == 'weight_sample') {
      await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
        batchId: batchId,
        logDate: DateTime.now(),
        averageWeight: Value(qty),
      ));
    }
  }

  Future<void> addDailyLog(String batchId, Map<String, dynamic> logData) async {
    final int feedBags = int.parse((logData['feed_bags'] ?? 0).toString());
    final int mortality = int.parse((logData['mortality'] ?? 0).toString());
    final double? avgWeight = logData['average_weight'] != null ? double.parse(logData['average_weight'].toString()) : null;

    // Local insert
    await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
      batchId: batchId,
      logDate: DateTime.now(),
      feedBags: Value(feedBags),
      mortality: Value(mortality),
      averageWeight: Value(avgWeight),
    ));

    // Update current count locally
    if (mortality > 0) {
      final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
      final newCount = (batch.currentCount - mortality).clamp(0, batch.initialCount);
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(
        LocalPoultryBatchesCompanion(currentCount: Value(newCount))
      );
    }

    bool offline = false;
    if (mortality > 0) {
      try {
        await logBatchEvent(batchId, {
          'event_type': 'mortality',
          'quantity': mortality.toDouble(),
        });
      } catch (e) {
        if (e.toString().contains('Saved locally')) {
          offline = true;
        } else {
          rethrow;
        }
      }
    }
    if (feedBags > 0) {
      try {
        await logBatchEvent(batchId, {
          'event_type': 'feed',
          'quantity': feedBags * 25.0, // Standard 25kg bag
          'value_json': {'price_per_kg': 200.0},
        });
      } catch (e) {
        if (e.toString().contains('Saved locally')) {
          offline = true;
        } else {
          rethrow;
        }
      }
    }
    if (avgWeight != null && avgWeight > 0.0) {
      try {
        await logBatchEvent(batchId, {
          'event_type': 'weight_sample',
          'quantity': 1.0,
          'value_json': {'avg_weight_kg': avgWeight},
        });
      } catch (e) {
        if (e.toString().contains('Saved locally')) {
          offline = true;
        } else {
          rethrow;
        }
      }
    }
    if (offline) {
      throw Exception('Saved locally. Will sync when connection is restored.');
    }
  }

  Future<void> logBatchSale(String batchId, Map<String, dynamic> saleData) async {
    final int soldCount = int.parse(saleData['quantity'].toString());
    final double avgWeight = double.parse(saleData['avg_weight_kg'].toString());
    final double revenue = double.parse(saleData['revenue'].toString());
    final bool isClosing = saleData['is_closing'] == true;

    // Sync sale event to backend
    final remoteData = {
      'event_type': 'sale',
      'event_date': DateTime.now().toIso8601String().substring(0, 10),
      'quantity': soldCount.toDouble(),
      'value_json': {
        'avg_weight_kg': avgWeight,
        'revenue': revenue,
      }
    };

    final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
    final newCount = (batch.currentCount - soldCount).clamp(0, batch.initialCount);

    try {
      await apiClient.dio.post('/poultry/batch/$batchId/event', data: remoteData);
      if (isClosing && newCount > 0) {
         await apiClient.dio.post('/poultry/batch/$batchId/event', data: {
            'event_type': 'close',
            'event_date': DateTime.now().toIso8601String().substring(0, 10),
            'quantity': 0,
            'value_json': null
         });
      }

      // Update current_count and status on remote server
      try {
        await apiClient.dio.patch('/poultry/batch/$batchId', data: {
          'current_count': newCount,
          if (isClosing || newCount == 0) 'status': 'closed',
        });
      } catch (_) {}

      // Update local count and conditionally update status
      var companion = LocalPoultryBatchesCompanion(currentCount: Value(newCount));
      if (isClosing || newCount == 0) {
        companion = companion.copyWith(status: const Value('closed'));
      }
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(companion);

      sl<NotificationService>().showLocalNotification(
        'Flock Sale Registered',
        'Logged sale of $soldCount birds for batch.',
      );
    } catch (e) {
      // Queue current_count and status PATCH for sync
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/poultry/batch/$batchId',
        method: 'PATCH',
        body: jsonEncode({
          'current_count': newCount,
          if (isClosing || newCount == 0) 'status': 'closed',
        }),
        queuedAt: DateTime.now(),
      ));

      var companion = LocalPoultryBatchesCompanion(currentCount: Value(newCount));
      if (isClosing || newCount == 0) {
        companion = companion.copyWith(status: const Value('closed'));
      }
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(companion);

      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/poultry/batch/$batchId/event',
        method: 'POST',
        body: jsonEncode(remoteData),
        queuedAt: DateTime.now(),
      ));
      if (isClosing && newCount > 0) {
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/poultry/batch/$batchId/event',
          method: 'POST',
          body: jsonEncode({
            'event_type': 'close',
            'event_date': DateTime.now().toIso8601String().substring(0, 10),
            'quantity': 0,
            'value_json': null
          }),
          queuedAt: DateTime.now(),
        ));
      }

      sl<NotificationService>().showLocalNotification(
        'Flock Sale Saved Offline',
        'Offline: Logged sale of $soldCount birds (queued for sync).',
      );

      throw Exception('Saved locally. Will sync when connection is restored.');
    }
  }

  Future<void> _syncBatches(List<dynamic> remoteData) async {
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(
          db.localPoultryBatches,
          remoteData.map((item) {
            final startDt = item['start_date'] != null ? DateTime.tryParse(item['start_date'].toString()) : null;
            final locId = (item['location_id'] ?? '').toString();
            final parts = locId.split('|');
            final batchNum = parts.isNotEmpty ? parts[0] : 'Unknown';
            final houseNm = parts.length > 1 ? parts[1] : '';

            return LocalPoultryBatchesCompanion.insert(
              id: item['id'].toString(),
              batchNumber: batchNum.isEmpty ? 'Unknown' : batchNum,
              houseName: houseNm,
              initialCount: int.tryParse(item['initial_count']?.toString() ?? '') ?? 0,
              currentCount: int.tryParse(item['current_count']?.toString() ?? '') ?? int.tryParse(item['initial_count']?.toString() ?? '') ?? 0,
              startDate: startDt ?? DateTime.now(),
              status: (item['status'] ?? 'active').toString(),
            );
          }).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> updateBatch(String id, Map<String, dynamic> data) async {
    final batchNumber = data['batch_number'].toString();
    final houseName = data['house_name'].toString();
    final initialCount = int.parse(data['initial_count'].toString());
    final currentCount = int.parse(data['current_count'].toString());
    final initialChickCost = double.parse(data['initial_chick_cost'].toString());
    final breed = data['breed'] ?? 'Broiler';
    final startDate = DateTime.parse(data['start_date'].toString());
    final status = data['status'] ?? 'active';

    final remoteData = {
      'batch_type': data['batch_type'] ?? 'broiler',
      'breed': breed.toString().length > 50 ? breed.toString().substring(0, 50) : breed,
      'start_date': data['start_date'],
      'initial_count': initialCount,
      'current_count': currentCount,
      'initial_chick_cost': initialChickCost,
      'status': status,
      'location_id': '$batchNumber|$houseName',
    };

    try {
      await apiClient.dio.patch('/poultry/batch/$id', data: remoteData);

      // Local Update
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(id))).write(
        LocalPoultryBatchesCompanion(
          batchNumber: Value(batchNumber),
          houseName: Value(houseName),
          initialCount: Value(initialCount),
          currentCount: Value(currentCount),
          startDate: Value(startDate),
          status: Value(status),
        ),
      );
    } catch (e) {
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(id))).write(
        LocalPoultryBatchesCompanion(
          batchNumber: Value(batchNumber),
          houseName: Value(houseName),
          initialCount: Value(initialCount),
          currentCount: Value(currentCount),
          startDate: Value(startDate),
          status: Value(status),
        ),
      );

      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/poultry/batch/$id',
        method: 'PATCH',
        body: jsonEncode(remoteData),
        queuedAt: DateTime.now(),
      ));
      throw Exception('Saved locally. Will sync when connection is restored.');
    }
  }

  Future<void> deleteBatch(String id) async {
    try {
      await apiClient.dio.delete('/poultry/batch/$id');

      // Local Delete
      await (db.delete(db.localPoultryBatches)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      await (db.delete(db.localPoultryBatches)..where((t) => t.id.equals(id))).go();

      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/poultry/batch/$id',
        method: 'DELETE',
        body: '',
        queuedAt: DateTime.now(),
      ));
      throw Exception('Saved locally. Will sync when connection is restored.');
    }
  }

  Future<void> updatePoultryLog(LocalPoultryLog log, {int? feedBags, int? mortality, double? averageWeight}) async {
    // 1. If mortality changed, correct the batch currentCount
    if (mortality != null && mortality != log.mortality) {
      final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(log.batchId))).getSingle();
      final diff = mortality - log.mortality;
      final newCount = (batch.currentCount - diff).clamp(0, batch.initialCount);
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(log.batchId))).write(
        LocalPoultryBatchesCompanion(currentCount: Value(newCount))
      );
      try {
        await apiClient.dio.patch('/poultry/batch/${log.batchId}', data: {
          'current_count': newCount,
        });
      } catch (_) {}
    }

    // 2. Update the log record locally
    await (db.update(db.localPoultryLogs)..where((t) => t.id.equals(log.id))).write(
      LocalPoultryLogsCompanion(
        feedBags: Value(feedBags ?? log.feedBags),
        mortality: Value(mortality ?? log.mortality),
        averageWeight: Value(averageWeight ?? log.averageWeight),
      )
    );
  }

  Future<void> deletePoultryLog(LocalPoultryLog log) async {
    // 1. Restore batch currentCount if it was a mortality log
    if (log.mortality > 0) {
      final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(log.batchId))).getSingle();
      final newCount = (batch.currentCount + log.mortality).clamp(0, batch.initialCount);
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(log.batchId))).write(
        LocalPoultryBatchesCompanion(currentCount: Value(newCount))
      );
      try {
        await apiClient.dio.patch('/poultry/batch/${log.batchId}', data: {
          'current_count': newCount,
        });
      } catch (_) {}
    }

    // 2. Delete the log locally
    await (db.delete(db.localPoultryLogs)..where((t) => t.id.equals(log.id))).go();
  }

  Future<void> deleteMedicalRecord(String id) async {
    await (db.delete(db.localAnimalMedicalRecords)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateMedicalRecord(LocalAnimalMedicalRecord m, {double? dose, String? condition, double? cost}) async {
    await (db.update(db.localAnimalMedicalRecords)..where((t) => t.id.equals(m.id))).write(
      LocalAnimalMedicalRecordsCompanion(
        administeredDose: Value(dose ?? m.administeredDose),
        diagnosedCondition: Value(condition ?? m.diagnosedCondition),
        cost: Value(cost ?? m.cost),
      )
    );
  }

  // --- NEW FLOCK ADVANCED MANAGEMENT METHODS ---

  Future<void> logFlockTreatment(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final batchId = data['batch_id'].toString();
    final medicationId = data['medication_id']?.toString();
    final medicationName = data['medication_name'].toString();
    final quantityUsed = double.parse(data['quantity_used'].toString());
    final unit = data['unit']?.toString() ?? 'units';
    final costPerUnit = double.parse((data['cost_per_unit'] ?? 0.0).toString());
    final totalCost = double.parse((data['total_cost'] ?? (quantityUsed * costPerUnit)).toString());
    final treatmentDate = DateTime.parse(data['treatment_date'].toString());
    final notes = data['notes']?.toString();

    // 1. Insert treatment record
    await db.into(db.localPoultryTreatments).insert(LocalPoultryTreatmentsCompanion.insert(
      id: uuid,
      batchId: batchId,
      medicationId: Value(medicationId),
      medicationName: medicationName,
      quantityUsed: quantityUsed,
      unit: unit,
      costPerUnit: Value(costPerUnit),
      totalCost: Value(totalCost),
      treatmentDate: treatmentDate,
      notes: Value(notes),
    ));

    // 2. Deduct Pharmacy Stock if medicationId is present
    if (medicationId != null) {
      final med = await (db.select(db.localMedications)..where((t) => t.id.equals(medicationId))).getSingleOrNull();
      if (med != null) {
        final newStock = (med.currentStock - quantityUsed).clamp(0.0, double.infinity);
        await (db.update(db.localMedications)..where((t) => t.id.equals(medicationId))).write(
          LocalMedicationsCompanion(currentStock: Value(newStock))
        );
      }
    }

    // 3. Post Financial Ledger Expense if cost > 0
    if (totalCost > 0) {
      final txUuid = const Uuid().v4();
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: txUuid,
        transactionType: 'expense',
        category: 'poultry_expenses',
        amount: totalCost,
        currency: const Value('NGN'),
        relatedEntityType: const Value('poultry'),
        relatedEntityId: Value(batchId),
        description: Value('Flock Treatment ($medicationName): $quantityUsed $unit'),
        transactionDate: treatmentDate,
        isReconciled: const Value(false),
      ));
    }

    // 4. Audit Log
    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'CREATE',
      moduleName: 'poultry',
      entityId: uuid,
      entityName: 'Flock Medication ($medicationName)',
      description: 'Administered $quantityUsed $unit $medicationName to Flock (Cost: ₦$totalCost)',
      details: data,
    );
  }

  Future<void> logFlockFeedConsumption(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final batchId = data['batch_id'].toString();
    final feedSourceType = data['feed_source_type']?.toString() ?? 'inventory'; // 'inventory' or 'formula'
    final feedItemId = data['feed_item_id']?.toString();
    final formulaId = data['formula_id']?.toString();
    final feedName = data['feed_name'].toString();
    final quantityKg = double.parse(data['quantity_kg'].toString());
    final costPerKg = double.parse((data['cost_per_kg'] ?? 0.0).toString());
    final totalCost = double.parse((data['total_cost'] ?? (quantityKg * costPerKg)).toString());
    final logDate = DateTime.parse(data['log_date'].toString());
    final notes = data['notes']?.toString();

    // 1. Insert Feed Log
    await db.into(db.localPoultryFeedLogs).insert(LocalPoultryFeedLogsCompanion.insert(
      id: uuid,
      batchId: batchId,
      feedSourceType: feedSourceType,
      feedItemId: Value(feedItemId),
      formulaId: Value(formulaId),
      feedName: feedName,
      quantityKg: quantityKg,
      costPerKg: Value(costPerKg),
      totalCost: Value(totalCost),
      logDate: logDate,
      notes: Value(notes),
    ));

    // 2. Deduct Store Inventory or Milled Formula Stock
    if (feedSourceType == 'inventory' && feedItemId != null) {
      final feedItem = await (db.select(db.localFeedItems)..where((t) => t.id.equals(feedItemId))).getSingleOrNull();
      if (feedItem != null) {
        final newStock = (feedItem.currentStock - quantityKg).clamp(0.0, double.infinity);
        await (db.update(db.localFeedItems)..where((t) => t.id.equals(feedItemId))).write(
          LocalFeedItemsCompanion(currentStock: Value(newStock))
        );
      }
    } else if (feedSourceType == 'formula' && formulaId != null) {
      final formula = await (db.select(db.localFeedFormulas)..where((t) => t.id.equals(formulaId))).getSingleOrNull();
      if (formula != null) {
        final newStock = (formula.currentStock - quantityKg).clamp(0.0, double.infinity);
        await (db.update(db.localFeedFormulas)..where((t) => t.id.equals(formulaId))).write(
          LocalFeedFormulasCompanion(currentStock: Value(newStock))
        );
      }
    }

    // 3. Post Financial Ledger Expense if cost > 0
    if (totalCost > 0) {
      final txUuid = const Uuid().v4();
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: txUuid,
        transactionType: 'expense',
        category: 'poultry_expenses',
        amount: totalCost,
        currency: const Value('NGN'),
        relatedEntityType: const Value('poultry'),
        relatedEntityId: Value(batchId),
        description: Value('Flock Feed ($feedName): ${quantityKg.toStringAsFixed(1)} kg'),
        transactionDate: logDate,
        isReconciled: const Value(false),
      ));
    }

    // 4. Audit Log
    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'CREATE',
      moduleName: 'poultry',
      entityId: uuid,
      entityName: 'Flock Feed ($feedName)',
      description: 'Logged ${quantityKg.toStringAsFixed(1)} kg feed for Flock (Cost: ₦$totalCost)',
      details: data,
    );
  }

  Future<void> logFlockAdjustment(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final batchId = data['batch_id'].toString();
    final adjustmentType = data['adjustment_type'].toString(); // 'mortality', 'addition', 'cull'
    final headCount = int.parse(data['head_count'].toString());
    final adjustmentDate = DateTime.parse(data['adjustment_date'].toString());
    final reasonNotes = data['reason_notes']?.toString();

    // 1. Insert Adjustment Log
    await db.into(db.localPoultryAdjustments).insert(LocalPoultryAdjustmentsCompanion.insert(
      id: uuid,
      batchId: batchId,
      adjustmentType: adjustmentType,
      headCount: headCount,
      adjustmentDate: adjustmentDate,
      reasonNotes: Value(reasonNotes),
    ));

    // 2. Update Batch Current Headcount
    final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingleOrNull();
    if (batch != null) {
      int newCount = batch.currentCount;
      if (adjustmentType == 'addition') {
        newCount += headCount;
      } else {
        // mortality or cull
        newCount = (newCount - headCount).clamp(0, 999999);
      }
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(
        LocalPoultryBatchesCompanion(currentCount: Value(newCount))
      );
    }

    // 3. Audit Log
    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'poultry',
      entityId: uuid,
      entityName: 'Flock Headcount Adjustment ($adjustmentType)',
      description: 'Logged $headCount birds $adjustmentType for Flock (Reason: ${reasonNotes ?? 'N/A'})',
      details: data,
    );
  }

  Future<List<LocalPoultryTreatment>> getFlockTreatments(String batchId) async {
    return await (db.select(db.localPoultryTreatments)
      ..where((t) => t.batchId.equals(batchId))
      ..orderBy([(t) => OrderingTerm.desc(t.treatmentDate)]))
        .get();
  }

  Future<List<LocalPoultryFeedLog>> getFlockFeedLogs(String batchId) async {
    return await (db.select(db.localPoultryFeedLogs)
      ..where((t) => t.batchId.equals(batchId))
      ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
        .get();
  }

  Future<List<LocalPoultryAdjustment>> getFlockAdjustments(String batchId) async {
    return await (db.select(db.localPoultryAdjustments)
      ..where((t) => t.batchId.equals(batchId))
      ..orderBy([(t) => OrderingTerm.desc(t.adjustmentDate)]))
        .get();
  }

  Future<Map<String, double>> getFlockFinancialSummary(String batchId) async {
    final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingleOrNull();
    double acquisitionCost = batch?.acquisitionCost ?? 0.0;

    final feedLogs = await getFlockFeedLogs(batchId);
    double cumulativeFeedCost = 0.0;
    for (var f in feedLogs) {
      cumulativeFeedCost += f.totalCost;
    }

    final treatments = await getFlockTreatments(batchId);
    double cumulativeHealthCost = 0.0;
    for (var t in treatments) {
      cumulativeHealthCost += t.totalCost;
    }

    final txs = await (db.select(db.localTransactions)
      ..where((t) => t.relatedEntityId.equals(batchId)))
        .get();

    double totalRevenue = 0.0;
    for (var tx in txs) {
      if (tx.transactionType == 'income') {
        totalRevenue += tx.amount;
      } else if (acquisitionCost == 0 && tx.category == 'poultry_purchase') {
        // Fallback for pre-existing flocks: load chick purchase expense from Financial Ledger
        acquisitionCost += tx.amount;
      }
    }

    final totalExpenses = acquisitionCost + cumulativeFeedCost + cumulativeHealthCost;
    final netProfitLoss = totalRevenue - totalExpenses;

    return {
      'acquisitionCost': acquisitionCost,
      'cumulativeFeedCost': cumulativeFeedCost,
      'cumulativeHealthCost': cumulativeHealthCost,
      'totalExpenses': totalExpenses,
      'totalRevenue': totalRevenue,
      'netProfitLoss': netProfitLoss,
    };
  }

  // --- BROODING UNIT MANAGEMENT METHODS ---

  Future<List<LocalBroodingBatche>> getBroodingBatches() async {
    return await (db.select(db.localBroodingBatches)
      ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }

  Future<void> createBroodingBatch(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final batchNumber = data['batch_number'].toString();
    final penName = data['pen_name'].toString();
    final chickSource = data['chick_source']?.toString() ?? 'external_doc';
    final hatcheryBatchId = data['hatchery_batch_id']?.toString();
    final initialCount = int.parse(data['initial_count'].toString());
    final startDate = DateTime.parse(data['start_date'].toString());
    final targetGraduationDate = startDate.add(Duration(days: int.parse((data['brooding_days'] ?? 28).toString())));
    final initialChickCost = double.parse((data['initial_chick_cost'] ?? 0.0).toString());
    final breed = data['breed']?.toString();
    final notes = data['notes']?.toString();

    await db.into(db.localBroodingBatches).insert(LocalBroodingBatchesCompanion.insert(
      id: uuid,
      batchNumber: batchNumber,
      penName: penName,
      chickSource: chickSource,
      hatcheryBatchId: Value(hatcheryBatchId),
      initialCount: initialCount,
      currentCount: initialCount,
      startDate: startDate,
      targetGraduationDate: targetGraduationDate,
      status: 'brooding',
      initialChickCost: Value(initialChickCost),
      initialTemperatureCelsius: Value(double.tryParse(data['initial_temp']?.toString() ?? '33.0') ?? 33.0),
      breed: Value(breed),
      notes: Value(notes),
    ));

    if (initialChickCost > 0) {
      final txUuid = const Uuid().v4();
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: txUuid,
        transactionType: 'expense',
        category: 'poultry_purchase',
        amount: initialChickCost,
        currency: const Value('NGN'),
        relatedEntityType: const Value('brooding_batch'),
        relatedEntityId: Value(uuid),
        description: Value('Brooding Stocking Cost ($chickSource): $initialCount chicks for Brooder Pen $penName'),
        transactionDate: startDate,
        isReconciled: const Value(false),
      ));
    }

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'CREATE',
      moduleName: 'poultry_brooder',
      entityId: uuid,
      entityName: 'Brooding Pen $penName (#$batchNumber)',
      description: 'Started brooding batch #$batchNumber with $initialCount chicks ($chickSource)',
      details: data,
    );

    try {
      await sl<NotificationService>().showLocalNotification(
        'Brooding Batch Started',
        'Batch #$batchNumber started in Brooder Pen $penName ($initialCount chicks)',
        payload: '/poultry',
      );
    } catch (_) {}
  }

  Future<void> logBroodingEntry(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final broodingBatchId = data['brooding_batch_id'].toString();
    final logDate = DateTime.parse(data['log_date'].toString());
    final temp = data['temperature_celsius'] != null ? double.parse(data['temperature_celsius'].toString()) : null;
    final heatingStatus = data['heating_status']?.toString();
    final humidity = data['humidity_percent'] != null ? double.parse(data['humidity_percent'].toString()) : null;
    final feedKg = double.parse((data['starter_feed_kg'] ?? 0.0).toString());
    final feedCost = double.parse((data['feed_cost'] ?? 0.0).toString());
    final mortality = int.parse((data['mortality_count'] ?? 0).toString());
    final cull = int.parse((data['cull_count'] ?? 0).toString());
    final medGiven = data['medication_given']?.toString();
    final medCost = double.parse((data['medication_cost'] ?? 0.0).toString());
    final avgWeight = data['average_weight_grams'] != null ? double.parse(data['average_weight_grams'].toString()) : null;
    final notes = data['notes']?.toString();

    // 1. Insert Brooding Log
    await db.into(db.localBroodingLogs).insert(LocalBroodingLogsCompanion.insert(
      id: uuid,
      broodingBatchId: broodingBatchId,
      logDate: logDate,
      temperatureCelsius: Value(temp),
      heatingStatus: Value(heatingStatus),
      humidityPercent: Value(humidity),
      starterFeedKg: Value(feedKg),
      feedCost: Value(feedCost),
      mortalityCount: Value(mortality),
      cullCount: Value(cull),
      medicationGiven: Value(medGiven),
      medicationCost: Value(medCost),
      averageWeightGrams: Value(avgWeight),
      notes: Value(notes),
    ));

    // 2. Deduct Mortality & Culls from Brooder Current Count
    final totalLoss = mortality + cull;
    if (totalLoss > 0) {
      final brooder = await (db.select(db.localBroodingBatches)..where((t) => t.id.equals(broodingBatchId))).getSingleOrNull();
      if (brooder != null) {
        final newCount = (brooder.currentCount - totalLoss).clamp(0, 999999);
        await (db.update(db.localBroodingBatches)..where((t) => t.id.equals(broodingBatchId))).write(
          LocalBroodingBatchesCompanion(currentCount: Value(newCount))
        );
      }
    }

    // 3. Deduct feed item or formula from inventory
    final formulaId = data['formula_id']?.toString();
    if (formulaId != null && formulaId.isNotEmpty && feedKg > 0) {
      final formula = await (db.select(db.localFeedFormulas)..where((t) => t.id.equals(formulaId))).getSingleOrNull();
      if (formula != null) {
        final newStock = (formula.currentStock - feedKg).clamp(0.0, 999999.0);
        await (db.update(db.localFeedFormulas)..where((t) => t.id.equals(formulaId))).write(
          LocalFeedFormulasCompanion(currentStock: Value(newStock))
        );
      }
    }

    final feedItemId = data['feed_item_id']?.toString();
    if (feedItemId != null && feedItemId.isNotEmpty && feedKg > 0) {
      final item = await (db.select(db.localFeedItems)..where((t) => t.id.equals(feedItemId))).getSingleOrNull();
      if (item != null) {
        final newStock = (item.currentStock - feedKg).clamp(0.0, 999999.0);
        await (db.update(db.localFeedItems)..where((t) => t.id.equals(feedItemId))).write(
          LocalFeedItemsCompanion(currentStock: Value(newStock))
        );
        await db.into(db.localInventoryLogs).insert(LocalInventoryLogsCompanion.insert(
          id: const Uuid().v4(),
          itemId: feedItemId,
          changeType: 'consumption',
          quantityChange: -feedKg,
          balanceAfter: newStock,
          relatedEntityType: const Value('brooding_batch'),
          relatedEntityId: Value(broodingBatchId),
          notes: Value('Consumed $feedKg kg in Brooder Pen'),
          logDate: logDate,
        ));
      }
    }

    // 4. Deduct medication from pharmacy if medication_id provided
    final medicationId = data['medication_id']?.toString();
    final medDose = double.parse((data['medication_dose'] ?? 1.0).toString());
    if (medicationId != null && medicationId.isNotEmpty && medDose > 0) {
      final med = await (db.select(db.localMedications)..where((t) => t.id.equals(medicationId))).getSingleOrNull();
      if (med != null) {
        final newMedStock = (med.currentStock - medDose).clamp(0.0, 999999.0);
        await (db.update(db.localMedications)..where((t) => t.id.equals(medicationId))).write(
          LocalMedicationsCompanion(currentStock: Value(newMedStock))
        );
        await db.into(db.localMedicationLogs).insert(LocalMedicationLogsCompanion.insert(
          id: const Uuid().v4(),
          medicationId: medicationId,
          changeType: 'treatment',
          quantityChange: -medDose,
          balanceAfter: newMedStock,
          logDate: logDate,
          notes: Value('Administered $medDose ${med.unit} to Brooder Pen batch'),
        ));
      }
    }

    // 5. Financial Expense Logging if costs > 0
    final totalLogCost = feedCost + medCost;
    if (totalLogCost > 0) {
      final txUuid = const Uuid().v4();
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: txUuid,
        transactionType: 'expense',
        category: 'poultry_expenses',
        amount: totalLogCost,
        currency: const Value('NGN'),
        relatedEntityType: const Value('brooding_batch'),
        relatedEntityId: Value(broodingBatchId),
        description: Value('Brooder Expenses (Feed: ₦$feedCost, Meds: ₦$medCost)'),
        transactionDate: logDate,
        isReconciled: const Value(false),
      ));
    }

    // 6. System Tray Notification if mortality logged
    if (mortality > 0) {
      try {
        await sl<NotificationService>().showLocalNotification(
          'Chick Mortality Logged',
          '$mortality chick death(s) recorded in Brooder Pen log',
          payload: '/poultry',
        );
      } catch (_) {}
    }
  }

  Future<List<LocalBroodingLog>> getBroodingLogs(String broodingBatchId) async {
    return await (db.select(db.localBroodingLogs)
      ..where((t) => t.broodingBatchId.equals(broodingBatchId))
      ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
        .get();
  }

  Future<void> graduateBroodingBatchToMainFlock(String broodingBatchId, Map<String, dynamic> targetData) async {
    final brooder = await (db.select(db.localBroodingBatches)..where((t) => t.id.equals(broodingBatchId))).getSingleOrNull();
    if (brooder == null) return;

    final logs = await getBroodingLogs(broodingBatchId);
    double totalBrooderFeedCost = 0.0;
    double totalBrooderMedCost = 0.0;
    for (var l in logs) {
      totalBrooderFeedCost += l.feedCost;
      totalBrooderMedCost += l.medicationCost;
    }

    final accumulatedBroodingCost = brooder.initialChickCost + totalBrooderFeedCost + totalBrooderMedCost;
    final mainBatchNumber = targetData['batch_number']?.toString() ?? 'FL-${brooder.batchNumber}';
    final houseName = targetData['house_name']?.toString() ?? 'Main Poultry House';
    final batchType = targetData['batch_type']?.toString() ?? 'layer';

    // 1. Create Main Poultry Batch with exact accumulated cost
    await createBatch({
      'batch_number': mainBatchNumber,
      'house_name': houseName,
      'initial_count': brooder.currentCount,
      'initial_chick_cost': accumulatedBroodingCost,
      'breed': brooder.breed ?? 'Graduated Brooder Chicks',
      'batch_type': batchType,
      'start_date': DateTime.now().toIso8601String().substring(0, 10),
    });

    // 2. Mark Brooding Batch as graduated
    await (db.update(db.localBroodingBatches)..where((t) => t.id.equals(broodingBatchId))).write(
      const LocalBroodingBatchesCompanion(status: Value('graduated'))
    );

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'poultry_brooder',
      entityId: broodingBatchId,
      entityName: 'Brooding Pen Batch #${brooder.batchNumber}',
      description: 'Graduated brooder batch to main flock batch #$mainBatchNumber in $houseName',
      details: targetData,
    );

    try {
      await sl<NotificationService>().showLocalNotification(
        'Brooding Graduation Completed',
        'Batch #${brooder.batchNumber} (${brooder.currentCount} birds) graduated to Main Flock',
        payload: '/poultry',
      );
    } catch (_) {}
  }
}
