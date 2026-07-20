import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/di/service_locator.dart';

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
    return await (db.select(db.localTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    final uuid = data['id'] ?? const Uuid().v4();
    data['id'] = uuid;
    data['currency'] = data['currency'] ?? 'NGN';
    data['is_reconciled'] = data['is_reconciled'] ?? false;
    
    final type = data['transaction_type'].toString();
    final category = data['category'].toString();
    final amount = double.parse(data['amount'].toString());
    final description = data['description'] ?? '';
    final dateVal = DateTime.parse(data['transaction_date'].toString());

    // Local Insert first (offline-first)
    await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
      id: uuid,
      transactionType: type,
      category: category,
      amount: amount,
      currency: const Value('NGN'),
      relatedEntityType: Value(data['related_entity_type']),
      relatedEntityId: Value(data['related_entity_id']),
      description: Value(description),
      transactionDate: dateVal,
      isReconciled: Value(data['is_reconciled'] ?? false),
    ));

    // Audit log
    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'CREATE',
      moduleName: 'finance',
      entityId: uuid,
      entityName: '$type: ₦$amount ($category)',
      description: 'Recorded transaction "$description"',
      details: data,
    );

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

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    data['id'] = id;
    final type = data['transaction_type'].toString();
    final category = data['category'].toString();
    final amount = double.parse(data['amount'].toString());
    final description = data['description'] ?? '';
    final dateVal = DateTime.parse(data['transaction_date'].toString());

    await (db.update(db.localTransactions)..where((t) => t.id.equals(id))).write(
      LocalTransactionsCompanion(
        transactionType: Value(type),
        category: Value(category),
        amount: Value(amount),
        relatedEntityType: Value(data['related_entity_type']),
        relatedEntityId: Value(data['related_entity_id']),
        description: Value(description),
        transactionDate: Value(dateVal),
      ),
    );

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'finance',
      entityId: id,
      entityName: '$type: ₦$amount ($category)',
      description: 'Updated transaction "$description"',
      details: data,
    );

    try {
      await apiClient.dio.put('/finance/transactions/$id', data: data);
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/finance/transactions/$id',
        method: 'PUT',
        body: jsonEncode(data),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> deleteTransaction(String id) async {
    final existing = await (db.select(db.localTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    
    await (db.delete(db.localTransactions)..where((t) => t.id.equals(id))).go();

    if (existing != null) {
      sl<AuditRepository>().logAction(
        userName: 'Farm Manager',
        actionType: 'DELETE',
        moduleName: 'finance',
        entityId: id,
        entityName: '${existing.transactionType}: ₦${existing.amount}',
        description: 'Deleted transaction "${existing.description ?? existing.category}"',
      );
    }

    try {
      await apiClient.dio.delete('/finance/transactions/$id');
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/finance/transactions/$id',
        method: 'DELETE',
        body: '{}',
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> clearAllTransactions() async {
    await db.delete(db.localTransactions).go();
    try {
      await apiClient.dio.delete('/finance/transactions');
    } catch (_) {}
  }

  Future<void> _syncTransactions(List<dynamic> remoteData) async {
    await db.transaction(() async {
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
    try {
      final response = await apiClient.dio.get('/finance/profit/animal/$animalId');
      final result = Map<String, dynamic>.from(response.data);
      
      final txs = await (db.select(db.localTransactions)..where((t) => t.relatedEntityId.equals(animalId))).get();
      result['transactions'] = txs.map((t) => {
          'id': t.id,
          'date': t.transactionDate.toIso8601String(),
          'type': t.transactionType,
          'category': t.category,
          'amount': t.amount,
          'description': t.description,
      }).toList();
      return result;
    } catch (e) {
      // Offline fallback: calculate from local transactions
      final txs = await (db.select(db.localTransactions)
            ..where((t) => t.relatedEntityId.equals(animalId)))
          .get();
      
      double directRev = 0.0;
      double feedCost = 0.0;
      double healthCost = 0.0;
      double laborCost = 0.0;
      double overhead = 0.0;
      
      for (var t in txs) {
        final amount = t.amount;
        if (t.transactionType == 'income') {
          directRev += amount;
        } else {
          final cat = t.category.toLowerCase();
          if (cat.contains('feed')) {
            feedCost += amount;
          } else if (cat.contains('medical') || cat.contains('medicine') || cat.contains('vaccine') || cat.contains('health')) {
            healthCost += amount;
          } else if (cat.contains('labor') || cat.contains('salary') || cat.contains('staff') || cat.contains('payroll')) {
            laborCost += amount;
          } else {
            overhead += amount;
          }
        }
      }
      
      // Calculate Depreciation from Local Animal record
      final animal = await (db.select(db.localAnimals)..where((t) => t.id.equals(animalId))).getSingleOrNull();
      final acquisitionCost = animal?.acquisitionCost ?? 0.0;
      final salvageValue = animal?.salvageValue ?? 0.0;
      
      double ageYears = 0.0;
      if (animal?.dateOfBirth != null) {
        ageYears = DateTime.now().difference(animal!.dateOfBirth!).inDays / 365.25;
      }
      
      double annualDepr = 0.0;
      double cumDepr = 0.0;
      double bookVal = acquisitionCost;
      
      if (acquisitionCost > 0) {
        // Assume 5 year useful life for livestock
        annualDepr = (acquisitionCost - salvageValue) / 5.0; 
        if (annualDepr < 0) annualDepr = 0;
        
        cumDepr = annualDepr * ageYears;
        if (cumDepr > (acquisitionCost - salvageValue)) {
            cumDepr = acquisitionCost - salvageValue;
        }
        if (cumDepr < 0) cumDepr = 0;
        
        bookVal = acquisitionCost - cumDepr;
      }

      final totalCosts = feedCost + healthCost + laborCost + overhead;
      final netProfit = directRev - totalCosts;
      
      return {
        'direct_revenue': directRev,
        'feed_cost': feedCost,
        'health_cost': healthCost,
        'labor_cost': laborCost,
        'allocated_overhead': overhead,
        'total_costs': totalCosts,
        'net_profit': netProfit,
        'acquisition_cost': acquisitionCost,
        'depreciation': {
          'age_years': ageYears,
          'annual_depreciation': annualDepr,
          'current_book_value': bookVal,
          'salvage_value': salvageValue,
          'cumulative_depreciation': cumDepr,
        },
        'transactions': txs.map((t) => {
          'id': t.id,
          'date': t.transactionDate.toIso8601String(),
          'type': t.transactionType,
          'category': t.category,
          'amount': t.amount,
          'description': t.description,
        }).toList()
      };
    }
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
    try {
      await apiClient.dio.patch('/finance/transactions/$id/reconcile');
      
      await (db.update(db.localTransactions)..where((t) => t.id.equals(id))).write(
        const LocalTransactionsCompanion(isReconciled: Value(true)),
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.update(db.localTransactions)..where((t) => t.id.equals(id))).write(
          const LocalTransactionsCompanion(isReconciled: Value(true)),
        );
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/finance/transactions/$id/reconcile',
          method: 'PATCH',
          body: jsonEncode({}),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to reconcile transaction: ${e.message}');
      }
      throw Exception('Failed to reconcile transaction: $e');
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
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to reverse transaction: ${e.message}');
      }
      throw Exception('Failed to reverse transaction: $e');
    }
  }
}
