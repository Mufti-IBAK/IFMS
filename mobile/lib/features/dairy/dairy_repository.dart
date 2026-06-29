import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class DairyRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  DairyRepository(this.apiClient, this.db);

  Future<List<LocalMilkRecord>> getMilkRecords() async {
    try {
      final response = await apiClient.dio.get('/dairy/records');
      final list = response.data as List;
      // Sync local cache
      await _syncLocalCache(list);
      return await db.select(db.localMilkRecords).get();
    } catch (e) {
      return await db.select(db.localMilkRecords).get();
    }
  }

  Future<void> addMilkRecord(Map<String, dynamic> data) async {
    final id = data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Optimistic local update
    await db.into(db.localMilkRecords).insert(LocalMilkRecordsCompanion.insert(
      id: id,
      animalId: data['animal_id'],
      recordDate: DateTime.parse(data['record_date']),
      milkingSession: data['milking_session'],
      quantityLiters: data['quantity_liters'],
      isWithdrawn: Value(data['is_withdrawn'] ?? false),
    ));

    try {
      await apiClient.dio.post('/dairy/records', data: data);
    } catch (e) {
      // Queue for sync
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/dairy/records',
        method: 'POST',
        body: jsonEncode(data),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _syncLocalCache(List<dynamic> remoteData) async {
    await db.delete(db.localMilkRecords).go();
    for (var item in remoteData) {
      await db.into(db.localMilkRecords).insertOnConflictUpdate(LocalMilkRecordsCompanion.insert(
        id: item['id'],
        animalId: item['animal_id'],
        recordDate: DateTime.parse(item['record_date']),
        milkingSession: item['milking_session'],
        quantityLiters: item['quantity_liters'].toDouble(),
        isWithdrawn: Value(item['is_withdrawn'] ?? false),
      ));
    }
  }
}
