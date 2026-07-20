import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/di/service_locator.dart';

class HatcheryRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  HatcheryRepository(this.apiClient, this.db);

  Future<List<Map<String, dynamic>>> getBatches() async {
    try {
      final response = await apiClient.dio.get('/hatchery/batches');
      final list = response.data as List;
      await _updateBatchesCache(list);
    } catch (_) {}
    
    final localBatches = await db.select(db.localHatcheryBatches).get();
    return localBatches.map((b) => {
      'id': b.id,
      'egg_source': b.eggSource,
      'egg_count': b.eggCount,
      'breed': b.breed,
      'set_date': b.setDate.toIso8601String().split('T')[0],
      'expected_hatch_date': b.expectedHatchDate.toIso8601String().split('T')[0],
      'fertile_eggs': b.fertileEggs,
      'hatched_chicks': b.hatchedChicks,
      'failed_eggs': b.failedEggs,
      'initial_egg_cost': b.initialEggCost,
      'status': b.status,
      'crate_number': b.crateNumber,
      'crate_section': b.crateSection,
    }).toList();
  }

  Future<void> _updateBatchesCache(List<dynamic> batches) async {
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(
          db.localHatcheryBatches,
          batches.map((b) => LocalHatcheryBatchesCompanion.insert(
            id: b['id'],
            eggSource: b['egg_source'],
            eggCount: int.parse(b['egg_count'].toString()),
            breed: Value(b['breed']),
            setDate: DateTime.parse(b['set_date']),
            expectedHatchDate: DateTime.parse(b['expected_hatch_date']),
            fertileEggs: Value(b['fertile_eggs']),
            hatchedChicks: Value(b['hatched_chicks']),
            failedEggs: Value(b['failed_eggs']),
            initialEggCost: Value(double.parse((b['initial_egg_cost'] ?? 0.0).toString())),
            status: Value(b['status'] ?? 'incubating'),
            crateNumber: Value(b['crate_number']),
            crateSection: Value(b['crate_section']),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> createBatch(Map<String, dynamic> batchData) async {
    final uuid = const Uuid().v4();
    batchData['id'] = uuid;
    batchData['status'] = 'incubating';

    final setDt = DateTime.parse(batchData['set_date']);
    final expectedDt = batchData['expected_hatch_date'] != null
        ? DateTime.parse(batchData['expected_hatch_date'])
        : setDt.add(const Duration(days: 21));

    batchData['expected_hatch_date'] = expectedDt.toIso8601String().substring(0, 10);
    batchData['egg_count'] = int.parse(batchData['egg_count'].toString());
    batchData['initial_egg_cost'] = double.parse((batchData['initial_egg_cost'] ?? 0.0).toString());

    try {
      await apiClient.dio.post('/hatchery/batch', data: batchData);

      // Update local cache optimistically on success
      await db.into(db.localHatcheryBatches).insertOnConflictUpdate(LocalHatcheryBatchesCompanion.insert(
        id: uuid,
        eggSource: batchData['egg_source'],
        eggCount: int.parse(batchData['egg_count'].toString()),
        breed: Value(batchData['breed']),
        setDate: setDt,
        expectedHatchDate: expectedDt,
        initialEggCost: Value(double.parse((batchData['initial_egg_cost'] ?? 0.0).toString())),
        status: const Value('incubating'),
        crateNumber: Value(batchData['crate_number']),
        crateSection: Value(batchData['crate_section']),
      ));

      sl<AuditRepository>().logAction(
        userName: 'Farm Manager',
        actionType: 'CREATE',
        moduleName: 'hatchery',
        entityId: uuid,
        entityName: 'Batch (${batchData['egg_source']})',
        description: 'Created incubation batch of ${batchData['egg_count']} eggs in Crate ${batchData['crate_number'] ?? 'Unassigned'}',
        details: batchData,
      );

      final initialEggCost = double.parse((batchData['initial_egg_cost'] ?? 0.0).toString());
      if (initialEggCost > 0) {
        final txUuid = const Uuid().v4();
        await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
          id: txUuid,
          transactionType: 'expense',
          category: 'poultry_purchase',
          amount: initialEggCost,
          currency: const Value('NGN'),
          relatedEntityType: const Value('hatchery'),
          relatedEntityId: Value(uuid),
          description: Value('Incubation egg batch purchase: ${batchData['egg_count']} eggs (${batchData['egg_source']})'),
          transactionDate: setDt,
          isReconciled: const Value(false),
        ));
      }
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.localHatcheryBatches).insertOnConflictUpdate(LocalHatcheryBatchesCompanion.insert(
          id: uuid,
          eggSource: batchData['egg_source'],
          eggCount: int.parse(batchData['egg_count'].toString()),
          breed: Value(batchData['breed']),
          setDate: setDt,
          expectedHatchDate: expectedDt,
          initialEggCost: Value(double.parse((batchData['initial_egg_cost'] ?? 0.0).toString())),
          status: const Value('incubating'),
          crateNumber: Value(batchData['crate_number']),
          crateSection: Value(batchData['crate_section']),
        ));

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/hatchery/batch',
          method: 'POST',
          body: jsonEncode(batchData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to create hatchery batch: ${e.message}');
      }
      throw Exception('Failed to create hatchery batch: $e');
    }
  }

  Future<List<dynamic>> getEvents(String batchId) async {
    try {
      final cached = await (db.select(db.localHatcheryEvents)..where((t) => t.batchId.equals(batchId))).get();
      return cached.map((c) => {
        'id': c.id,
        'batch_id': c.batchId,
        'event_type': c.eventType,
        'event_date': c.eventDate.toIso8601String().split('T')[0],
        'value_json': c.valueJson != null ? jsonDecode(c.valueJson!) : null,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addEvent(String batchId, Map<String, dynamic> eventData) async {
    final uuid = const Uuid().v4();
    eventData['id'] = uuid;

    final eventType = eventData['event_type'];
    final eventDate = DateTime.parse(eventData['event_date']);
    final valMap = eventData['value_json'] as Map<String, dynamic>? ?? {};

    try {
      await apiClient.dio.post('/hatchery/batch/$batchId/event', data: eventData);

      // Apply change locally on success
      await db.into(db.localHatcheryEvents).insertOnConflictUpdate(LocalHatcheryEventsCompanion.insert(
        id: uuid,
        batchId: batchId,
        eventType: eventType,
        eventDate: eventDate,
        valueJson: Value(jsonEncode(valMap)),
      ));

      // Update batch stats locally based on event type
      final batchQuery = await (db.select(db.localHatcheryBatches)..where((t) => t.id.equals(batchId))).getSingleOrNull();
      if (batchQuery != null) {
        if (eventType == 'candling') {
          final fertile = valMap['fertile_eggs'];
          if (fertile != null) {
            await (db.update(db.localHatcheryBatches)..where((t) => t.id.equals(batchId))).write(
              LocalHatcheryBatchesCompanion(fertileEggs: Value(int.parse(fertile.toString())))
            );
          }
        } else if (eventType == 'hatch_complete') {
          final hatched = valMap['hatched_chicks'];
          if (hatched != null) {
            final hatchedInt = int.parse(hatched.toString());
            final failed = batchQuery.eggCount - hatchedInt;
            await (db.update(db.localHatcheryBatches)..where((t) => t.id.equals(batchId))).write(
              LocalHatcheryBatchesCompanion(
                hatchedChicks: Value(hatchedInt),
                failedEggs: Value(failed),
                status: const Value('completed'),
              )
            );
          }
        }
      }
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.localHatcheryEvents).insertOnConflictUpdate(LocalHatcheryEventsCompanion.insert(
          id: uuid,
          batchId: batchId,
          eventType: eventType,
          eventDate: eventDate,
          valueJson: Value(jsonEncode(valMap)),
        ));

        final batchQuery = await (db.select(db.localHatcheryBatches)..where((t) => t.id.equals(batchId))).getSingleOrNull();
        if (batchQuery != null) {
          if (eventType == 'candling') {
            final fertile = valMap['fertile_eggs'];
            if (fertile != null) {
              await (db.update(db.localHatcheryBatches)..where((t) => t.id.equals(batchId))).write(
                LocalHatcheryBatchesCompanion(fertileEggs: Value(int.parse(fertile.toString())))
              );
            }
          } else if (eventType == 'hatch_complete') {
            final hatched = valMap['hatched_chicks'];
            if (hatched != null) {
              final hatchedInt = int.parse(hatched.toString());
              final failed = batchQuery.eggCount - hatchedInt;
              await (db.update(db.localHatcheryBatches)..where((t) => t.id.equals(batchId))).write(
                LocalHatcheryBatchesCompanion(
                  hatchedChicks: Value(hatchedInt),
                  failedEggs: Value(failed),
                  status: const Value('completed'),
                )
              );
            }
          }
        }

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/hatchery/batch/$batchId/event',
          method: 'POST',
          body: jsonEncode(eventData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to add event: ${e.message}');
      }
      throw Exception('Failed to add event: $e');
    }
  }

  Future<Map<String, dynamic>> getKpis(String batchId) async {
    try {
      final response = await apiClient.dio.get('/hatchery/batch/$batchId/kpi');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Offline KPI calculations
      final b = await (db.select(db.localHatcheryBatches)..where((t) => t.id.equals(batchId))).getSingleOrNull();
      if (b == null) return {};

      final fertile = b.fertileEggs ?? 0;
      final hatched = b.hatchedChicks ?? 0;
      final failed = b.failedEggs ?? 0;

      double fertility = b.eggCount > 0 ? (fertile / b.eggCount * 100.0) : 0.0;
      double hatchability = fertile > 0 ? (hatched / fertile * 100.0) : 0.0;
      double cost = b.initialEggCost;

      return {
        'fertility_rate_percent': fertility,
        'hatchability_rate_percent': hatchability,
        'total_cost': cost,
        'cost_per_chick': hatched > 0 ? cost / hatched : 0.0,
        'hatched_chicks': hatched,
        'failed_eggs': failed,
        'status': b.status,
      };
    }
  }
}
