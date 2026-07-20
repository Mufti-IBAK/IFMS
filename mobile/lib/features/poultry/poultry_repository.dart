import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';

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
      ));
    } catch (e) {
      await db.into(db.localPoultryBatches).insert(LocalPoultryBatchesCompanion.insert(
        id: uuid,
        batchNumber: batchNumber,
        houseName: houseName,
        initialCount: initialCount,
        currentCount: initialCount,
        startDate: startDate,
        status: 'active',
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
}
