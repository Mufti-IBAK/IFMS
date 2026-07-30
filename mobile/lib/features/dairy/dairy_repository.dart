import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/di/service_locator.dart';

class DairyRepository {
  final LocalDatabase db;
  final ApiClient apiClient;

  static double defaultMilkPrice = 500.0;

  DairyRepository(this.db, this.apiClient) {
    getDefaultMilkPrice();
  }

  Future<void> setDefaultMilkPrice(double price) async {
    defaultMilkPrice = price;
    try {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'default_milk_price', value: price.toString());
    } catch (_) {}
  }

  Future<double> getDefaultMilkPrice() async {
    try {
      const storage = FlutterSecureStorage();
      final val = await storage.read(key: 'default_milk_price');
      if (val != null) {
        final parsed = double.tryParse(val);
        if (parsed != null && parsed > 0) {
          defaultMilkPrice = parsed;
          return parsed;
        }
      }
    } catch (_) {}
    return defaultMilkPrice;
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

      // Auto-post milk sale revenue if sale_price_per_liter or sale_amount is provided
      final pricePerLiter = double.tryParse((recordData['price_per_liter'] ?? 0).toString()) ?? 0.0;
      final saleAmount = recordData['sale_amount'] != null 
          ? double.parse(recordData['sale_amount'].toString())
          : (pricePerLiter * quantity);

      if (saleAmount > 0) {
        final txUuid = const Uuid().v4();
        await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
          id: txUuid,
          transactionType: 'income',
          category: 'milk_sales',
          amount: saleAmount,
          currency: const Value('NGN'),
          relatedEntityType: const Value('dairy'),
          relatedEntityId: Value(id),
          description: Value('Milk sale revenue: $quantity L @ ₦$pricePerLiter/L'),
          transactionDate: DateTime.now(),
          isReconciled: const Value(false),
        ));
      }
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

  Future<Map<String, dynamic>> getMilkStoreMetrics() async {
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

    final salesTxs = await (db.select(db.localTransactions)
      ..where((t) => t.category.equals('milk_sales'))
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();

    double totalRevenue = 0.0;
    double totalSoldLiters = 0.0;

    final regexLiters = RegExp(r'(\d+(?:\.\d+)?)\s*L');

    for (var tx in salesTxs) {
      totalRevenue += tx.amount;
      final match = regexLiters.firstMatch(tx.description ?? '');
      if (match != null) {
        totalSoldLiters += double.tryParse(match.group(1)!) ?? 0.0;
      } else {
        totalSoldLiters += (tx.amount > 0 ? (tx.amount / (defaultMilkPrice > 0 ? defaultMilkPrice : 500.0)) : 0.0);
      }
    }

    double inStoreLiters = totalCollectedLiters - totalSoldLiters;
    if (inStoreLiters < 0) inStoreLiters = 0.0;

    return {
      'totalCollectedLiters': totalCollectedLiters,
      'totalWithdrawnLiters': totalWithdrawnLiters,
      'totalSoldLiters': totalSoldLiters,
      'totalRevenue': totalRevenue,
      'inStoreLiters': inStoreLiters,
      'salesHistory': salesTxs,
    };
  }

  Future<void> recordBulkMilkSale({
    required double quantityLiters,
    required double pricePerLiter,
    String? buyerName,
    String? notes,
  }) async {
    final txUuid = const Uuid().v4();
    final totalAmount = quantityLiters * pricePerLiter;
    final buyer = (buyerName != null && buyerName.trim().isNotEmpty) ? buyerName.trim() : 'Bulk Buyer';

    final desc = 'Bulk Milk Sale: ${quantityLiters.toStringAsFixed(1)} L @ ₦${pricePerLiter.toStringAsFixed(0)}/L - $buyer';

    await db.into(db.localTransactions).insert(LocalTransactionsCompanion.insert(
      id: txUuid,
      transactionType: 'income',
      category: 'milk_sales',
      amount: totalAmount,
      currency: const Value('NGN'),
      relatedEntityType: const Value('manual'),
      relatedEntityId: Value(txUuid),
      description: Value(desc),
      transactionDate: DateTime.now(),
      isReconciled: const Value(true),
    ));

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'CREATE',
      moduleName: 'finance',
      entityId: txUuid,
      entityName: 'Milk Sale (${quantityLiters.toStringAsFixed(1)} L)',
      description: desc,
    );

    try {
      await apiClient.dio.post('/transactions', data: {
        'id': txUuid,
        'transaction_type': 'income',
        'category': 'milk_sales',
        'amount': totalAmount,
        'currency': 'NGN',
        'description': desc,
        'related_entity_type': 'manual',
        'related_entity_id': txUuid,
        'transaction_date': DateTime.now().toIso8601String(),
        'is_reconciled': true,
      });
    } catch (_) {}
  }

  Future<void> editMilkSaleTransaction({
    required String id,
    required double quantityLiters,
    required double pricePerLiter,
    String? buyerName,
    String? notes,
  }) async {
    final totalAmount = quantityLiters * pricePerLiter;
    final buyer = (buyerName != null && buyerName.trim().isNotEmpty) ? buyerName.trim() : 'Bulk Buyer';
    final desc = 'Bulk Milk Sale: ${quantityLiters.toStringAsFixed(1)} L @ ₦${pricePerLiter.toStringAsFixed(0)}/L - $buyer';

    await (db.update(db.localTransactions)..where((t) => t.id.equals(id))).write(
      LocalTransactionsCompanion(
        amount: Value(totalAmount),
        description: Value(desc),
        transactionDate: Value(DateTime.now()),
      ),
    );

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'finance',
      entityId: id,
      entityName: 'Milk Sale (${quantityLiters.toStringAsFixed(1)} L)',
      description: 'Updated milk sale transaction: $desc',
    );

    try {
      await apiClient.dio.patch('/transactions/$id', data: {
        'amount': totalAmount,
        'description': desc,
      });
    } catch (_) {}
  }

  Future<void> deleteMilkSaleTransaction(String id) async {
    await (db.delete(db.localTransactions)..where((t) => t.id.equals(id))).go();

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'DELETE',
      moduleName: 'finance',
      entityId: id,
      entityName: 'Milk Sale',
      description: 'Deleted bulk milk sale transaction',
    );

    try {
      await apiClient.dio.delete('/transactions/$id');
    } catch (_) {}
  }
}
