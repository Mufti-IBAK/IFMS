import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class FinanceRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  FinanceRepository(this.apiClient, this.db);

  Future<List<LocalTransaction>> getTransactions() async {
    try {
      final response = await apiClient.dio.get('/finance/transactions');
      final list = response.data as List;
      await _syncTransactions(list);
    } catch (_) {}
    return await db.select(db.localTransactions).get();
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    final type = data['transaction_type'].toString();
    final category = data['category'].toString();
    final amount = double.parse(data['amount'].toString());
    final description = data['description'] ?? '';
    final dateVal = DateTime.parse(data['transaction_date'].toString());

    // Local Insert
    await db.into(db.localTransactions).insert(LocalTransactionsCompanion.insert(
      id: uuid,
      transactionType: type,
      category: category,
      amount: amount,
      currency: const Value('NGN'),
      relatedEntityType: Value(data['related_entity_type']),
      relatedEntityId: Value(data['related_entity_id']),
      description: Value(description),
      transactionDate: dateVal,
      isReconciled: const Value(false),
    ));

    // Remote sync
    try {
      await apiClient.dio.post('/finance/transaction', data: data);
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/finance/transaction',
        method: 'POST',
        body: jsonEncode(data),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _syncTransactions(List<dynamic> remoteData) async {
    await db.transaction(() async {
      final syncItems = await (db.select(db.syncQueue)
            ..where((t) => t.endpoint.equals('/finance/transaction') & t.method.equals('POST')))
          .get();
      final pendingIds = syncItems.map((item) {
        try {
          final data = jsonDecode(item.body);
          return data['id'] as String?;
        } catch (_) {
          return null;
        }
      }).whereType<String>().toList();

      final serverIds = remoteData.map((item) => item['id'] as String).toList();
      final excludeIds = [...serverIds, ...pendingIds];

      if (excludeIds.isNotEmpty) {
        await (db.delete(db.localTransactions)..where((t) => t.id.isNotIn(excludeIds))).go();
      } else {
        await db.delete(db.localTransactions).go();
      }

      await db.batch((batch) {
        batch.insertAll(
          db.localTransactions,
          remoteData.map((item) => LocalTransactionsCompanion.insert(
            id: item['id'],
            transactionType: item['transaction_type'],
            category: item['category'],
            amount: item['amount'].toDouble(),
            currency: Value(item['currency'] ?? 'NGN'),
            relatedEntityType: Value(item['related_entity_type']),
            relatedEntityId: Value(item['related_entity_id']),
            description: Value(item['description']),
            transactionDate: DateTime.parse(item['transaction_date']),
            isReconciled: Value(item['is_reconciled'] ?? false),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<Map<String, dynamic>> getOverallFarmProfit() async {
    try {
      final response = await apiClient.dio.get('/finance/profit/farm');
      return Map<String, dynamic>.from(response.data);
    } catch (_) {
      final txs = await db.select(db.localTransactions).get();
      double rev = 0.0;
      double exp = 0.0;
      Map<String, double> breakdown = {};
      for (var t in txs) {
        final amt = t.amount;
        if (t.transactionType == 'income') {
          rev += amt;
        } else {
          exp += amt;
        }
        breakdown[t.category] = (breakdown[t.category] ?? 0.0) + amt;
      }
      return {
        'total_revenue': rev,
        'total_expenses': exp,
        'net_profit': rev - exp,
        'breakdown': breakdown,
      };
    }
  }

  Future<Map<String, dynamic>> getAnimalFinancialSummary(String animalId) async {
    final response = await apiClient.dio.get('/finance/profit/animal/$animalId');
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getCullingRecommendations() async {
    try {
      final response = await apiClient.dio.get('/finance/culling-analysis');
      return response.data as List;
    } catch (_) {
      return [];
    }
  }

  Future<void> reconcileTransaction(String id) async {
    await (db.update(db.localTransactions)..where((t) => t.id.equals(id))).write(
      const LocalTransactionsCompanion(isReconciled: Value(true)),
    );
    try {
      await apiClient.dio.patch('/finance/transactions/$id/reconcile');
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/finance/transactions/$id/reconcile',
        method: 'PATCH',
        body: '{}',
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> reverseTransaction(String id) async {
    try {
      final response = await apiClient.dio.post('/finance/transactions/$id/reverse');
      final newItem = response.data;
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: newItem['id'],
        transactionType: newItem['transaction_type'],
        category: newItem['category'],
        amount: newItem['amount'].toDouble(),
        currency: Value(newItem['currency'] ?? 'NGN'),
        relatedEntityType: Value(newItem['related_entity_type']),
        relatedEntityId: Value(newItem['related_entity_id']),
        description: Value(newItem['description']),
        transactionDate: DateTime.parse(newItem['transaction_date']),
        isReconciled: Value(newItem['is_reconciled'] ?? false),
      ));
    } catch (e) {
      final localOrig = await (db.select(db.localTransactions)..where((t) => t.id.equals(id))).getSingle();
      final reversedType = localOrig.transactionType == 'income' ? 'expense' : 'income';
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      await db.into(db.localTransactions).insert(LocalTransactionsCompanion.insert(
        id: newId,
        transactionType: reversedType,
        category: localOrig.category,
        amount: localOrig.amount,
        currency: const Value('NGN'),
        relatedEntityType: Value(localOrig.relatedEntityType),
        relatedEntityId: Value(localOrig.relatedEntityId),
        description: Value('REVERSAL of transaction ${localOrig.id}: ${localOrig.description ?? ""}'),
        transactionDate: DateTime.now(),
        isReconciled: const Value(false),
      ));
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/finance/transactions/$id/reverse',
        method: 'POST',
        body: '{}',
        queuedAt: DateTime.now(),
      ));
    }
  }
}
