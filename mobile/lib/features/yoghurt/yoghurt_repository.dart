import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/database/local_db.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/api_client.dart';
import '../../core/sync/sync_event_bus.dart';
import '../dairy/dairy_repository.dart';

class YoghurtRepository {
  final LocalDatabase _db;
  final ApiClient _apiClient;
  final _uuid = const Uuid();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _bottlePriceKey = 'yoghurt_price_per_bottle';
  static const String _packPriceKey = 'yoghurt_price_per_pack';

  YoghurtRepository(this._db, this._apiClient);

  Future<Map<String, double>> getYoghurtPrices() async {
    double bottlePrice = 500.0;
    double packPrice = 6000.0;

    // 1. Try to fetch latest from Supabase farm_settings
    try {
      final res = await _apiClient.dio.get('/farm_settings', queryParameters: {'key': 'in.($_bottlePriceKey,$_packPriceKey)'});
      final list = res.data as List?;
      if (list != null) {
        for (final item in list) {
          final k = item['key']?.toString();
          final v = double.tryParse(item['value']?.toString() ?? '');
          if (v != null && v > 0) {
            if (k == _bottlePriceKey) {
              bottlePrice = v;
              await _storage.write(key: _bottlePriceKey, value: v.toString());
            } else if (k == _packPriceKey) {
              packPrice = v;
              await _storage.write(key: _packPriceKey, value: v.toString());
            }
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to cached secure storage
    try {
      final bStr = await _storage.read(key: _bottlePriceKey);
      if (bStr != null && double.tryParse(bStr) != null) {
        bottlePrice = double.parse(bStr);
      }
      final pStr = await _storage.read(key: _packPriceKey);
      if (pStr != null && double.tryParse(pStr) != null) {
        packPrice = double.parse(pStr);
      }
    } catch (_) {}
    return {'pricePerBottle': bottlePrice, 'pricePerPack': packPrice};
  }

  Future<void> updateYoghurtPrices({required double pricePerBottle, required double pricePerPack}) async {
    if (pricePerBottle <= 0 || pricePerPack <= 0) {
      throw Exception('Prices must be greater than 0');
    }
    await _storage.write(key: _bottlePriceKey, value: pricePerBottle.toString());
    await _storage.write(key: _packPriceKey, value: pricePerPack.toString());

    // Push both to Supabase farm_settings
    try {
      await _apiClient.dio.post(
        '/farm_settings',
        data: {'key': _bottlePriceKey, 'value': pricePerBottle.toString()},
      );
    } catch (_) {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          endpoint: '/farm_settings',
          method: 'POST',
          body: jsonEncode({'key': _bottlePriceKey, 'value': pricePerBottle.toString()}),
          queuedAt: DateTime.now(),
        ),
      );
    }

    try {
      await _apiClient.dio.post(
        '/farm_settings',
        data: {'key': _packPriceKey, 'value': pricePerPack.toString()},
      );
    } catch (_) {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          endpoint: '/farm_settings',
          method: 'POST',
          body: jsonEncode({'key': _packPriceKey, 'value': pricePerPack.toString()}),
          queuedAt: DateTime.now(),
        ),
      );
    }

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'yoghurt',
      entityName: 'Yoghurt Selling Price Configuration',
      description: 'Updated Yoghurt Selling Prices: ₦${pricePerBottle.toStringAsFixed(0)}/Bottle, ₦${pricePerPack.toStringAsFixed(0)}/Pack',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_prices', 'farm_settings'}));
  }

