import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/di/service_locator.dart';

class InventoryRepository {
  final LocalDatabase db;
  final ApiClient apiClient;

  InventoryRepository(this.db, this.apiClient);

  // ──────────────────────────────────────────────
  // FEED ITEMS (feed-only, filtered by category)
  // ──────────────────────────────────────────────

  Future<List<dynamic>> getFeedItems() async {
    try {
      final response = await apiClient.dio.get('/inventory/items');
      final list = response.data as List;
      await _updateItemsCache(list);
      // Return only active feed items
      return list.where((i) => i['category'] == 'feed' && (i['is_active'] ?? true) == true).toList();
    } catch (e) {
      final cached = await (db.select(db.localFeedItems)
            ..where((t) => t.category.equals('feed') & t.isActive.equals(true)))
          .get();
      return cached.map((c) => {
        'id': c.id,
        'name': c.name,
        'category': c.category,
        'unit': c.unit,
        'current_stock': c.currentStock,
        'reorder_threshold': c.reorderThreshold,
        'cost_per_unit': c.costPerUnit,
        'weight_per_unit': c.weightPerUnit,
        'cost_per_kg': c.costPerKg,
        'supplier': c.supplier,
        'is_active': c.isActive,
      }).toList();
    }
  }

  Future<void> _updateItemsCache(List<dynamic> items) async {
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(
          db.localFeedItems,
          items.map((item) {
            final weightPer = double.tryParse((item['weight_per_unit'] ?? 1.0).toString()) ?? 1.0;
            final costPer = double.tryParse((item['cost_per_unit'] ?? 0.0).toString()) ?? 0.0;
            final costKg = double.tryParse((item['cost_per_kg'] ?? (costPer / weightPer)).toString()) ?? (costPer / weightPer);

            return LocalFeedItemsCompanion.insert(
              id: item['id'],
              name: item['name'],
              category: item['category'],
              unit: item['unit'],
              currentStock: double.parse(item['current_stock'].toString()),
              reorderThreshold: double.parse(item['reorder_threshold'].toString()),
              costPerUnit: costPer,
              weightPerUnit: Value(weightPer),
              costPerKg: Value(costKg),
              supplier: Value(item['supplier']),
              isActive: Value(item['is_active'] ?? true),
            );
          }).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> addFeedItem(Map<String, dynamic> itemData) async {
    final uuid = const Uuid().v4();
    itemData['id'] = uuid;
    itemData['category'] = 'feed'; // Always feed on this screen

    final weightPer = double.tryParse(itemData['weight_per_unit'].toString()) ?? 1.0;
    final costPer = double.tryParse(itemData['cost_per_unit'].toString()) ?? 0.0;
    final costKg = costPer / weightPer;
    
    // UI inputs stock in packs (e.g. bags), and we store it directly in units
    final stockKg = double.tryParse(itemData['current_stock'].toString()) ?? 0.0;

    final apiData = {
      'id': uuid,
      'name': itemData['name'],
      'category': 'feed',
      'unit': itemData['unit'],
      'current_stock': stockKg,
      'reorder_threshold': double.parse((itemData['reorder_threshold'] ?? 10.0).toString()),
      'cost_per_unit': costPer,
      'weight_per_unit': weightPer,
      'cost_per_kg': costKg,
      'supplier': itemData['supplier'],
      'is_active': true,
    };

    try {
      await apiClient.dio.post('/inventory/items', data: apiData);

      // On success, save locally
      await db.into(db.localFeedItems).insertOnConflictUpdate(LocalFeedItemsCompanion.insert(
        id: uuid,
        name: itemData['name'],
        category: 'feed',
        unit: itemData['unit'],
        currentStock: stockKg,
        reorderThreshold: double.parse((itemData['reorder_threshold'] ?? 10.0).toString()),
        costPerUnit: costPer,
        weightPerUnit: Value(weightPer),
        costPerKg: Value(costKg),
        supplier: Value(itemData['supplier']),
        isActive: const Value(true),
      ));

      sl<AuditRepository>().logAction(
        userName: 'Farm Manager',
        actionType: 'CREATE',
        moduleName: 'inventory',
        entityId: uuid,
        entityName: itemData['name'],
        description: 'Added new feed item "${itemData['name']}"',
        details: apiData,
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.localFeedItems).insertOnConflictUpdate(LocalFeedItemsCompanion.insert(
          id: uuid,
          name: itemData['name'],
          category: 'feed',
          unit: itemData['unit'],
          currentStock: stockKg,
          reorderThreshold: double.parse((itemData['reorder_threshold'] ?? 10.0).toString()),
          costPerUnit: costPer,
          weightPerUnit: Value(weightPer),
          costPerKg: Value(costKg),
          supplier: Value(itemData['supplier']),
          isActive: const Value(true),
        ));

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/inventory/items',
          method: 'POST',
          body: jsonEncode(apiData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to add feed item: ${e.message}');
      }
      throw Exception('Failed to add feed item: $e');
    }
  }

  Future<void> updateFeedItem(String id, Map<String, dynamic> itemData) async {
    final weightPer = double.tryParse((itemData['weight_per_unit'] ?? 1.0).toString()) ?? 1.0;
    final costPer = double.tryParse((itemData['cost_per_unit'] ?? 0.0).toString()) ?? 0.0;
    final costKg = costPer / weightPer;

    // Convert stock to units if it was updated
    double? stockKg;
    if (itemData['current_stock'] != null) {
      stockKg = double.tryParse(itemData['current_stock'].toString()) ?? 0.0;
    }

    final apiData = <String, dynamic>{};
    if (itemData.containsKey('name')) apiData['name'] = itemData['name'];
    if (itemData.containsKey('unit')) apiData['unit'] = itemData['unit'];
    if (itemData.containsKey('supplier')) apiData['supplier'] = itemData['supplier'];
    if (itemData.containsKey('current_stock')) apiData['current_stock'] = stockKg;
    if (itemData.containsKey('reorder_threshold')) {
      apiData['reorder_threshold'] = double.parse(itemData['reorder_threshold'].toString());
    }
    apiData['weight_per_unit'] = weightPer;
    apiData['cost_per_unit'] = costPer;
    apiData['cost_per_kg'] = costKg;

    // Sync with backend API first
    try {
      await apiClient.dio.patch('/inventory/items/$id', data: apiData);

      // On success, update locally
      await (db.update(db.localFeedItems)..where((t) => t.id.equals(id))).write(
        LocalFeedItemsCompanion(
          name: itemData['name'] != null ? Value(itemData['name']) : const Value.absent(),
          unit: itemData['unit'] != null ? Value(itemData['unit']) : const Value.absent(),
          weightPerUnit: Value(weightPer),
          costPerUnit: Value(costPer),
          costPerKg: Value(costKg),
          currentStock: stockKg != null ? Value(stockKg) : const Value.absent(),
          reorderThreshold: itemData['reorder_threshold'] != null 
              ? Value(double.parse(itemData['reorder_threshold'].toString())) 
              : const Value.absent(),
          supplier: itemData['supplier'] != null ? Value(itemData['supplier']) : const Value.absent(),
        ),
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.update(db.localFeedItems)..where((t) => t.id.equals(id))).write(
          LocalFeedItemsCompanion(
            name: itemData['name'] != null ? Value(itemData['name']) : const Value.absent(),
            unit: itemData['unit'] != null ? Value(itemData['unit']) : const Value.absent(),
            weightPerUnit: Value(weightPer),
            costPerUnit: Value(costPer),
            costPerKg: Value(costKg),
            currentStock: stockKg != null ? Value(stockKg) : const Value.absent(),
            reorderThreshold: itemData['reorder_threshold'] != null 
                ? Value(double.parse(itemData['reorder_threshold'].toString())) 
                : const Value.absent(),
            supplier: itemData['supplier'] != null ? Value(itemData['supplier']) : const Value.absent(),
          ),
        );

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/inventory/items/$id',
          method: 'PATCH',
          body: jsonEncode(apiData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to update feed item: ${e.message}');
      }
      throw Exception('Failed to update feed item: $e');
    }
  }

  Future<void> deleteFeedItem(String id) async {
    // Sync with backend API (archive or delete) first
    try {
      await apiClient.dio.delete('/inventory/items/$id');

      // On success, update locally
      await (db.update(db.localFeedItems)..where((t) => t.id.equals(id))).write(
        const LocalFeedItemsCompanion(isActive: Value(false)),
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.update(db.localFeedItems)..where((t) => t.id.equals(id))).write(
          const LocalFeedItemsCompanion(isActive: Value(false)),
        );

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/inventory/items/$id',
          method: 'DELETE',
          body: jsonEncode({}),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Deleted locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to delete feed item: ${e.message}');
      }
      throw Exception('Failed to delete feed item: $e');
    }
  }

  // ──────────────────────────────────────────────
  // INVENTORY LOGS (stock movements)
  // ──────────────────────────────────────────────

  Future<List<dynamic>> getInventoryLogs() async {
    try {
      final response = await apiClient.dio.get('/inventory/logs');
      final list = response.data as List;
      await _updateLogsCache(list);
      return list;
    } catch (e) {
      final cached = await (db.select(db.localInventoryLogs)
            ..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)]))
          .get();
      return cached.map((c) => {
        'id': c.id,
        'item_id': c.itemId,
        'change_type': c.changeType,
        'quantity_change': c.quantityChange,
        'balance_after': c.balanceAfter,
        'related_entity_type': c.relatedEntityType,
        'related_entity_id': c.relatedEntityId,
        'notes': c.notes,
        'log_date': c.logDate.toIso8601String(),
      }).toList();
    }
  }

  Future<void> _updateLogsCache(List<dynamic> logs) async {
    await db.transaction(() async {
      await db.delete(db.localInventoryLogs).go();
      await db.batch((batch) {
        batch.insertAll(
          db.localInventoryLogs,
          logs.map((log) => LocalInventoryLogsCompanion.insert(
            id: log['id'],
            itemId: log['item_id'],
            changeType: log['change_type'],
            quantityChange: double.parse(log['quantity_change'].toString()),
            balanceAfter: double.parse(log['balance_after'].toString()),
            relatedEntityType: Value(log['related_entity_type']),
            relatedEntityId: Value(log['related_entity_id']),
            notes: Value(log['notes']),
            logDate: DateTime.parse(log['log_date']),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> logInventoryChange(Map<String, dynamic> logData) async {
    final uuid = const Uuid().v4();
    logData['id'] = uuid;

    final itemId = logData['item_id'];
    final changeType = logData['change_type'];
    final changeVal = double.parse(logData['quantity_change'].toString());

    final itemQuery = await (db.select(db.localFeedItems)..where((t) => t.id.equals(itemId))).getSingleOrNull();
    double currentBal = itemQuery?.currentStock ?? 0.0;
    double newBal = currentBal;

    if (changeType == 'purchase' || changeType == 'return' || changeType == 'adjustment') {
      newBal += changeVal.abs();
    } else if (changeType == 'consumption' || changeType == 'waste') {
      newBal -= changeVal.abs();
    }

    final logDateStr = DateTime.now().toIso8601String();
    logData['log_date'] = logDateStr;
    
    final apiData = {
      'id': uuid,
      'item_id': itemId,
      'change_type': changeType,
      'quantity_change': changeVal,
      'balance_after': newBal,
      'related_entity_type': logData['related_entity_type'],
      'related_entity_id': logData['related_entity_id'],
      'notes': logData['notes'],
      'log_date': logDateStr,
    };

    // ── OFFLINE-FIRST: Always update local DB immediately ──
    await db.into(db.localInventoryLogs).insertOnConflictUpdate(LocalInventoryLogsCompanion.insert(
      id: uuid,
      itemId: itemId,
      changeType: changeType,
      quantityChange: changeVal,
      balanceAfter: newBal,
      relatedEntityType: Value(logData['related_entity_type']),
      relatedEntityId: Value(logData['related_entity_id']),
      notes: Value(logData['notes']),
      logDate: DateTime.now(),
    ));

    if (itemQuery != null) {
      await (db.update(db.localFeedItems)..where((t) => t.id.equals(itemId))).write(
        LocalFeedItemsCompanion(currentStock: Value(newBal))
      );
    }

    // Add informational notification task
    final String itemName = itemQuery?.name ?? 'Item';
    final String actionText = changeType == 'purchase' ? 'Restocked' 
        : changeType == 'consumption' ? 'Consumed' 
        : changeType == 'waste' ? 'Wasted' 
        : 'Adjusted';
        
    await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
      id: 'task_inv_$uuid',
      title: 'Feed Inventory $actionText',
      description: Value('$actionText $changeVal units of $itemName. New balance: $newBal.'),
      priority: 'medium',
      status: 'completed',
      dueDate: Value(DateTime.now()),
      category: const Value('feed'),
      isActionable: const Value(false),
    ));

    // Auto-log financial expense on feed purchase
    if (changeType == 'purchase' && itemQuery != null && itemQuery.costPerKg > 0) {
      final totalCost = changeVal.abs() * itemQuery.costPerKg;
      final txUuid = const Uuid().v4();
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: txUuid,
        transactionType: 'expense',
        category: 'feed_purchase',
        amount: totalCost,
        currency: const Value('NGN'),
        relatedEntityType: const Value('inventory'),
        relatedEntityId: Value(itemId),
        description: Value('Restocked $changeVal units of ${itemQuery.name}'),
        transactionDate: DateTime.now(),
        isReconciled: const Value(false),
      ));
    }

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: changeType == 'purchase' ? 'CREATE' : 'UPDATE',
      moduleName: 'inventory',
      entityId: itemId,
      entityName: itemName,
      description: '$actionText $changeVal units of $itemName (New balance: $newBal)',
      details: logData,
    );

    // ── THEN attempt remote sync (non-blocking) ──
    try {
      await apiClient.dio.post('/inventory/log', data: apiData);
    } catch (e) {
      // Queue for later sync regardless of error type
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/inventory/log',
        method: 'POST',
        body: jsonEncode(apiData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // FEED FORMULAS
  // ──────────────────────────────────────────────

  Future<List<LocalFeedFormula>> getFormulas() async {
    return await (db.select(db.localFeedFormulas)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Future<void> addFormula(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    await db.into(db.localFeedFormulas).insertOnConflictUpdate(LocalFeedFormulasCompanion.insert(
      id: uuid,
      name: data['name'],
      batchSize: double.parse(data['batch_size'].toString()),
      batchUnit: Value(data['batch_unit'] ?? 'per_tonne'),
      notes: Value(data['notes']),
    ));
  }

  Future<void> deleteFormula(String formulaId) async {
    await (db.delete(db.localFormulaIngredients)..where((t) => t.formulaId.equals(formulaId))).go();
    await (db.delete(db.localFeedFormulas)..where((t) => t.id.equals(formulaId))).go();
  }

  // ──────────────────────────────────────────────
  // FORMULA INGREDIENTS
  // ──────────────────────────────────────────────

  Future<List<LocalFormulaIngredient>> getFormulaIngredients(String formulaId) async {
    return await (db.select(db.localFormulaIngredients)
          ..where((t) => t.formulaId.equals(formulaId)))
        .get();
  }

  Future<void> addFormulaIngredient(String formulaId, Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    // Get the formula to calculate quantityKg
    final formula = await (db.select(db.localFeedFormulas)..where((t) => t.id.equals(formulaId))).getSingleOrNull();
    final batchSize = formula?.batchSize ?? 1000.0;
    final percentage = double.parse(data['percentage'].toString());
    final quantityKg = batchSize * percentage / 100.0;

    await db.into(db.localFormulaIngredients).insertOnConflictUpdate(LocalFormulaIngredientsCompanion.insert(
      id: uuid,
      formulaId: formulaId,
      feedItemId: data['feed_item_id'],
      percentage: percentage,
      quantityKg: quantityKg,
    ));
  }

  Future<void> removeFormulaIngredient(String ingredientId) async {
    await (db.delete(db.localFormulaIngredients)..where((t) => t.id.equals(ingredientId))).go();
  }

  /// Recalculates all ingredient quantities for a formula based on a new target batch size.
  Future<List<Map<String, dynamic>>> calculateFormulaCost(String formulaId, double targetBatchKg) async {
    final ingredients = await getFormulaIngredients(formulaId);
    final results = <Map<String, dynamic>>[];

    for (var ing in ingredients) {
      final item = await (db.select(db.localFeedItems)..where((t) => t.id.equals(ing.feedItemId))).getSingleOrNull();
      final qtyKg = targetBatchKg * ing.percentage / 100.0;
      final costKg = item?.costPerKg ?? 0.0;
      final lineCost = qtyKg * costKg;

      results.add({
        'ingredient_id': ing.id,
        'feed_item_id': ing.feedItemId,
        'feed_item_name': item?.name ?? 'Unknown',
        'unit': item?.unit ?? 'kg',
        'percentage': ing.percentage,
        'quantity_kg': qtyKg,
        'cost_per_unit': costKg, // This represents cost per base unit (kg/litre)
        'line_cost': lineCost,
      });
    }
    return results;
  }

  // ──────────────────────────────────────────────
  // FEED CONSUMPTION (per-animal daily tracking)
  // ──────────────────────────────────────────────

  Future<List<LocalFeedConsumptionLog>> getConsumptionLogs({DateTime? date, String? animalId}) async {
    var query = db.select(db.localFeedConsumptionLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)]);

    if (animalId != null) {
      query = query..where((t) => t.animalId.equals(animalId));
    }
    // Date filtering is done in-memory for simplicity with Drift's dateTime handling
    final all = await query.get();
    if (date != null) {
      return all.where((l) =>
        l.logDate.year == date.year &&
        l.logDate.month == date.month &&
        l.logDate.day == date.day
      ).toList();
    }
    return all;
  }

  Future<void> logConsumption(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final formulaId = data['formula_id'];
    final qtyKg = double.parse(data['quantity_kg'].toString());

    // 1. Fetch formula details
    final formula = await (db.select(db.localFeedFormulas)
          ..where((t) => t.id.equals(formulaId)))
        .getSingle();

    // Deduct from formula currentStock
    final newStock = (formula.currentStock - qtyKg).clamp(0.0, double.infinity);

    await (db.update(db.localFeedFormulas)
          ..where((t) => t.id.equals(formulaId)))
        .write(LocalFeedFormulasCompanion(
          currentStock: Value(newStock),
        ));

    // 2. Record the consumption log
    await db.into(db.localFeedConsumptionLogs).insertOnConflictUpdate(LocalFeedConsumptionLogsCompanion.insert(
      id: uuid,
      animalId: data['animal_id'],
      feedItemId: formulaId,
      quantityKg: qtyKg,
      logDate: DateTime.parse(data['log_date']),
      notes: Value(data['notes']),
    ));

    // Log the prepared feed stock deduction in inventory logs
    await db.into(db.localInventoryLogs).insertOnConflictUpdate(LocalInventoryLogsCompanion.insert(
      id: const Uuid().v4(),
      itemId: formulaId,
      changeType: 'consumption',
      quantityChange: -qtyKg,
      balanceAfter: newStock,
      notes: Value('Consumption by animal: ${qtyKg.toStringAsFixed(1)} kg'),
      logDate: DateTime.parse(data['log_date']),
    ));
  }

  // ──────────────────────────────────────────────
  // FORMULATED FEED BATCH PREPARATION
  // ──────────────────────────────────────────────

  Future<void> prepareFormulaBatch(String formulaId, double quantityKg) async {
    // 1. Fetch formula details
    final formula = await (db.select(db.localFeedFormulas)
          ..where((t) => t.id.equals(formulaId)))
        .getSingle();

    // 2. Fetch recipe ingredients
    final ingredients = await (db.select(db.localFormulaIngredients)
          ..where((t) => t.formulaId.equals(formulaId)))
        .get();

    // 3. Verify stock levels for raw ingredients before making any deduction
    for (var ingredient in ingredients) {
      final qtyIngKg = quantityKg * (ingredient.percentage / 100.0);
      final itemQuery = await (db.select(db.localFeedItems)
            ..where((t) => t.id.equals(ingredient.feedItemId)))
          .getSingle();
      if (itemQuery.currentStock < qtyIngKg) {
        throw Exception('Insufficient stock of raw ingredient "${itemQuery.name}". Current: ${itemQuery.currentStock.toStringAsFixed(1)} kg, Required: ${qtyIngKg.toStringAsFixed(1)} kg');
      }
    }

    // 4. Deduct raw stock items
    for (var ingredient in ingredients) {
      final qtyIngKg = quantityKg * (ingredient.percentage / 100.0);
      final itemQuery = await (db.select(db.localFeedItems)
            ..where((t) => t.id.equals(ingredient.feedItemId)))
          .getSingle();

      // Deduct stock
      final finalStock = (itemQuery.currentStock - qtyIngKg).clamp(0.0, double.infinity);
      await (db.update(db.localFeedItems)
            ..where((t) => t.id.equals(ingredient.feedItemId)))
          .write(LocalFeedItemsCompanion(
            currentStock: Value(finalStock),
          ));

      // Log movement
      await db.into(db.localInventoryLogs).insertOnConflictUpdate(LocalInventoryLogsCompanion.insert(
        id: const Uuid().v4(),
        itemId: ingredient.feedItemId,
        changeType: 'consumption',
        quantityChange: -qtyIngKg,
        balanceAfter: finalStock,
        notes: Value('Ingredient in preparation of "${formula.name}" batch'),
        logDate: DateTime.now(),
      ));
    }

    // 5. Update formula currentStock
    final newStock = formula.currentStock + quantityKg;
    await (db.update(db.localFeedFormulas)
          ..where((t) => t.id.equals(formulaId)))
        .write(LocalFeedFormulasCompanion(
          currentStock: Value(newStock),
        ));

    // Log the preparation in inventory logs
    await db.into(db.localInventoryLogs).insertOnConflictUpdate(LocalInventoryLogsCompanion.insert(
      id: const Uuid().v4(),
      itemId: formula.id,
      changeType: 'purchase',
      quantityChange: quantityKg,
      balanceAfter: newStock,
      notes: Value('Formulated feed batch prepared: +${quantityKg.toStringAsFixed(1)} kg'),
      logDate: DateTime.now(),
    ));
  }

  // ──────────────────────────────────────────────
  // FEEDING PLANS
  // ──────────────────────────────────────────────

  Future<List<LocalFeedingPlan>> getFeedingPlans() async {
    return await db.select(db.localFeedingPlans).get();
  }

  Future<void> saveFeedingPlan(LocalFeedingPlan plan) async {
    await db.into(db.localFeedingPlans).insertOnConflictUpdate(plan);
  }

  Future<void> deleteFeedingPlan(String id) async {
    await (db.delete(db.localFeedingPlans)..where((t) => t.id.equals(id))).go();
  }

  // ──────────────────────────────────────────────
  // ANALYTICS HELPERS
  // ──────────────────────────────────────────────

  Future<Map<String, double>> getConsumptionCostByAnimal(DateTime from, DateTime to) async {
    final logs = await (db.select(db.localFeedConsumptionLogs)
          ..orderBy([(t) => OrderingTerm(expression: t.logDate)]))
        .get();

    final filtered = logs.where((l) =>
      l.logDate.isAfter(from.subtract(const Duration(days: 1))) &&
      l.logDate.isBefore(to.add(const Duration(days: 1)))
    );

    final result = <String, double>{};
    for (var log in filtered) {
      final item = await (db.select(db.localFeedItems)..where((t) => t.id.equals(log.feedItemId))).getSingleOrNull();
      final cost = log.quantityKg * (item?.costPerUnit ?? 0.0);
      result[log.animalId] = (result[log.animalId] ?? 0.0) + cost;
    }
    return result;
  }

  Future<double> getTotalStockValue() async {
    final items = await (db.select(db.localFeedItems)..where((t) => t.category.equals('feed'))).get();
    double total = 0.0;
    for (var item in items) {
      total += item.currentStock * item.costPerUnit;
    }
    return total;
  }
}
