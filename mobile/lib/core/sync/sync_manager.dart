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

      // E. Yoghurt Returns
      final localReturns = await db.select(db.localYoghurtReturns).get();
      if (localReturns.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/yoghurt_returns', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final ret in localReturns) {
          if (!remoteIds.contains(ret.id)) {
            final payload = {
              'id': ret.id,
              'return_date': ret.returnDate.toIso8601String(),
              'customer_name': ret.customerName,
              'description': ret.description,
              'initial_bought_bottles': ret.initialBoughtBottles,
              'returned_bottles': ret.returnedBottles,
              'replaced_bottles': ret.replacedBottles,
              'processed_by_name': ret.processedByName,
              'processed_by_role': ret.processedByRole,
              'selected_batch_id': ret.selectedBatchId,
            };
            try {
              await apiClient.dio.post('/yoghurt_returns', data: payload);
              remoteIds.add(ret.id);
            } catch (_) {}
          }
        }
      }

      // F. Milk Records
      final localMilk = await db.select(db.localMilkRecords).get();
      if (localMilk.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/milk_records', queryParameters: {'select': 'id', 'limit': '5000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final m in localMilk) {
          if (!remoteIds.contains(m.id)) {
            final payload = {
              'id': m.id,
              'animal_id': m.animalId,
              'record_date': m.recordDate.toIso8601String(),
              'milking_session': m.milkingSession,
              'quantity_liters': m.quantityLiters,
              'is_withdrawn': m.isWithdrawn,
            };
            try {
              await apiClient.dio.post('/milk_records', data: payload);
              remoteIds.add(m.id);
            } catch (_) {}
          }
        }
      }

      // G. Transactions
      final localTx = await db.select(db.localTransactions).get();
      if (localTx.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/transactions', queryParameters: {'select': 'id', 'limit': '5000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final t in localTx) {
          if (!remoteIds.contains(t.id)) {
            final payload = {
              'id': t.id,
              'transaction_type': t.transactionType,
              'category': t.category,
              'amount': t.amount,
              'currency': t.currency,
              'related_entity_type': t.relatedEntityType,
              'related_entity_id': t.relatedEntityId,
              'description': t.description,
              'transaction_date': t.transactionDate.toIso8601String(),
              'is_reconciled': t.isReconciled,
            };
            try {
              await apiClient.dio.post('/transactions', data: payload);
              remoteIds.add(t.id);
            } catch (_) {}
          }
        }
      }

      // H. Tasks
      final localTasks = await db.select(db.localTasks).get();
      if (localTasks.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/tasks', queryParameters: {'select': 'id', 'limit': '2000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final tk in localTasks) {
          if (!remoteIds.contains(tk.id)) {
            final payload = {
              'id': tk.id,
              'title': tk.title,
              'description': tk.description,
              'priority': tk.priority,
              'status': tk.status,
              'assigned_to': tk.assignedTo,
              'due_date': tk.dueDate?.toIso8601String().split('T').first,
              'completed_at': tk.completedAt?.toIso8601String(),
            };
            try {
              await apiClient.dio.post('/tasks', data: payload);
              remoteIds.add(tk.id);
            } catch (_) {}
          }
        }
      }

      // I. Poultry Batches
      final localPoultry = await db.select(db.localPoultryBatches).get();
      if (localPoultry.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/poultry_batches', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final p in localPoultry) {
          if (!remoteIds.contains(p.id)) {
            final payload = {
              'id': p.id,
              'batch_type': p.purpose ?? 'broiler',
              'breed': p.breed ?? 'Broiler',
              'start_date': p.startDate.toIso8601String().split('T').first,
              'initial_count': p.initialCount,
              'current_count': p.currentCount,
              'initial_chick_cost': p.acquisitionCost,
              'status': p.status,
              'location_id': '${p.batchNumber}|${p.houseName}',
              'batch_name': p.batchNumber,
              'house_name': p.houseName,
            };
            try {
              await apiClient.dio.post('/poultry_batches', data: payload);
              remoteIds.add(p.id);
            } catch (_) {}
          }
        }
      }

      // J. Hatchery Batches
      final localHatchery = await db.select(db.localHatcheryBatches).get();
      if (localHatchery.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/hatchery_batches', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final h in localHatchery) {
          if (!remoteIds.contains(h.id)) {
            final payload = {
              'id': h.id,
              'egg_source': h.eggSource,
              'egg_count': h.eggCount,
              'breed': h.breed,
              'set_date': h.setDate.toIso8601String().split('T').first,
              'expected_hatch_date': h.expectedHatchDate.toIso8601String().split('T').first,
              'fertile_eggs': h.fertileEggs,
              'hatched_chicks': h.hatchedChicks,
              'failed_eggs': h.failedEggs,
              'initial_egg_cost': h.initialEggCost,
              'status': h.status,
              'crate_number': h.crateNumber,
              'crate_section': h.crateSection,
            };
            try {
              await apiClient.dio.post('/hatchery_batches', data: payload);
              remoteIds.add(h.id);
            } catch (_) {}
          }
        }
      }

      // K. Feed Items
      final localFeed = await db.select(db.localFeedItems).get();
      if (localFeed.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/feed_items', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final f in localFeed) {
          if (!remoteIds.contains(f.id)) {
            final payload = {
              'id': f.id,
              'name': f.name,
              'category': f.category,
              'unit': f.unit,
              'purchase_unit': f.purchaseUnit,
              'current_stock': f.currentStock,
              'reorder_threshold': f.reorderThreshold,
              'cost_per_unit': f.costPerUnit,
              'weight_per_unit': f.weightPerUnit,
              'cost_per_kg': f.costPerKg,
              'supplier': f.supplier,
              'is_active': f.isActive,
              'currency': 'NGN',
            };
            try {
              await apiClient.dio.post('/feed_items', data: payload);
              remoteIds.add(f.id);
            } catch (_) {}
          }
        }
      }

      // L. Inventory Logs
      final localInvLogs = await db.select(db.localInventoryLogs).get();
      if (localInvLogs.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/inventory_logs', queryParameters: {'select': 'id', 'limit': '2000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final l in localInvLogs) {
          if (!remoteIds.contains(l.id)) {
            final payload = {
              'id': l.id,
              'item_id': l.itemId,
              'change_type': l.changeType,
              'quantity_change': l.quantityChange,
              'balance_after': l.balanceAfter,
              'log_date': l.logDate.toIso8601String().split('T').first,
              'related_entity_type': l.relatedEntityType,
              'related_entity_id': l.relatedEntityId,
              'notes': l.notes,
            };
            try {
              await apiClient.dio.post('/inventory_logs', data: payload);
              remoteIds.add(l.id);
            } catch (_) {}
          }
        }
      }

      // M. Medications
      final localMeds = await db.select(db.localMedications).get();
      if (localMeds.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/medications', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final med in localMeds) {
          if (!remoteIds.contains(med.id)) {
            final payload = {
              'id': med.id,
              'name': med.name,
              'category': med.category,
              'unit': med.unit,
              'current_stock': med.currentStock,
              'reorder_threshold': med.reorderThreshold,
              'cost_per_unit': med.costPerUnit,
              'supplier': med.supplier,
              'expiry_date': med.expiryDate?.toIso8601String(),
              'batch_number': med.batchNumber,
              'milk_withdrawal_days': med.milkWithdrawalDays,
              'meat_withdrawal_days': med.meatWithdrawalDays,
              'is_active': med.isActive,
              'dosage_rate_per_kg': med.dosageRatePerKg,
              'dosage_rate_text': med.dosageRateText,
              'concentration': med.concentration,
              'concentration_mg_per_ml': med.concentrationMgPerMl,
              'concentration_value': med.concentrationValue,
              'concentration_unit': med.concentrationUnit,
            };
            try {
              await apiClient.dio.post('/medications', data: payload);
              remoteIds.add(med.id);
            } catch (_) {}
          }
        }
      }

      // N. Animal Medical Records
      final localMedRecords = await db.select(db.localAnimalMedicalRecords).get();
      if (localMedRecords.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/animal_medical_records', queryParameters: {'select': 'id', 'limit': '2000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final mr in localMedRecords) {
          if (!remoteIds.contains(mr.id)) {
            final payload = {
              'id': mr.id,
              'animal_id': mr.animalId,
              'medication_id': mr.medicationId,
              'administered_dose': mr.administeredDose,
              'cost': mr.cost,
              'treatment_date': mr.treatmentDate.toIso8601String(),
              'diagnosed_condition': mr.diagnosedCondition,
              'administered_by': mr.administeredBy,
              'withdrawal_end_date': mr.withdrawalEndDate?.toIso8601String(),
              'notes': mr.notes,
            };
            try {
              await apiClient.dio.post('/animal_medical_records', data: payload);
              remoteIds.add(mr.id);
            } catch (_) {}
          }
        }
      }

      // O. Staff
      final localStaff = await db.select(db.localStaff).get();
      if (localStaff.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/staff', queryParameters: {'select': 'id', 'limit': '500'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final st in localStaff) {
          if (!remoteIds.contains(st.id)) {
            final payload = {
              'id': st.id,
              'name': st.name,
              'role': st.role,
              'phone': st.phone,
              'base_salary': st.baseSalary,
              'performance_rating': st.performanceRating,
              'is_active': st.isActive,
              'profile_pic': st.profilePic,
              'gender': st.gender,
              'date_of_birth': st.dateOfBirth?.toIso8601String().split('T').first,
              'address': st.address,
              'emergency_contact': st.emergencyContact,
              'employment_type': st.employmentType,
              'start_date': st.startDate?.toIso8601String(),
            };
            try {
              await apiClient.dio.post('/staff', data: payload);
              remoteIds.add(st.id);
            } catch (_) {}
          }
        }
      }

      // P. Salary Advances
      final localAdvances = await db.select(db.localSalaryAdvances).get();
      if (localAdvances.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/salary_advances', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final sa in localAdvances) {
          if (!remoteIds.contains(sa.id)) {
            final payload = {
              'id': sa.id,
              'staff_id': sa.staffId,
              'advance_amount': sa.advanceAmount,
              'monthly_deduction': sa.monthlyDeduction,
              'repayment_months': 1,
              'total_repaid': sa.totalRepaid,
              'collection_date': sa.collectionDate.toIso8601String(),
              'is_fully_repaid': sa.isFullyRepaid,
              'is_one_off_advance': sa.isOneOffAdvance,
              'notes': sa.notes,
            };
            try {
              await apiClient.dio.post('/salary_advances', data: payload);
              remoteIds.add(sa.id);
            } catch (_) {}
          }
        }
      }

      // Q. Staff Queries
      final localQueries = await db.select(db.localStaffQueries).get();
      if (localQueries.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/staff_queries', queryParameters: {'select': 'id', 'limit': '1000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final sq in localQueries) {
          if (!remoteIds.contains(sq.id)) {
            final payload = {
              'id': sq.id,
              'staff_id': sq.staffId,
              'title': sq.title,
              'description': sq.description,
              'deduction_amount': sq.deductionAmount,
              'is_resolved': sq.isResolved,
              'resolution_notes': sq.resolutionNotes,
              'resolved_at': sq.resolvedAt?.toIso8601String(),
              'issue_date': sq.issueDate.toIso8601String().split('T').first,
            };
            try {
              await apiClient.dio.post('/staff_queries', data: payload);
              remoteIds.add(sq.id);
            } catch (_) {}
          }
        }
      }

      // R. Breeding Events
      final localBreeding = await db.select(db.localBreedingEvents).get();
      if (localBreeding.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/breeding_events', queryParameters: {'select': 'id', 'limit': '2000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final be in localBreeding) {
          if (!remoteIds.contains(be.id)) {
            final payload = {
              'id': be.id,
              'animal_id': be.animalId,
              'event_type': be.eventType,
              'event_date': be.eventDate.toIso8601String(),
              'sire_id': be.sireId,
              'semen_batch_id': be.semenBatchId,
              'technician': be.technician,
              'result': be.result,
              'notes': be.notes,
            };
            try {
              await apiClient.dio.post('/breeding_events', data: payload);
              remoteIds.add(be.id);
            } catch (_) {}
          }
        }
      }

      // S. Alerts
      final localAlerts = await db.select(db.localAlerts).get();
      if (localAlerts.isNotEmpty) {
        final remoteRes = await apiClient.dio.get('/alerts', queryParameters: {'select': 'id', 'limit': '2000'});
        final remoteIds = ((remoteRes.data as List?) ?? []).map((e) => e['id']?.toString()).toSet();
        for (final al in localAlerts) {
          if (!remoteIds.contains(al.id)) {
            final payload = {
              'id': al.id,
              'title': al.title,
              'severity': al.severity,
              'message': al.message,
              'location': al.location,
              'impact': al.impact,
              'created_at': al.createdAt.toIso8601String(),
              'is_resolved': al.isResolved,
            };
            try {
              await apiClient.dio.post('/alerts', data: payload);
              remoteIds.add(al.id);
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
        _restorePoultryBatches(),
        _restoreHatcheryBatches(),
        _restoreFeedItems(),
        _restoreInventoryLogs(),
        _restoreAnimalMedicalRecords(),
        _restoreSalaryAdvances(),
        _restoreStaffQueries(),
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
      if (results[12]) updatedTables.add('poultry');
      if (results[13]) updatedTables.add('hatchery');
      if (results[14]) updatedTables.add('feed_items');
      if (results[15]) updatedTables.add('inventory');
      if (results[16]) updatedTables.add('medical_records');
      if (results[17]) updatedTables.add('salary_advances');
      if (results[18]) updatedTables.add('staff_queries');

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
          generation: Value(r['generation'] as String? ?? 'F1'),
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

  Future<bool> _restorePoultryBatches() async {
    try {
      final res = await apiClient.dio.get('/poultry_batches', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalPoultryBatchesCompanion>[];
      for (final r in rows) {
        final startDateStr = r['start_date'] as String?;
        if (startDateStr == null) continue;
        final locId = r['location_id'] as String? ?? '';
        final parts = locId.split('|');
        final batchNum = r['batch_name'] as String? ?? (parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : 'Batch');
        final house = r['house_name'] as String? ?? (parts.length > 1 ? parts[1] : 'Main House');
        companions.add(LocalPoultryBatchesCompanion.insert(
          id: r['id'] as String,
          batchNumber: batchNum,
          houseName: house,
          initialCount: (r['initial_count'] as num).toInt(),
          currentCount: (r['current_count'] as num).toInt(),
          startDate: DateTime.parse(startDateStr),
          status: r['status'] as String? ?? 'active',
          breed: Value(r['breed'] as String?),
          purpose: Value(r['batch_type'] as String?),
          acquisitionCost: Value((r['initial_chick_cost'] as num?)?.toDouble() ?? 0.0),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localPoultryBatches, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreHatcheryBatches() async {
    try {
      final res = await apiClient.dio.get('/hatchery_batches', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalHatcheryBatchesCompanion>[];
      for (final r in rows) {
        final setDateStr = r['set_date'] as String?;
        final hatchDateStr = r['expected_hatch_date'] as String?;
        if (setDateStr == null || hatchDateStr == null) continue;
        companions.add(LocalHatcheryBatchesCompanion.insert(
          id: r['id'] as String,
          eggSource: r['egg_source'] as String? ?? 'Farm',
          eggCount: (r['egg_count'] as num).toInt(),
          breed: Value(r['breed'] as String?),
          setDate: DateTime.parse(setDateStr),
          expectedHatchDate: DateTime.parse(hatchDateStr),
          fertileEggs: Value((r['fertile_eggs'] as num?)?.toInt()),
          hatchedChicks: Value((r['hatched_chicks'] as num?)?.toInt()),
          failedEggs: Value((r['failed_eggs'] as num?)?.toInt()),
          initialEggCost: Value((r['initial_egg_cost'] as num?)?.toDouble() ?? 0.0),
          status: Value(r['status'] as String? ?? 'incubating'),
          crateNumber: Value(r['crate_number'] as String?),
          crateSection: Value(r['crate_section'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localHatcheryBatches, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreFeedItems() async {
    try {
      final res = await apiClient.dio.get('/feed_items', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalFeedItemsCompanion>[];
      for (final r in rows) {
        companions.add(LocalFeedItemsCompanion.insert(
          id: r['id'] as String,
          name: r['name'] as String,
          category: r['category'] as String? ?? 'feed',
          unit: r['unit'] as String? ?? 'kg',
          purchaseUnit: Value(r['purchase_unit'] as String? ?? 'bag'),
          currentStock: (r['current_stock'] as num?)?.toDouble() ?? 0.0,
          reorderThreshold: (r['reorder_threshold'] as num?)?.toDouble() ?? 10.0,
          costPerUnit: (r['cost_per_unit'] as num?)?.toDouble() ?? 0.0,
          weightPerUnit: Value((r['weight_per_unit'] as num?)?.toDouble() ?? 1.0),
          costPerKg: Value((r['cost_per_kg'] as num?)?.toDouble() ?? 0.0),
          supplier: Value(r['supplier'] as String?),
          isActive: Value(r['is_active'] as bool? ?? true),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localFeedItems, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreInventoryLogs() async {
    try {
      final res = await apiClient.dio.get('/inventory_logs', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalInventoryLogsCompanion>[];
      for (final r in rows) {
        final logDateStr = r['log_date'] as String?;
        if (logDateStr == null) continue;
        companions.add(LocalInventoryLogsCompanion.insert(
          id: r['id'] as String,
          itemId: r['item_id'] as String,
          changeType: r['change_type'] as String? ?? 'consumption',
          quantityChange: (r['quantity_change'] as num?)?.toDouble() ?? 0.0,
          balanceAfter: (r['balance_after'] as num?)?.toDouble() ?? 0.0,
          logDate: DateTime.parse(logDateStr),
          relatedEntityType: Value(r['related_entity_type'] as String?),
          relatedEntityId: Value(r['related_entity_id'] as String?),
          notes: Value(r['notes'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localInventoryLogs, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreAnimalMedicalRecords() async {
    try {
      final res = await apiClient.dio.get('/animal_medical_records', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalAnimalMedicalRecordsCompanion>[];
      for (final r in rows) {
        final treatDateStr = r['treatment_date'] as String?;
        if (treatDateStr == null) continue;
        companions.add(LocalAnimalMedicalRecordsCompanion.insert(
          id: r['id'] as String,
          animalId: r['animal_id'] as String? ?? '',
          medicationId: r['medication_id'] as String? ?? '',
          administeredDose: (r['administered_dose'] as num?)?.toDouble() ?? 0.0,
          cost: (r['cost'] as num?)?.toDouble() ?? 0.0,
          treatmentDate: DateTime.parse(treatDateStr),
          diagnosedCondition: r['diagnosed_condition'] as String? ?? 'General Treatment',
          administeredBy: Value(r['administered_by'] as String?),
          withdrawalEndDate: Value(r['withdrawal_end_date'] != null ? DateTime.tryParse(r['withdrawal_end_date']) : null),
          notes: Value(r['notes'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localAnimalMedicalRecords, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreSalaryAdvances() async {
    try {
      final res = await apiClient.dio.get('/salary_advances', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalSalaryAdvancesCompanion>[];
      for (final r in rows) {
        final colDateStr = r['collection_date'] as String?;
        if (colDateStr == null) continue;
        companions.add(LocalSalaryAdvancesCompanion.insert(
          id: r['id'] as String,
          staffId: r['staff_id'] as String? ?? '',
          advanceAmount: (r['advance_amount'] as num?)?.toDouble() ?? 0.0,
          monthlyDeduction: (r['monthly_deduction'] as num?)?.toDouble() ?? 0.0,
          totalRepaid: Value((r['total_repaid'] as num?)?.toDouble() ?? 0.0),
          collectionDate: DateTime.parse(colDateStr),
          isFullyRepaid: Value(r['is_fully_repaid'] as bool? ?? false),
          isOneOffAdvance: Value(r['is_one_off_advance'] as bool? ?? false),
          notes: Value(r['notes'] as String?),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localSalaryAdvances, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _restoreStaffQueries() async {
    try {
      final res = await apiClient.dio.get('/staff_queries', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      final companions = <LocalStaffQueriesCompanion>[];
      for (final r in rows) {
        final issDateStr = r['issue_date'] as String?;
        if (issDateStr == null) continue;
        companions.add(LocalStaffQueriesCompanion.insert(
          id: r['id'] as String,
          staffId: r['staff_id'] as String? ?? '',
          title: r['title'] as String? ?? 'Query',
          description: Value(r['description'] as String?),
          deductionAmount: Value((r['deduction_amount'] as num?)?.toDouble() ?? 0.0),
          isResolved: Value(r['is_resolved'] as bool? ?? false),
          resolutionNotes: Value(r['resolution_notes'] as String?),
          resolvedAt: Value(r['resolved_at'] != null ? DateTime.tryParse(r['resolved_at']) : null),
          issueDate: DateTime.parse(issDateStr),
        ));
      }
      if (companions.isNotEmpty) {
        await db.batch((batch) {
          batch.insertAllOnConflictUpdate(db.localStaffQueries, companions);
        });
        return true;
      }
    } catch (_) {}
    return false;
  }
}