  Future<List<LocalYoghurtBatche>> getAllBatches() async {
    return (_db.select(_db.localYoghurtBatches)
          ..orderBy([(t) => OrderingTerm(expression: t.productionDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<LocalYoghurtSale>> getAllSales() async {
    return (_db.select(_db.localYoghurtSales)
          ..orderBy([(t) => OrderingTerm(expression: t.saleDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<LocalYoghurtReturn>> getAllReturns() async {
    return (_db.select(_db.localYoghurtReturns)
          ..orderBy([(t) => OrderingTerm(expression: t.returnDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<LocalYoghurtExpense>> getAllExpenses() async {
    return (_db.select(_db.localYoghurtExpenses)
          ..orderBy([(t) => OrderingTerm(expression: t.expenseDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<Map<String, dynamic>> getYoghurtStoreMetrics() async {
    final batches = await getAllBatches();
    final sales = await getAllSales();
    final returns = await getAllReturns();
    final expenses = await getAllExpenses();
    final prices = await getYoghurtPrices();

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final monthStr = DateFormat('yyyy-MM').format(now);

    int totalBottlesInStore = 0;
    int todayBottlesProduced = 0;
    int monthlyBottlesProduced = 0;
    Map<String, int> batchInventoryByDate = {};

    for (var b in batches) {
      totalBottlesInStore += b.bottlesRemaining;

      final pDateStr = DateFormat('yyyy-MM-dd').format(b.productionDate);
      final pMonthStr = DateFormat('yyyy-MM').format(b.productionDate);

      if (pDateStr == todayStr) {
        todayBottlesProduced += b.bottlesProduced;
      }
      if (pMonthStr == monthStr) {
        monthlyBottlesProduced += b.bottlesProduced;
      }

      if (b.bottlesRemaining > 0) {
        final dateKey = DateFormat('dd/MM/yy').format(b.productionDate);
        batchInventoryByDate[dateKey] = (batchInventoryByDate[dateKey] ?? 0) + b.bottlesRemaining;
      }
    }

    double totalRevenue = 0.0;
    double totalPaid = 0.0;
    double totalClientReceivables = 0.0;
    double totalFarmPayables = 0.0;

    for (var s in sales) {
      totalRevenue += s.totalAmount;
      totalPaid += s.amountPaid;

      if (s.balancePayer == 'client_owes_farm') {
        totalClientReceivables += s.balanceDue;
      } else if (s.balancePayer == 'farm_owes_client') {
        totalFarmPayables += s.balanceDue;
      }
    }

    int totalReplacedBottles = 0;
    for (var r in returns) {
      totalReplacedBottles += r.replacedBottles;
    }

    double totalExpenses = 0.0;
    for (var e in expenses) {
      totalExpenses += e.amount;
    }

    return {
      'totalBottlesInStore': totalBottlesInStore,
      'totalPacksInStore': totalBottlesInStore ~/ 12,
      'todayBottlesProduced': todayBottlesProduced,
      'monthlyBottlesProduced': monthlyBottlesProduced,
      'totalRevenue': totalRevenue,
      'totalPaid': totalPaid,
      'totalClientReceivables': totalClientReceivables,
      'totalFarmPayables': totalFarmPayables,
      'totalReplacedBottles': totalReplacedBottles,
      'totalExpenses': totalExpenses,
      'pricePerBottle': prices['pricePerBottle'] ?? 500.0,
      'pricePerPack': prices['pricePerPack'] ?? 6000.0,
      'batchInventoryByDate': batchInventoryByDate,
      'salesHistory': sales,
      'batchHistory': batches,
      'returnHistory': returns,
      'expenseHistory': expenses,
    };
  }

  // 🥛 Raw Milk Transfer to Yoghurt Production
  Future<void> transferMilkToProduction({
    required double quantityLiters,
    String staffName = 'Production Lead',
    String staffRole = 'Production Lead',
  }) async {
    final dairyRepo = sl<DairyRepository>();
    final currentMilkPrice = await dairyRepo.getMilkPrice();
    final metrics = await dairyRepo.getMilkStoreMetrics();

    final availableLiters = (metrics['inStoreLiters'] as num?)?.toDouble() ?? 0.0;
    if (quantityLiters > availableLiters) {
      throw Exception('Cannot transfer ${quantityLiters.toStringAsFixed(1)} L. Only ${availableLiters.toStringAsFixed(1)} L available in Cold Store.');
    }

    final transferCost = quantityLiters * currentMilkPrice;

    // Record internal raw material transfer expense in financial ledger
    final txId = _uuid.v4();
    await _db.into(_db.localTransactions).insert(
      LocalTransactionsCompanion.insert(
        id: txId,
        transactionType: 'expense',
        category: 'yoghurt_raw_material_transfer',
        amount: transferCost,
        currency: const Value('NGN'),
        description: Value('Internal Transfer: ${quantityLiters.toStringAsFixed(1)} L Raw Milk to Yoghurt Factory (@ ₦${currentMilkPrice.toStringAsFixed(0)}/L)'),
        transactionDate: DateTime.now(),
      ),
    );

    // Record bulk milk sale / withdrawal in Dairy Repository
    await dairyRepo.recordBulkMilkSale(
      quantityLiters: quantityLiters,
      pricePerLiter: currentMilkPrice,
      buyerName: 'Yoghurt Processing Factory',
      notes: 'Internal Raw Material Transfer to Yoghurt Production (Initiated by $staffName [$staffRole])',
    );

    // Log Audit Trail
    sl<AuditRepository>().logAction(
      userName: '$staffName ($staffRole)',
      actionType: 'CREATE',
      moduleName: 'yoghurt',
      entityId: txId,
      entityName: 'Milk Transfer to Yoghurt Factory',
      description: 'Transferred ${quantityLiters.toStringAsFixed(1)} Liters of milk to Yoghurt Production (Valued at ₦${NumberFormat('#,##0').format(transferCost)})',
      details: {
        'liters_transferred': quantityLiters,
        'milk_price_per_liter': currentMilkPrice,
        'total_cost': transferCost,
        'staff_name': staffName,
        'staff_role': staffRole,
      },
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'transactions', 'milk_records'}));
  }

  // 🍶 Record Yoghurt Production Batch (Auto-fetches dynamic milk cost)
  Future<void> recordYoghurtBatch({
    required DateTime productionDate,
    required double milkInputLiters,
    required int bottlesProduced,
    required double additionalCosts,
    String producedByName = 'Production Lead',
    String producedByRole = 'Production Lead',
    String? notes,
  }) async {
    final milkCostPerLiter = await sl<DairyRepository>().getMilkPrice();
    final batchId = _uuid.v4();
    final dateStr = DateFormat('yyyyMMdd').format(productionDate);
    final count = await (_db.select(_db.localYoghurtBatches)).get();
    final batchNumber = 'YOG-$dateStr-${(count.length + 1).toString().padLeft(3, '0')}';

    final totalMilkCost = milkInputLiters * milkCostPerLiter;
    final packsProduced = bottlesProduced ~/ 12;

    await _db.into(_db.localYoghurtBatches).insert(
      LocalYoghurtBatchesCompanion.insert(
        id: batchId,
        batchNumber: batchNumber,
        productionDate: productionDate,
        milkInputLiters: milkInputLiters,
        milkCostPerLiter: milkCostPerLiter,
        totalMilkCost: totalMilkCost,
        bottlesProduced: bottlesProduced,
        packsProduced: packsProduced,
        bottlesRemaining: bottlesProduced,
        additionalCosts: Value(additionalCosts),
        producedByName: producedByName,
        producedByRole: producedByRole,
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
      ),
    );

    // Audit log
    sl<AuditRepository>().logAction(
      userName: '$producedByName ($producedByRole)',
      actionType: 'CREATE',
      moduleName: 'yoghurt',
      entityId: batchId,
      entityName: 'Yoghurt Production Batch $batchNumber',
      description: 'Produced $bottlesProduced Bottles ($packsProduced Packs) from ${milkInputLiters.toStringAsFixed(1)} L milk',
      details: {
        'batch_number': batchNumber,
        'milk_used': milkInputLiters,
        'milk_cost_per_liter': milkCostPerLiter,
        'bottles_produced': bottlesProduced,
        'packs_produced': packsProduced,
        'produced_by': producedByName,
        'producer_role': producedByRole,
      },
    );

    // Sync to Cloud Supabase
    final batchPayload = {
      'id': batchId,
      'batch_number': batchNumber,
      'production_date': productionDate.toIso8601String(),
      'milk_input_liters': milkInputLiters,
      'milk_cost_per_liter': milkCostPerLiter,
      'total_milk_cost': totalMilkCost,
      'bottles_produced': bottlesProduced,
      'packs_produced': packsProduced,
      'bottles_remaining': bottlesProduced,
      'additional_costs': additionalCosts,
      'produced_by_name': producedByName,
      'produced_by_role': producedByRole,
      'notes': notes,
    };
    try {
      await _apiClient.dio.post('/yoghurt_production_batches', data: batchPayload);
    } catch (_) {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          endpoint: '/yoghurt_production_batches',
          method: 'POST',
          body: jsonEncode(batchPayload),
          queuedAt: DateTime.now(),
        ),
      );
    }

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_batches'}));
  }

  // 💰 Record Yoghurt Sale with Specific Batch or FIFO
  Future<void> recordYoghurtSale({
    required DateTime saleDate,
    required String customerName,
    String? customerPhone,
    String? description,
    required String saleUnit, // "bottles" or "packs"
    required int quantityUnits,
    required double unitPrice,
    required double amountPaid,
    String initiatedByName = 'Sales Manager',
    String initiatedByRole = 'Yoghurt Sales & Distribution Manager',
    String? selectedBatchId,
  }) async {
    final totalBottlesNeeded = saleUnit == 'packs' ? quantityUnits * 12 : quantityUnits;
    final totalAmount = quantityUnits * unitPrice;

    final diff = totalAmount - amountPaid;
    double balanceDue = diff.abs();
    String balancePayer = 'cleared';

    if (diff > 0.01) {
      balancePayer = 'client_owes_farm';
    } else if (diff < -0.01) {
      balancePayer = 'farm_owes_client';
    } else {
      balanceDue = 0.0;
      balancePayer = 'cleared';
    }

    if (selectedBatchId != null && selectedBatchId.isNotEmpty && selectedBatchId != 'auto') {
      // Deduct from specified batch directly
      final targetBatch = await (_db.select(_db.localYoghurtBatches)
            ..where((t) => t.id.equals(selectedBatchId)))
          .getSingleOrNull();

      if (targetBatch == null) {
        throw Exception('Selected production batch was not found.');
      }

      if (targetBatch.bottlesRemaining < totalBottlesNeeded) {
        final batchDateStr = DateFormat('dd/MM/yyyy').format(targetBatch.productionDate);
        throw Exception('Selected Batch #${targetBatch.batchNumber} ($batchDateStr) only has ${targetBatch.bottlesRemaining} bottles remaining. Required: $totalBottlesNeeded bottles.');
      }

      final newRemaining = targetBatch.bottlesRemaining - totalBottlesNeeded;
      await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(targetBatch.id))).write(
        LocalYoghurtBatchesCompanion(bottlesRemaining: Value(newRemaining)),
      );
    } else {
      // Deduct using FIFO across active batches
      final activeBatches = await (_db.select(_db.localYoghurtBatches)
            ..where((t) => t.bottlesRemaining.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm(expression: t.productionDate, mode: OrderingMode.asc)]))
          .get();

      int totalAvailable = activeBatches.fold(0, (sum, b) => sum + b.bottlesRemaining);
      if (totalBottlesNeeded > totalAvailable) {
        throw Exception('Insufficient yoghurt in store! Required: $totalBottlesNeeded bottles, Available: $totalAvailable bottles.');
      }

      int remainingToDeduct = totalBottlesNeeded;
      for (var b in activeBatches) {
        if (remainingToDeduct <= 0) break;
        if (b.bottlesRemaining <= remainingToDeduct) {
          remainingToDeduct -= b.bottlesRemaining;
          await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(b.id))).write(
            const LocalYoghurtBatchesCompanion(bottlesRemaining: Value(0)),
          );
        } else {
          final newRemaining = b.bottlesRemaining - remainingToDeduct;
          remainingToDeduct = 0;
          await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(b.id))).write(
            LocalYoghurtBatchesCompanion(bottlesRemaining: Value(newRemaining)),
          );
        }
      }
    }

    final saleId = _uuid.v4();
    await _db.into(_db.localYoghurtSales).insert(
      LocalYoghurtSalesCompanion.insert(
        id: saleId,
        saleDate: saleDate,
        customerName: customerName,
        customerPhone: Value(customerPhone),
        description: Value(description ?? 'Yoghurt Sale ($quantityUnits $saleUnit)'),
        saleUnit: saleUnit,
        quantityUnits: quantityUnits,
        totalBottles: totalBottlesNeeded,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        amountPaid: amountPaid,
        balanceDue: Value(balanceDue),
        balancePayer: balancePayer,
        initiatedByName: initiatedByName,
        initiatedByRole: initiatedByRole,
        selectedBatchId: Value(selectedBatchId),
        createdAt: Value(DateTime.now()),
      ),
    );

    // Record Financial Ledger Income
    if (amountPaid > 0) {
      final txId = _uuid.v4();
      await _db.into(_db.localTransactions).insert(
        LocalTransactionsCompanion.insert(
          id: txId,
          transactionType: 'income',
          category: 'yoghurt_sales',
          amount: amountPaid,
          currency: const Value('NGN'),
          description: Value('Yoghurt Sale: $quantityUnits $saleUnit to $customerName (Total Bill: ₦${NumberFormat('#,##0').format(totalAmount)}, Paid: ₦${NumberFormat('#,##0').format(amountPaid)})'),
          transactionDate: saleDate,
        ),
      );
    }

    // Audit Log
    sl<AuditRepository>().logAction(
      userName: '$initiatedByName ($initiatedByRole)',
      actionType: 'CREATE',
      moduleName: 'yoghurt',
      entityId: saleId,
      entityName: 'Yoghurt Sale to $customerName',
      description: 'Sold $quantityUnits $saleUnit ($totalBottlesNeeded bottles) to $customerName for ₦${NumberFormat('#,##0').format(totalAmount)} (Paid: ₦${NumberFormat('#,##0').format(amountPaid)})',
      details: {
        'customer_name': customerName,
        'quantity': quantityUnits,
        'unit': saleUnit,
        'total_amount': totalAmount,
        'amount_paid': amountPaid,
        'balance_due': balanceDue,
        'balance_payer': balancePayer,
        'selected_batch_id': selectedBatchId,
        'initiated_by': initiatedByName,
        'staff_role': initiatedByRole,
      },
    );

    // Sync to Cloud Supabase
    final salePayload = {
      'id': saleId,
      'sale_date': saleDate.toIso8601String(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'description': description ?? 'Yoghurt Sale ($quantityUnits $saleUnit)',
      'sale_unit': saleUnit,
      'quantity_units': quantityUnits,
      'total_bottles': totalBottlesNeeded,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'balance_due': balanceDue,
      'balance_payer': balancePayer,
      'initiated_by_name': initiatedByName,
      'initiated_by_role': initiatedByRole,
      'selected_batch_id': (selectedBatchId != null && selectedBatchId != 'auto' && selectedBatchId.isNotEmpty) ? selectedBatchId : null,
    };
    try {
      await _apiClient.dio.post('/yoghurt_sales', data: salePayload);
    } catch (_) {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          endpoint: '/yoghurt_sales',
          method: 'POST',
          body: jsonEncode(salePayload),
          queuedAt: DateTime.now(),
        ),
      );
    }

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_sales', 'transactions'}));
  }

  // 🔄 Record Yoghurt Product Return & Replacement with Specific Batch or FIFO
  Future<void> recordYoghurtReturn({
    required DateTime returnDate,
    required String customerName,
    required String description,
    required int initialBoughtBottles,
    required int returnedBottles,
    required int replacedBottles,
    String processedByName = 'Sales Manager',
    String processedByRole = 'Yoghurt Sales & Distribution Manager',
    String? selectedBatchId,
  }) async {
    // Deduct replaced bottles from store inventory
    if (replacedBottles > 0) {
      if (selectedBatchId != null && selectedBatchId.isNotEmpty && selectedBatchId != 'auto') {
        final targetBatch = await (_db.select(_db.localYoghurtBatches)
              ..where((t) => t.id.equals(selectedBatchId)))
            .getSingleOrNull();

        if (targetBatch == null) {
          throw Exception('Selected production batch was not found.');
        }

        if (targetBatch.bottlesRemaining < replacedBottles) {
          final batchDateStr = DateFormat('dd/MM/yyyy').format(targetBatch.productionDate);
          throw Exception('Cannot replace $replacedBottles bottles. Selected Batch #${targetBatch.batchNumber} ($batchDateStr) only has ${targetBatch.bottlesRemaining} bottles remaining.');
        }

        final newRemaining = targetBatch.bottlesRemaining - replacedBottles;
        await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(targetBatch.id))).write(
          LocalYoghurtBatchesCompanion(bottlesRemaining: Value(newRemaining)),
        );
      } else {
        final activeBatches = await (_db.select(_db.localYoghurtBatches)
              ..where((t) => t.bottlesRemaining.isBiggerThanValue(0))
              ..orderBy([(t) => OrderingTerm(expression: t.productionDate, mode: OrderingMode.asc)]))
          .get();

        int totalAvailable = activeBatches.fold(0, (sum, b) => sum + b.bottlesRemaining);
        if (replacedBottles > totalAvailable) {
          throw Exception('Cannot replace $replacedBottles bottles. Only $totalAvailable bottles available in store.');
        }

        int remainingToDeduct = replacedBottles;
        for (var b in activeBatches) {
          if (remainingToDeduct <= 0) break;
          if (b.bottlesRemaining <= remainingToDeduct) {
            remainingToDeduct -= b.bottlesRemaining;
            await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(b.id))).write(
              const LocalYoghurtBatchesCompanion(bottlesRemaining: Value(0)),
            );
          } else {
            final newRemaining = b.bottlesRemaining - remainingToDeduct;
            remainingToDeduct = 0;
            await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(b.id))).write(
              LocalYoghurtBatchesCompanion(bottlesRemaining: Value(newRemaining)),
            );
          }
        }
      }
    }

    final returnId = _uuid.v4();
    await _db.into(_db.localYoghurtReturns).insert(
      LocalYoghurtReturnsCompanion.insert(
        id: returnId,
        returnDate: returnDate,
        customerName: customerName,
        description: Value(description),
        initialBoughtBottles: initialBoughtBottles,
        returnedBottles: returnedBottles,
        replacedBottles: replacedBottles,
        processedByName: processedByName,
        processedByRole: processedByRole,
        selectedBatchId: Value(selectedBatchId),
        createdAt: Value(DateTime.now()),
      ),
    );

    // Audit log
    sl<AuditRepository>().logAction(
      userName: '$processedByName ($processedByRole)',
      actionType: 'CREATE',
      moduleName: 'yoghurt',
      entityId: returnId,
      entityName: 'Product Return from $customerName',
      description: 'Processed return of $returnedBottles bottles from $customerName ($replacedBottles replaced)',
      details: {
        'customer_name': customerName,
        'returned_bottles': returnedBottles,
        'replaced_bottles': replacedBottles,
        'selected_batch_id': selectedBatchId,
        'processed_by': processedByName,
        'staff_role': processedByRole,
      },
    );

    // Sync to Cloud Supabase
    final retPayload = {
      'id': returnId,
      'return_date': returnDate.toIso8601String(),
      'customer_name': customerName,
      'description': description,
      'initial_bought_bottles': initialBoughtBottles,
      'returned_bottles': returnedBottles,
      'replaced_bottles': replacedBottles,
      'processed_by_name': processedByName,
      'processed_by_role': processedByRole,
      'selected_batch_id': (selectedBatchId != null && selectedBatchId != 'auto' && selectedBatchId.isNotEmpty) ? selectedBatchId : null,
    };
    try {
      await _apiClient.dio.post('/yoghurt_returns', data: retPayload);
    } catch (_) {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          endpoint: '/yoghurt_returns',
          method: 'POST',
          body: jsonEncode(retPayload),
          queuedAt: DateTime.now(),
        ),
      );
    }

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_returns'}));
  }

  // 💸 Record Yoghurt Operational Expense
  Future<void> recordYoghurtExpense({
    required DateTime expenseDate,
    required String description,
    required String category,
    required double amount,
    String processedByName = 'Production Lead',
    String processedByRole = 'Production Lead',
  }) async {
    final expenseId = _uuid.v4();

    await _db.into(_db.localYoghurtExpenses).insert(
      LocalYoghurtExpensesCompanion.insert(
        id: expenseId,
        expenseDate: expenseDate,
        description: description,
        category: Value(category),
        amount: amount,
        processedByName: processedByName,
        processedByRole: processedByRole,
        createdAt: Value(DateTime.now()),
      ),
    );

    // Post to Financial Ledger
    final txId = _uuid.v4();
    await _db.into(_db.localTransactions).insert(
      LocalTransactionsCompanion.insert(
        id: txId,
        transactionType: 'expense',
        category: 'yoghurt_expense',
        amount: amount,
        currency: const Value('NGN'),
        description: Value('Yoghurt Expense: $description ($category)'),
        transactionDate: expenseDate,
      ),
    );

    // Audit Log
    sl<AuditRepository>().logAction(
      userName: '$processedByName ($processedByRole)',
      actionType: 'CREATE',
      moduleName: 'yoghurt',
      entityId: expenseId,
      entityName: 'Yoghurt Expense',
      description: 'Recorded yoghurt operational expense of ₦${NumberFormat('#,##0').format(amount)} ($description)',
      details: {
        'description': description,
        'category': category,
        'amount': amount,
        'processed_by': processedByName,
        'staff_role': processedByRole,
      },
    );

    // Sync to Cloud Supabase
    final expPayload = {
      'id': expenseId,
      'expense_date': expenseDate.toIso8601String(),
      'description': description,
      'category': category,
      'amount': amount,
      'processed_by_name': processedByName,
      'processed_by_role': processedByRole,
    };
    try {
      await _apiClient.dio.post('/yoghurt_expenses', data: expPayload);
    } catch (_) {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          endpoint: '/yoghurt_expenses',
          method: 'POST',
          body: jsonEncode(expPayload),
          queuedAt: DateTime.now(),
        ),
      );
    }

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_expenses', 'transactions'}));
  }

  // ── UPDATE & DELETE BATCHES ──────────────────────────────────────────────
  Future<void> updateYoghurtBatch({
    required String id,
    required DateTime productionDate,
    required double milkInputLiters,
    required int bottlesProduced,
    required double additionalCosts,
    String? notes,
  }) async {
    final existing = await (_db.select(_db.localYoghurtBatches)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) throw Exception('Batch record not found.');

    final milkCostPerLiter = await sl<DairyRepository>().getMilkPrice();
    final totalMilkCost = milkInputLiters * milkCostPerLiter;
    final packsProduced = bottlesProduced ~/ 12;

    // Adjust bottles remaining proportionally
    final soldOrUsedBottles = existing.bottlesProduced - existing.bottlesRemaining;
    int newBottlesRemaining = bottlesProduced - soldOrUsedBottles;
    if (newBottlesRemaining < 0) newBottlesRemaining = 0;

    await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(id))).write(
      LocalYoghurtBatchesCompanion(
        productionDate: Value(productionDate),
        milkInputLiters: Value(milkInputLiters),
        totalMilkCost: Value(totalMilkCost),
        bottlesProduced: Value(bottlesProduced),
        packsProduced: Value(packsProduced),
        bottlesRemaining: Value(newBottlesRemaining),
        additionalCosts: Value(additionalCosts),
        notes: Value(notes),
      ),
    );

    sl<AuditRepository>().logAction(
      userName: 'Production Lead',
      actionType: 'UPDATE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Batch ${existing.batchNumber}',
      description: 'Updated Yoghurt Production Batch ${existing.batchNumber}',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_batches'}));
  }

  Future<void> deleteYoghurtBatch(String id) async {
    final existing = await (_db.select(_db.localYoghurtBatches)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return;

    await (_db.delete(_db.localYoghurtBatches)..where((t) => t.id.equals(id))).go();

    sl<AuditRepository>().logAction(
      userName: 'Production Lead',
      actionType: 'DELETE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Batch ${existing.batchNumber}',
      description: 'Deleted Yoghurt Production Batch ${existing.batchNumber}',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_batches'}));
  }

  // ── UPDATE & DELETE SALES ────────────────────────────────────────────────
  Future<void> updateYoghurtSale({
    required String id,
    required DateTime saleDate,
    required String customerName,
    String? customerPhone,
    String? description,
    required String saleUnit,
    required int quantityUnits,
    required double unitPrice,
    required double amountPaid,
    String? selectedBatchId,
  }) async {
    final existing = await (_db.select(_db.localYoghurtSales)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) throw Exception('Sale record not found.');

    final totalBottlesNeeded = saleUnit == 'packs' ? quantityUnits * 12 : quantityUnits;
    final totalAmount = quantityUnits * unitPrice;

    final diff = totalAmount - amountPaid;
    double balanceDue = diff.abs();
    String balancePayer = 'cleared';

    if (diff > 0.01) {
      balancePayer = 'client_owes_farm';
    } else if (diff < -0.01) {
      balancePayer = 'farm_owes_client';
    } else {
      balanceDue = 0.0;
      balancePayer = 'cleared';
    }

    await (_db.update(_db.localYoghurtSales)..where((t) => t.id.equals(id))).write(
      LocalYoghurtSalesCompanion(
        saleDate: Value(saleDate),
        customerName: Value(customerName),
        customerPhone: Value(customerPhone),
        description: Value(description ?? 'Yoghurt Sale ($quantityUnits $saleUnit)'),
        saleUnit: Value(saleUnit),
        quantityUnits: Value(quantityUnits),
        totalBottles: Value(totalBottlesNeeded),
        unitPrice: Value(unitPrice),
        totalAmount: Value(totalAmount),
        amountPaid: Value(amountPaid),
        balanceDue: Value(balanceDue),
        balancePayer: Value(balancePayer),
        selectedBatchId: Value(selectedBatchId),
      ),
    );

    sl<AuditRepository>().logAction(
      userName: 'Sales Manager',
      actionType: 'UPDATE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Sale to $customerName',
      description: 'Updated Yoghurt Sale entry for $customerName',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_sales', 'transactions'}));
  }

  Future<void> deleteYoghurtSale(String id) async {
    final existing = await (_db.select(_db.localYoghurtSales)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return;

    // Restore stock if associated with batch
    if (existing.selectedBatchId != null && existing.selectedBatchId!.isNotEmpty && existing.selectedBatchId != 'auto') {
      final batch = await (_db.select(_db.localYoghurtBatches)..where((t) => t.id.equals(existing.selectedBatchId!))).getSingleOrNull();
      if (batch != null) {
        await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(batch.id))).write(
          LocalYoghurtBatchesCompanion(bottlesRemaining: Value(batch.bottlesRemaining + existing.totalBottles)),
        );
      }
    }

    await (_db.delete(_db.localYoghurtSales)..where((t) => t.id.equals(id))).go();

    sl<AuditRepository>().logAction(
      userName: 'Sales Manager',
      actionType: 'DELETE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Sale to ${existing.customerName}',
      description: 'Deleted Yoghurt Sale entry for ${existing.customerName}',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_sales', 'transactions'}));
  }

  // ── UPDATE & DELETE RETURNS ──────────────────────────────────────────────
  Future<void> updateYoghurtReturn({
    required String id,
    required DateTime returnDate,
    required String customerName,
    required String description,
    required int initialBoughtBottles,
    required int returnedBottles,
    required int replacedBottles,
    String? selectedBatchId,
  }) async {
    final existing = await (_db.select(_db.localYoghurtReturns)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) throw Exception('Return record not found.');

    await (_db.update(_db.localYoghurtReturns)..where((t) => t.id.equals(id))).write(
      LocalYoghurtReturnsCompanion(
        returnDate: Value(returnDate),
        customerName: Value(customerName),
        description: Value(description),
        initialBoughtBottles: Value(initialBoughtBottles),
        returnedBottles: Value(returnedBottles),
        replacedBottles: Value(replacedBottles),
        selectedBatchId: Value(selectedBatchId),
      ),
    );

    sl<AuditRepository>().logAction(
      userName: 'Sales Manager',
      actionType: 'UPDATE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Return from $customerName',
      description: 'Updated Product Return record for $customerName',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_returns'}));
  }

  Future<void> deleteYoghurtReturn(String id) async {
    final existing = await (_db.select(_db.localYoghurtReturns)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return;

    // Restore stock if replaced bottles were deducted
    if (existing.replacedBottles > 0 && existing.selectedBatchId != null && existing.selectedBatchId!.isNotEmpty && existing.selectedBatchId != 'auto') {
      final batch = await (_db.select(_db.localYoghurtBatches)..where((t) => t.id.equals(existing.selectedBatchId!))).getSingleOrNull();
      if (batch != null) {
        await (_db.update(_db.localYoghurtBatches)..where((t) => t.id.equals(batch.id))).write(
          LocalYoghurtBatchesCompanion(bottlesRemaining: Value(batch.bottlesRemaining + existing.replacedBottles)),
        );
      }
    }

    await (_db.delete(_db.localYoghurtReturns)..where((t) => t.id.equals(id))).go();

    sl<AuditRepository>().logAction(
      userName: 'Sales Manager',
      actionType: 'DELETE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Return from ${existing.customerName}',
      description: 'Deleted Product Return record for ${existing.customerName}',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_returns'}));
  }

  // ── UPDATE & DELETE EXPENSES ─────────────────────────────────────────────
  Future<void> updateYoghurtExpense({
    required String id,
    required DateTime expenseDate,
    required String description,
    required String category,
    required double amount,
  }) async {
    final existing = await (_db.select(_db.localYoghurtExpenses)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) throw Exception('Expense record not found.');

    await (_db.update(_db.localYoghurtExpenses)..where((t) => t.id.equals(id))).write(
      LocalYoghurtExpensesCompanion(
        expenseDate: Value(expenseDate),
        description: Value(description),
        category: Value(category),
        amount: Value(amount),
      ),
    );

    sl<AuditRepository>().logAction(
      userName: 'Production Lead',
      actionType: 'UPDATE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Expense: $description',
      description: 'Updated Yoghurt Operational Expense ($description)',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_expenses', 'transactions'}));
  }

  Future<void> deleteYoghurtExpense(String id) async {
    final existing = await (_db.select(_db.localYoghurtExpenses)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return;

    await (_db.delete(_db.localYoghurtExpenses)..where((t) => t.id.equals(id))).go();

    sl<AuditRepository>().logAction(
      userName: 'Production Lead',
      actionType: 'DELETE',
      moduleName: 'yoghurt',
      entityId: id,
      entityName: 'Expense: ${existing.description}',
      description: 'Deleted Yoghurt Operational Expense (${existing.description})',
    );

    SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: {'yoghurt', 'yoghurt_expenses', 'transactions'}));
  }
}
