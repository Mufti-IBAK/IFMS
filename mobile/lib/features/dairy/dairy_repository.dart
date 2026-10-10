import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/sync/sync_event_bus.dart';

class DairyRepository {
  final LocalDatabase db;
  final ApiClient apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _priceKey = 'milk_price_per_liter';
  static double defaultMilkPrice = 500.0;
  double _currentMilkPrice = 500.0;

  DairyRepository(this.db, this.apiClient);

  Future<double> getMilkPrice() async {
    try {
      final str = await _storage.read(key: _priceKey);
      if (str != null) {
        final val = double.tryParse(str);
        if (val != null && val > 0) {
          _currentMilkPrice = val;
          defaultMilkPrice = val;
          return val;
        }
      }
    } catch (_) {}
    return _currentMilkPrice;
  }

  Future<void> updateMilkPrice(double newPrice) async {
    if (newPrice <= 0) throw Exception('Price must be greater than 0');
    _currentMilkPrice = newPrice;
    defaultMilkPrice = newPrice;
    await _storage.write(key: _priceKey, value: newPrice.toString());

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'dairy',
      entityId: 'milk_price',
      entityName: 'Milk Price Configuration',
      description: 'Updated dynamic milk price per liter to ₦${newPrice.toStringAsFixed(0)}',
      details: {'price_per_liter': newPrice},
    );

