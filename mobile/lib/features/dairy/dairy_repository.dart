import 'dart:convert';
import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class DairyRepository {
  final LocalDatabase db;
  final ApiClient apiClient;

  DairyRepository(this.db, this.apiClient);

  Future<void> addMilkRecord(Map<String, dynamic> recordData) async {
    final id = const Uuid().v4();
    
    // Convert dynamic values safely to avoid casting errors
    double quantity = 0.0;
    if (recordData['quantity_liters'] != null) {
      quantity = double.parse(recordData['quantity_liters'].toString());
    }
    
    double? fatPercentage;
    if (recordData['fat_percentage'] != null) {
      fatPercentage = double.parse(recordData['fat_percentage'].toString());
    }

    double? proteinPercentage;
    if (recordData['protein_percentage'] != null) {
      proteinPercentage = double.parse(recordData['protein_percentage'].toString());
    }

    final now = DateTime.now();
    final activeWithdrawals = await (db.select(db.localAnimalMedicalRecords)
      ..where((r) => r.animalId.equals(recordData['animal_id']))
      ..where((r) => r.withdrawalEndDate.isBiggerOrEqualValue(now)))
        .get();
    
    final bool isWithdrawn = activeWithdrawals.isNotEmpty;

    await db.into(db.localMilkRecords).insert(
      LocalMilkRecordsCompanion.insert(
        id: id,
        animalId: recordData['animal_id'],
        recordDate: DateTime.parse(recordData['record_date']),
        milkingSession: recordData['milking_session'],
        quantityLiters: quantity,
        fatPercentage: Value(fatPercentage),
        proteinPercentage: Value(proteinPercentage),
        isWithdrawn: Value(isWithdrawn),
      ),
    );

    // Sync to backend asynchronously
    final apiData = {
      'id': id,
      ...recordData,
      'is_withdrawn': isWithdrawn,
    };
    
    try {
      await apiClient.dio.post('/dairy/milk-record', data: apiData);
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/dairy/milk-record',
        method: 'POST',
        body: jsonEncode(apiData),
        queuedAt: DateTime.now(),
      ));
      log('Offline mode: Milk record saved locally and queued for sync.');
    }
  }

  Future<List<LocalMilkRecord>> getHerdDailyTotal(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await (db.select(db.localMilkRecords)
      ..where((r) => r.recordDate.isBiggerOrEqualValue(startOfDay))
      ..where((r) => r.recordDate.isSmallerThanValue(endOfDay)))
        .get();
  }

  Future<List<LocalMilkRecord>> getRecordsByDateRange(DateTime start, DateTime end) async {
    return await (db.select(db.localMilkRecords)
      ..where((r) => r.recordDate.isBiggerOrEqualValue(start))
      ..where((r) => r.recordDate.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.asc)]))
        .get();
  }

  Future<List<LocalMilkRecord>> getCowLactationHistory(String animalId) async {
    return await (db.select(db.localMilkRecords)
      ..where((r) => r.animalId.equals(animalId))
      ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .get();
  }
}
