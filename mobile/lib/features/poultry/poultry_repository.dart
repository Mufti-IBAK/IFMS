import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

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

  Future<void> addDailyLog(String batchId, Map<String, dynamic> logData) async {
    // Local insert
    await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
      batchId: batchId,
      logDate: DateTime.now(),
      feedBags: Value(logData['feed_bags'] ?? 0),
      mortality: Value(logData['mortality'] ?? 0),
      averageWeight: Value(logData['average_weight']),
    ));

    try {
      await apiClient.dio.post('/poultry/batches/$batchId/logs', data: logData);
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/poultry/batches/$batchId/logs',
        method: 'POST',
        body: jsonEncode(logData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _syncBatches(List<dynamic> remoteData) async {
    await db.delete(db.localPoultryBatches).go();
    for (var item in remoteData) {
      await db.into(db.localPoultryBatches).insertOnConflictUpdate(LocalPoultryBatchesCompanion.insert(
        id: item['id'],
        batchNumber: item['batch_number'],
        houseName: item['house_name'],
        initialCount: item['initial_count'],
        currentCount: item['current_count'],
        startDate: DateTime.parse(item['start_date']),
        status: item['status'],
      ));
    }
  }
}