    // Notify listeners across app
    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'milk_records', 'milk_price', 'transactions'}));
  }

  Future<void> addMilkRecord(Map<String, dynamic> recordData) async {
    final id = const Uuid().v4();
    
    // Convert dynamic values safely to avoid casting errors
    double quantity = 0.0;
    if (recordData['quantity_liters'] != null) {
      quantity = double.parse(recordData['quantity_liters'].toString());
    }

    final now = DateTime.now();
    final activeWithdrawals = await (db.select(db.localAnimalMedicalRecords)
      ..where((r) => r.animalId.equals(recordData['animal_id']))
      ..where((r) => r.withdrawalEndDate.isBiggerOrEqualValue(now)))
        .get();
    
    final bool isWithdrawn = activeWithdrawals.isNotEmpty;

    // Sync to backend synchronously
    final apiData = {
      'id': id,
      ...recordData,
      'is_withdrawn': isWithdrawn,
    };
    
    try {
      await apiClient.dio.post('/dairy/milk-record', data: apiData);
      
      // Update local cache on success
      await db.into(db.localMilkRecords).insert(
        LocalMilkRecordsCompanion.insert(
          id: id,
          animalId: recordData['animal_id'],
          recordDate: DateTime.parse(recordData['record_date']),
          milkingSession: recordData['milking_session'],
          quantityLiters: quantity,
          isWithdrawn: Value(isWithdrawn),
        ),
      );

      sl<AuditRepository>().logAction(
        userName: 'Farm Manager',
        actionType: 'CREATE',
        moduleName: 'animals',
        entityId: id,
        entityName: 'Milk Log ($quantity L)',
        description: 'Recorded $quantity L milk production (${recordData['milking_session']})',
        details: recordData,
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.localMilkRecords).insert(
          LocalMilkRecordsCompanion.insert(
            id: id,
            animalId: recordData['animal_id'],
            recordDate: DateTime.parse(recordData['record_date']),
            milkingSession: recordData['milking_session'],
            quantityLiters: quantity,
            isWithdrawn: Value(isWithdrawn),
          ),
        );
        
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/dairy/milk-record',
          method: 'POST',
          body: jsonEncode(apiData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to add milk record: ${e.message}');
      }
      throw Exception('Failed to add milk record: $e');
    }
  }

  Future<List<LocalMilkRecord>> getHerdDailyTotal(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return await (db.select(db.localMilkRecords)
      ..where((r) => r.recordDate.isBiggerOrEqualValue(start))
      ..where((r) => r.recordDate.isSmallerThanValue(end)))
        .get();
  }

  Future<List<LocalMilkRecord>> getRecordsByDateRange(DateTime start, DateTime end) async {
    return await (db.select(db.localMilkRecords)
      ..where((r) => r.recordDate.isBiggerOrEqualValue(start))
      ..where((r) => r.recordDate.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.asc)]))
        .get();
  }

  Future<void> updateMilkRecord(String id, Map<String, dynamic> recordData) async {
    double quantity = 0.0;
    if (recordData['quantity_liters'] != null) {
      quantity = double.parse(recordData['quantity_liters'].toString());
    }

    final now = DateTime.now();
    final activeWithdrawals = await (db.select(db.localAnimalMedicalRecords)
      ..where((r) => r.animalId.equals(recordData['animal_id']))
      ..where((r) => r.withdrawalEndDate.isBiggerOrEqualValue(now)))
        .get();
    
    final bool isWithdrawn = activeWithdrawals.isNotEmpty;

    final apiData = {
      ...recordData,
      'is_withdrawn': isWithdrawn,
    };

    try {
      await apiClient.dio.patch('/dairy/milk-record/$id', data: apiData);

      await (db.update(db.localMilkRecords)..where((t) => t.id.equals(id))).write(
        LocalMilkRecordsCompanion(
          animalId: Value(recordData['animal_id']),
          recordDate: Value(DateTime.parse(recordData['record_date'])),
          milkingSession: Value(recordData['milking_session']),
          quantityLiters: Value(quantity),
          isWithdrawn: Value(isWithdrawn),
        ),
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.update(db.localMilkRecords)..where((t) => t.id.equals(id))).write(
          LocalMilkRecordsCompanion(
            animalId: Value(recordData['animal_id']),
            recordDate: Value(DateTime.parse(recordData['record_date'])),
            milkingSession: Value(recordData['milking_session']),
            quantityLiters: Value(quantity),
            isWithdrawn: Value(isWithdrawn),
          ),
        );

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/dairy/milk-record/$id',
          method: 'PATCH',
          body: jsonEncode(apiData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to update milk record: ${e.message}');
      }
      throw Exception('Failed to update milk record: $e');
    }
  }

  Future<void> deleteMilkRecord(String id) async {
    try {
      await apiClient.dio.delete('/dairy/milk-record/$id');
      await (db.delete(db.localMilkRecords)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.delete(db.localMilkRecords)..where((t) => t.id.equals(id))).go();
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/dairy/milk-record/$id',
          method: 'DELETE',
          body: jsonEncode({}),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Deleted locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to delete milk record: ${e.message}');
      }
      throw Exception('Failed to delete milk record: $e');
    }
  }

  // --- RAW MILK SALES METHODS ---

  Future<void> recordBulkMilkSale({
    required double quantityLiters,
    required double pricePerLiter,
    required String buyerName,
    String? notes,
  }) async {
    final txId = const Uuid().v4();
    final totalRevenue = quantityLiters * pricePerLiter;
    final now = DateTime.now();

    final String desc = 'Bulk Milk Sale: ${quantityLiters.toStringAsFixed(1)}L @ ₦${pricePerLiter.toStringAsFixed(0)}/L - $buyerName${notes != null && notes.isNotEmpty ? ' ($notes)' : ''}';

    final txData = {
      'id': txId,
      'transaction_type': 'income',
      'category': 'milk_sales',
      'amount': totalRevenue,
      'currency': 'NGN',
      'related_entity_type': 'dairy_store',
      'description': desc,
      'transaction_date': now.toIso8601String(),
    };

    try {
      await apiClient.dio.post('/finance/transaction', data: txData);
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/finance/transaction',
          method: 'POST',
          body: jsonEncode(txData),
          queuedAt: now,
        ));
      }
    }

    await db.into(db.localTransactions).insert(
      LocalTransactionsCompanion.insert(
        id: txId,
        transactionType: 'income',
        category: 'milk_sales',
        amount: totalRevenue,
        currency: const Value('NGN'),
        relatedEntityType: const Value('dairy_store'),
        description: Value(desc),
        transactionDate: now,
      ),
    );

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'CREATE',
      moduleName: 'dairy',
      entityId: txId,
      entityName: 'Milk Sale (${quantityLiters.toStringAsFixed(1)}L)',
      description: 'Recorded sale of ${quantityLiters.toStringAsFixed(1)}L at ₦${pricePerLiter.toStringAsFixed(0)}/L to $buyerName',
      details: txData,
    );
  }

  Future<void> editMilkSaleTransaction(
    String id, {
    required double quantityLiters,
    required double pricePerLiter,
    required String buyerName,
    String? notes,
  }) async {
    final totalRevenue = quantityLiters * pricePerLiter;
    final String desc = 'Bulk Milk Sale: ${quantityLiters.toStringAsFixed(1)}L @ ₦${pricePerLiter.toStringAsFixed(0)}/L - $buyerName${notes != null && notes.isNotEmpty ? ' ($notes)' : ''}';

    final txData = {
      'amount': totalRevenue,
      'description': desc,
    };

    try {
      await apiClient.dio.patch('/finance/transaction/$id', data: txData);
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/finance/transaction/$id',
          method: 'PATCH',
          body: jsonEncode(txData),
          queuedAt: DateTime.now(),
        ));
      }
    }

    await (db.update(db.localTransactions)..where((t) => t.id.equals(id))).write(
      LocalTransactionsCompanion(
        amount: Value(totalRevenue),
        description: Value(desc),
      ),
    );
  }

  Future<void> deleteMilkSaleTransaction(String id) async {
    try {
      await apiClient.dio.delete('/finance/transaction/$id');
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/finance/transaction/$id',
          method: 'DELETE',
          body: jsonEncode({}),
          queuedAt: DateTime.now(),
        ));
      }
    }

    await (db.delete(db.localTransactions)..where((t) => t.id.equals(id))).go();
  }

  Future<Map<String, dynamic>> getMilkStoreMetrics() async {
    final milkPrice = await getMilkPrice();
    final allMilkRecords = await db.select(db.localMilkRecords).get();
    
    double totalCollectedLiters = 0.0;
    double totalWithdrawnLiters = 0.0;

    for (var r in allMilkRecords) {
      if (r.isWithdrawn) {
        totalWithdrawnLiters += r.quantityLiters;
      } else {
        totalCollectedLiters += r.quantityLiters;
      }
    }

    // Fetch all milk sales transactions
    final salesTx = await (db.select(db.localTransactions)
      ..where((t) => t.category.equals('milk_sales'))
      ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
        .get();

    double totalSoldLiters = 0.0;
    double totalRevenue = 0.0;

    final regexLiters = RegExp(r'(\d+(?:\.\d+)?)\s*L');
    for (var tx in salesTx) {
      totalRevenue += tx.amount;
      final match = regexLiters.firstMatch(tx.description ?? '');
      if (match != null) {
        totalSoldLiters += double.tryParse(match.group(1)!) ?? 0.0;
      }
    }

    double inStoreLiters = totalCollectedLiters - totalSoldLiters;
    if (inStoreLiters < 0) inStoreLiters = 0.0;

    double inStoreValue = inStoreLiters * milkPrice;

    return {
      'currentMilkPrice': milkPrice,
      'totalCollectedLiters': totalCollectedLiters,
      'totalWithdrawnLiters': totalWithdrawnLiters,
      'totalSoldLiters': totalSoldLiters,
      'totalRevenue': totalRevenue,
      'inStoreLiters': inStoreLiters,
      'inStoreValue': inStoreValue,
      'salesHistory': salesTx,
    };
  }
}
