import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../database/local_db.dart';
import '../network/api_client.dart';
import '../di/service_locator.dart';
import '../network/notification_service.dart';
import 'sync_event_bus.dart';

class SyncManager {
  final LocalDatabase db;
  final ApiClient apiClient;
  bool _isSyncing = false;
  bool _isRestoring = false;

  SyncManager(this.db, this.apiClient) {
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        triggerSync();
        restoreFromSupabase();
      }
    });

    // Outbound queue check every 15 seconds (lightweight, non-blocking)
    Timer.periodic(const Duration(seconds: 15), (timer) {
      triggerSync();
    });

    // Inbound cloud sync check every 45 seconds for active multi-user sync
    Timer.periodic(const Duration(seconds: 45), (timer) {
      restoreFromSupabase();
    });
  }

  /// Triggered whenever the app is brought to foreground (AppLifecycleState.resumed)
  Future<void> syncOnAppResume() async {
    await syncAll();
  }

  // ─── Outbound Sync (local → Supabase) ─────────────────────────────────────

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Reset all stuck items to 0 attempts so they can retry on app launch / connection restored
      await (db.update(db.syncQueue)..where((t) => t.attempts.isBiggerOrEqualValue(5)))
          .write(const SyncQueueCompanion(attempts: Value(0)));

      final queueItems = await (db.select(db.syncQueue)
            ..where((t) => t.attempts.isSmallerThanValue(5))
            ..orderBy([(t) => OrderingTerm(expression: t.queuedAt)]))
          .get();

      int successCount = 0;
      for (var item in queueItems) {
        try {
          // Rescue check: discard corrupted IDs that are not valid UUIDs
          if (item.body.contains('"id":"anim_') || item.body.contains('"id":"milk_') || item.body.contains('"id": "anim_') || item.body.contains('"id": "milk_')) {
            await (db.delete(db.syncQueue)..where((t) => t.id.equals(item.id))).go();
            continue;
          }

          final success = await _processQueueItem(item);
          if (success) {
            await (db.delete(db.syncQueue)..where((t) => t.id.equals(item.id))).go();
            successCount++;
          } else {
            await _incrementAttempts(item, 'Server Error (Non-2xx Status)');
          }
        } catch (e) {
          String errMsg = e.toString();
          if (e is DioException) {
            errMsg = e.response?.data?.toString() ?? e.message ?? e.toString();
          }
          await _incrementAttempts(item, errMsg);
          
          if (e is DioException) {
            final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.connectionError ||
                e.response == null;
            if (isNetworkError) {
              // Stop processing queue if we have no network connection
              break;
            }
          }
        }
      }

      if (successCount > 0) {
        sl<NotificationService>().showLocalNotification(
          'Offline Sync Complete',
          '$successCount offline actions pushed to server.',
        );
      }
    } catch (_) {
      // Handle logging
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _incrementAttempts(SyncQueueData item, String error) async {
    await (db.update(db.syncQueue)..where((t) => t.id.equals(item.id))).write(
      SyncQueueCompanion(
        attempts: Value(item.attempts + 1),
        lastError: Value(error),
      ),
    );
  }

  Future<bool> _processQueueItem(SyncQueueData item) async {
    final data = jsonDecode(item.body);
    
    // Rescue missing required fields for animals to unblock old sync queues
    if (item.endpoint.startsWith('/animals')) {
      if (data is Map) {
        if (!data.containsKey('acquisition_cost') || data['acquisition_cost'] == null) data['acquisition_cost'] = 0.0;
        if (!data.containsKey('salvage_value') || data['salvage_value'] == null) data['salvage_value'] = 0.0;
        if (!data.containsKey('status') || data['status'] == null) data['status'] = 'active';
      }
    }

    Response response;
    if (item.method == 'POST') {
      response = await apiClient.dio.post(item.endpoint, data: data);
    } else if (item.method == 'PATCH') {
      response = await apiClient.dio.patch(item.endpoint, data: data);
    } else if (item.method == 'DELETE') {
      response = await apiClient.dio.delete(item.endpoint, data: data);
    } else {
      return false;
    }
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ─── Inbound Restore (Supabase → local) ───────────────────────────────────

  /// Checks if the local database is empty (fresh install / wipe) and if so,
  /// pulls all data from Supabase and populates the local database.
  Future<bool> restoreFromSupabaseIfNeeded() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return false;

      await restoreFromSupabase();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pushes local queue and checks for unsynced local records, then pulls remote changes
  Future<void> syncAll() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;
    
    // 1. Force upload any local records missing from Cloud (Animals, Yoghurt Batches, Sales, Expenses)
    await uploadUnsyncedLocalDataToCloud();

    // 2. Push local queue
    await triggerSync();
    
    // 3. Pull remote changes
    await restoreFromSupabase();
  }

  /// Automatically scans local database tables and uploads any records that do not exist on Supabase
  Future<void> uploadUnsyncedLocalDataToCloud() async {
    try {
      // A. Animals
      final localAnimals = await db.select(db.localAnimals).get();
      if (localAnimals.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/animals', queryParameters: {'select': 'id', 'limit': '2000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final anim in localAnimals) {
          if (!remoteIds.contains(anim.id)) {
            final payload = {
              'id': anim.id,
              'tag_id': anim.tagId,
              'species': anim.species,
              'breed': anim.breed,
              'sex': anim.sex,
              'date_of_birth': anim.dateOfBirth?.toIso8601String().split('T').first,
              'status': anim.status,
              'current_reproductive_status': anim.currentReproductiveStatus,
              'location_id': anim.locationId,
              'acquisition_cost': anim.acquisitionCost,
              'salvage_value': anim.salvageValue,
              'weight': anim.weight,
              'color': anim.color,
              'unique_marks': anim.uniqueMarks,
              'pedigree_type': anim.pedigreeType,
              'purpose': anim.purpose,
              'vaccination_status': anim.vaccinationStatus,
              'deworming_status': anim.dewormingStatus,
              'generation': anim.generation,
              'sire_id': anim.sireId,
              'dam_id': anim.damId,
            };
            try {
              await apiClient.dio.post('/animals', data: payload);
              remoteIds.add(anim.id);
            } catch (_) {}
          }
        }
      }

      // B. Yoghurt Batches
      final localBatches = await db.select(db.localYoghurtBatches).get();
      if (localBatches.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/yoghurt_production_batches', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final b in localBatches) {
          if (!remoteIds.contains(b.id)) {
            final payload = {
              'id': b.id,
              'batch_number': b.batchNumber,
              'production_date': b.productionDate.toIso8601String(),
              'milk_input_liters': b.milkInputLiters,
              'milk_cost_per_liter': b.milkCostPerLiter,
              'total_milk_cost': b.totalMilkCost,
              'bottles_produced': b.bottlesProduced,
              'packs_produced': b.packsProduced,
              'bottles_remaining': b.bottlesRemaining,
              'additional_costs': b.additionalCosts,
              'produced_by_name': b.producedByName,
              'produced_by_role': b.producedByRole,
              'notes': b.notes,
            };
            try {
              await apiClient.dio.post('/yoghurt_production_batches', data: payload);
              remoteIds.add(b.id);
            } catch (_) {}
          }
        }
      }

      // C. Yoghurt Sales
      final localSales = await db.select(db.localYoghurtSales).get();
      if (localSales.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/yoghurt_sales', queryParameters: {'select': 'id', 'limit': '2000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final s in localSales) {
          if (!remoteIds.contains(s.id)) {
            final payload = {
              'id': s.id,
              'sale_date': s.saleDate.toIso8601String(),
              'customer_name': s.customerName,
              'customer_phone': s.customerPhone,
              'description': s.description,
              'sale_unit': s.saleUnit,
              'quantity_units': s.quantityUnits,
              'total_bottles': s.totalBottles,
              'unit_price': s.unitPrice,
              'total_amount': s.totalAmount,
              'amount_paid': s.amountPaid,
              'balance_due': s.balanceDue,
              'balance_payer': s.balancePayer,
              'initiated_by_name': s.initiatedByName,
              'initiated_by_role': s.initiatedByRole,
              'selected_batch_id': s.selectedBatchId,
            };
            try {
              await apiClient.dio.post('/yoghurt_sales', data: payload);
              remoteIds.add(s.id);
            } catch (_) {}
          }
        }
      }

      // D. Yoghurt Expenses
      final localExp = await db.select(db.localYoghurtExpenses).get();
      if (localExp.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/yoghurt_expenses', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final ex in localExp) {
          if (!remoteIds.contains(ex.id)) {
            final payload = {
              'id': ex.id,
              'expense_date': ex.expenseDate.toIso8601String(),
              'description': ex.description,
              'category': ex.category,
              'amount': ex.amount,
              'processed_by_name': ex.processedByName,
              'processed_by_role': ex.processedByRole,
            };
            try {
              await apiClient.dio.post('/yoghurt_expenses', data: payload);
              remoteIds.add(ex.id);
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  /// Pulls all tables from Supabase and inserts into local DB.
  /// Uses insertOnConflictUpdate in batch transactions for high performance.
  /// Emits a SyncCompletedEvent via SyncEventBus so active BLoCs reload immediately.
  Future<void> restoreFromSupabase() async {
    if (_isRestoring) return;
    _isRestoring = true;

    try {
      final updatedTables = <String>{};
      final results = await Future.wait([
        _restoreAnimals(),
        _restoreMilkRecords(),
        _restoreTransactions(),
        _restoreTasks(),
        _restoreBreedingEvents(),
        _restoreAlerts(),
        _restoreMedications(),
        _restoreStaff(),
        _restoreYoghurtBatches(),
        _restoreYoghurtSales(),
        _restoreYoghurtReturns(),
        _restoreYoghurtExpenses(),
      ]);

      if (results[0]) updatedTables.add('animals');
      if (results[1]) updatedTables.add('milk_records');
      if (results[2]) updatedTables.add('transactions');
      if (results[3]) updatedTables.add('tasks');
      if (results[4]) updatedTables.add('breeding_events');
      if (results[5]) updatedTables.add('alerts');
      if (results[6]) updatedTables.add('medications');
      if (results[7]) updatedTables.add('staff');
      if (results[8]) updatedTables.add('yoghurt_batches');
      if (results[9]) updatedTables.add('yoghurt_sales');
      if (results[10]) updatedTables.add('yoghurt_returns');
      if (results[11]) updatedTables.add('yoghurt_expenses');
      if (results[8] || results[9] || results[10] || results[11]) updatedTables.add('yoghurt');

      if (updatedTables.isNotEmpty) {
        SyncEventBus().fire(SyncCompletedEvent(tablesUpdated: updatedTables));
      }
    } finally {
      _isRestoring = false;
    }
  }

  Future<bool> _restoreAnimals() async {
    try {
      final res = await apiClient.dio.get('/animals', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalAnimalsCompanion>[];
      for (final r in rows) {
        companions.add(LocalAnimalsCompanion.insert(
          id: r['id'] as String,
          tagId: r['tag_id'] as String,
          species: r['species'] as String,
          sex: r['sex'] as String,
          currentReproductiveStatus: r['current_reproductive_status'] as String? ?? 'unknown',
          breed: Value(r['breed'] as String?),
          dateOfBirth: Value(r['date_of_birth'] != null ? DateTime.tryParse(r['date_of_birth']) : null),
          locationId: Value(r['location_id'] as String?),
          acquisitionCost: Value((r['acquisition_cost'] as num?)?.toDouble() ?? 0.0),
          salvageValue: Value((r['salvage_value'] as num?)?.toDouble() ?? 0.0),
          imagePath: Value(r['image_path'] as String?),
          weight: Value((r['weight'] as num?)?.toDouble()),
          color: Value(r['color'] as String?),
          uniqueMarks: Value(r['unique_marks'] as String?),
          pedigreeType: Value(r['pedigree_type'] as String?),
          purpose: Value(r['purpose'] as String?),
          vaccinationStatus: Value(r['vaccination_status'] as String?),
          dewormingStatus: Value(r['deworming_status'] as String?),
          status: Value(r['status'] as String? ?? 'active'),
          sireId: Value(r['sire_id'] as String?),
          damId: Value(r['dam_id'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localAnimals, companions);
        });
        return true;
      }
    } catch (e) {
      // Non-fatal — continue restoring other tables
    }
    return false;
  }

  Future<bool> _restoreMilkRecords() async {
    try {
      final res = await apiClient.dio.get('/milk_records', queryParameters: {'limit': '5000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalMilkRecordsCompanion>[];
      for (final r in rows) {
        final dateStr = r['record_date'] as String?;
        if (dateStr == null) continue;
        companions.add(LocalMilkRecordsCompanion.insert(
          id: r['id'] as String,
          animalId: r['animal_id'] as String,
          recordDate: DateTime.parse(dateStr),
          milkingSession: r['milking_session'] as String? ?? 'morning',
          quantityLiters: (r['quantity_liters'] as num).toDouble(),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localMilkRecords, companions);
        });
        return true;
      }
    } catch (e) {
      // Non-fatal
    }
    return false;
  }

  Future<bool> _restoreTransactions() async {
    try {
      final res = await apiClient.dio.get('/transactions', queryParameters: {'limit': '5000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalTransactionsCompanion>[];
      for (final r in rows) {
        final dateStr = r['transaction_date'] as String?;
        if (dateStr == null) continue;
        companions.add(LocalTransactionsCompanion.insert(
          id: r['id'] as String,
          transactionType: r['transaction_type'] as String? ?? r['type'] as String? ?? 'expense',
          category: r['category'] as String? ?? 'general',
          amount: (r['amount'] as num).toDouble(),
          transactionDate: DateTime.parse(dateStr),
          description: Value(r['description'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localTransactions, companions);
        });
        return true;
      }
    } catch (e) {
      // Non-fatal
    }
    return false;
  }

  Future<bool> _restoreTasks() async {
    try {
      final res = await apiClient.dio.get('/tasks', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalTasksCompanion>[];
      for (final r in rows) {
        companions.add(LocalTasksCompanion.insert(
          id: r['id'] as String,
          title: r['title'] as String,
          status: r['status'] as String? ?? 'pending',
          priority: r['priority'] as String? ?? 'medium',
          description: Value(r['description'] as String?),
          assignedTo: Value(r['assigned_to'] as String?),
          dueDate: Value(r['due_date'] != null ? DateTime.tryParse(r['due_date']) : null),
          completedAt: Value(r['completed_at'] != null ? DateTime.tryParse(r['completed_at']) : null),
          category: Value(r['category'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localTasks, companions);
        });
        return true;
      }
    } catch (e) {
      // Non-fatal
    }
    return false;
  }

  Future<bool> _restoreBreedingEvents() async {
    try {
      final res = await apiClient.dio.get('/breeding_events', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalBreedingEventsCompanion>[];
      for (final r in rows) {
        final eventDateStr = r['event_date'] as String?;
        if (eventDateStr == null) continue;
        companions.add(LocalBreedingEventsCompanion.insert(
          id: r['id'] as String,
          animalId: r['animal_id'] as String,
          eventType: r['event_type'] as String,
          eventDate: DateTime.parse(eventDateStr),
          notes: Value(r['notes'] as String?),
          sireId: Value(r['sire_id'] as String?),
          payload: Value(r['payload'] != null ? jsonEncode(r['payload']) : null),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localBreedingEvents, companions);
        });
        return true;
      }
    } catch (e) {
      // Non-fatal
    }
    return false;
  }

  Future<bool> _restoreAlerts() async {
    try {
      final res = await apiClient.dio.get('/alerts', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalAlertsCompanion>[];
      for (final r in rows) {
        final createdStr = r['created_at'] as String?;
        companions.add(LocalAlertsCompanion.insert(
          id: r['id'] as String,
          title: r['title'] as String? ?? '',
          severity: r['severity'] as String? ?? 'insight',
          message: r['message'] as String? ?? '',
          createdAt: createdStr != null
              ? (DateTime.tryParse(createdStr) ?? DateTime.now())
              : DateTime.now(),
          location: Value(r['location'] as String?),
          impact: Value(r['impact'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localAlerts, companions);
        });
        return true;
      }
    } catch (e) {
      // Non-fatal
    }
    return false;
  }

  Future<bool> _restoreMedications() async {
    try {
      final res = await apiClient.dio.get('/medications', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalMedicationsCompanion>[];
      for (final r in rows) {
        companions.add(LocalMedicationsCompanion.insert(
          id: r['id'] as String,
          name: r['name'] as String,
          category: r['category'] as String? ?? 'other',
          unit: r['unit'] as String? ?? 'ml',
          currentStock: Value((r['current_stock'] as num?)?.toDouble() ?? 0.0),
          reorderThreshold: Value((r['reorder_threshold'] as num?)?.toDouble() ?? 5.0),
          costPerUnit: Value((r['cost_per_unit'] as num?)?.toDouble() ?? 0.0),
          supplier: Value(r['supplier'] as String?),
          expiryDate: Value(r['expiry_date'] != null ? DateTime.tryParse(r['expiry_date']) : null),
          batchNumber: Value(r['batch_number'] as String?),
          milkWithdrawalDays: Value((r['milk_withdrawal_days'] as num?)?.toInt() ?? 0),
          meatWithdrawalDays: Value((r['meat_withdrawal_days'] as num?)?.toInt() ?? 0),
          dosageRatePerKg: Value((r['dosage_rate_per_kg'] as num?)?.toDouble()),
          dosageRateText: Value(r['dosage_rate_text'] as String?),
          concentration: Value(r['concentration'] as String?),
          concentrationMgPerMl: Value((r['concentration_mg_per_ml'] as num?)?.toDouble()),
          concentrationValue: Value((r['concentration_value'] as num?)?.toDouble()),
          concentrationUnit: Value(r['concentration_unit'] as String?),
          isActive: Value(r['is_active'] as bool? ?? true),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localMedications, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreStaff() async {
    try {
      final res = await apiClient.dio.get('/staff', queryParameters: {'limit': '500'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalStaffCompanion>[];
      for (final r in rows) {
        companions.add(LocalStaffCompanion.insert(
          id: r['id'] as String,
          name: r['name'] as String,
          role: r['role'] as String? ?? 'Worker',
          phone: Value(r['phone'] as String?),
          baseSalary: Value((r['base_salary'] as num?)?.toDouble() ?? 0.0),
          performanceRating: Value((r['performance_rating'] as num?)?.toDouble() ?? 5.0),
          isActive: Value(r['is_active'] as bool? ?? true),
          profilePic: Value(r['profile_pic'] as String?),
          gender: Value(r['gender'] as String?),
          dateOfBirth: Value(r['date_of_birth'] != null ? DateTime.tryParse(r['date_of_birth']) : null),
          address: Value(r['address'] as String?),
          emergencyContact: Value(r['emergency_contact'] as String?),
          employmentType: Value(r['employment_type'] as String?),
          startDate: Value(r['start_date'] != null ? DateTime.tryParse(r['start_date']) : null),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localStaff, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreYoghurtBatches() async {
    try {
      final res = await apiClient.dio.get('/yoghurt_production_batches', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalYoghurtBatchesCompanion>[];
      for (final r in rows) {
        final prodDateStr = r['production_date'] as String?;
        if (prodDateStr == null) continue;
        companions.add(LocalYoghurtBatchesCompanion.insert(
          id: r['id'] as String,
          batchNumber: r['batch_number'] as String,
          productionDate: DateTime.parse(prodDateStr),
          milkInputLiters: (r['milk_input_liters'] as num).toDouble(),
          milkCostPerLiter: (r['milk_cost_per_liter'] as num?)?.toDouble() ?? 0.0,
          totalMilkCost: (r['total_milk_cost'] as num?)?.toDouble() ?? 0.0,
          bottlesProduced: (r['bottles_produced'] as num).toInt(),
          packsProduced: (r['packs_produced'] as num).toInt(),
          bottlesRemaining: (r['bottles_remaining'] as num).toInt(),
          additionalCosts: Value((r['additional_costs'] as num?)?.toDouble() ?? 0.0),
          producedByName: r['produced_by_name'] as String? ?? 'Staff',
          producedByRole: r['produced_by_role'] as String? ?? 'Production Lead',
          notes: Value(r['notes'] as String?),
          createdAt: Value(r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now()),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localYoghurtBatches, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreYoghurtSales() async {
    try {
      final res = await apiClient.dio.get('/yoghurt_sales', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalYoghurtSalesCompanion>[];
      for (final r in rows) {
        final saleDateStr = r['sale_date'] as String?;
        if (saleDateStr == null) continue;
        companions.add(LocalYoghurtSalesCompanion.insert(
          id: r['id'] as String,
          saleDate: DateTime.parse(saleDateStr),
          customerName: r['customer_name'] as String,
          customerPhone: Value(r['customer_phone'] as String?),
          description: Value(r['description'] as String?),
          saleUnit: r['sale_unit'] as String? ?? 'bottles',
          quantityUnits: (r['quantity_units'] as num).toInt(),
          totalBottles: (r['total_bottles'] as num).toInt(),
          unitPrice: (r['unit_price'] as num).toDouble(),
          totalAmount: (r['total_amount'] as num).toDouble(),
          amountPaid: (r['amount_paid'] as num).toDouble(),
          balanceDue: Value((r['balance_due'] as num?)?.toDouble() ?? 0.0),
          balancePayer: r['balance_payer'] as String? ?? 'cleared',
          initiatedByName: r['initiated_by_name'] as String? ?? 'Staff',
          initiatedByRole: r['initiated_by_role'] as String? ?? 'Officer',
          selectedBatchId: Value(r['selected_batch_id'] as String?),
          createdAt: Value(r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now()),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localYoghurtSales, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreYoghurtReturns() async {
    try {
      final res = await apiClient.dio.get('/yoghurt_returns', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalYoghurtReturnsCompanion>[];
      for (final r in rows) {
        final retDateStr = r['return_date'] as String?;
        if (retDateStr == null) continue;
        companions.add(LocalYoghurtReturnsCompanion.insert(
          id: r['id'] as String,
          returnDate: DateTime.parse(retDateStr),
          customerName: r['customer_name'] as String,
          description: Value(r['description'] as String?),
          initialBoughtBottles: (r['initial_bought_bottles'] as num).toInt(),
          returnedBottles: (r['returned_bottles'] as num).toInt(),
          replacedBottles: (r['replaced_bottles'] as num).toInt(),
          processedByName: r['processed_by_name'] as String? ?? 'Staff',
          processedByRole: r['processed_by_role'] as String? ?? 'Officer',
          selectedBatchId: Value(r['selected_batch_id'] as String?),
          createdAt: Value(r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now()),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localYoghurtReturns, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreYoghurtExpenses() async {
    try {
      final res = await apiClient.dio.get('/yoghurt_expenses', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalYoghurtExpensesCompanion>[];
      for (final r in rows) {
        final expDateStr = r['expense_date'] as String?;
        if (expDateStr == null) continue;
        companions.add(LocalYoghurtExpensesCompanion.insert(
          id: r['id'] as String,
          expenseDate: DateTime.parse(expDateStr),
          description: r['description'] as String,
          category: Value(r['category'] as String? ?? 'other'),
          amount: (r['amount'] as num).toDouble(),
          processedByName: r['processed_by_name'] as String? ?? 'Staff',
          processedByRole: r['processed_by_role'] as String? ?? 'Officer',
          createdAt: Value(r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now()),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localYoghurtExpenses, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }
}
