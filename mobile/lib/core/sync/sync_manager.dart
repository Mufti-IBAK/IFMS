import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../database/local_db.dart';
import '../network/api_client.dart';
import '../di/service_locator.dart';
import '../network/notification_service.dart';

class SyncManager {
  final LocalDatabase db;
  final ApiClient apiClient;
  bool _isSyncing = false;

  SyncManager(this.db, this.apiClient) {
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        triggerSync();
      }
    });
  }

  // ─── Outbound Sync (local → Supabase) ─────────────────────────────────────

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Unblock items that were stuck due to the acquisition_cost bug
      await (db.update(db.syncQueue)..where((t) => t.endpoint.like('/animals%') & t.attempts.isBiggerOrEqualValue(5)))
          .write(const SyncQueueCompanion(attempts: Value(4)));

      final queueItems = await (db.select(db.syncQueue)
            ..where((t) => t.attempts.isSmallerThanValue(5))
            ..orderBy([(t) => OrderingTerm(expression: t.queuedAt)]))
          .get();

      int successCount = 0;
      for (var item in queueItems) {
        try {
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
      final count = await db.localAnimals.count().getSingle();
      if (count > 0) return false; // Data already exists — skip restore

      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return false;

      await restoreFromSupabase();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pulls all tables from Supabase and inserts into local DB.
  /// Uses insertOnConflictUpdate so it is safe to call multiple times.
  Future<void> restoreFromSupabase() async {
    await Future.wait([
      _restoreAnimals(),
      _restoreMilkRecords(),
      _restoreTransactions(),
      _restoreTasks(),
      _restoreBreedingEvents(),
      _restoreAlerts(),
    ]);
  }

  Future<void> _restoreAnimals() async {
    try {
      final res = await apiClient.dio.get('/animals', queryParameters: {'limit': '1000'});
      final rows = (res.data as List?) ?? [];
      for (final r in rows) {
        await db.into(db.localAnimals).insertOnConflictUpdate(LocalAnimalsCompanion.insert(
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
    } catch (e) {
      // Non-fatal — continue restoring other tables
    }
  }

  Future<void> _restoreMilkRecords() async {
    try {
      final res = await apiClient.dio.get('/milk_records', queryParameters: {'limit': '5000'});
      final rows = (res.data as List?) ?? [];
      for (final r in rows) {
        final dateStr = r['record_date'] as String?;
        if (dateStr == null) continue;
        await db.into(db.localMilkRecords).insertOnConflictUpdate(LocalMilkRecordsCompanion.insert(
          id: r['id'] as String,
          animalId: r['animal_id'] as String,
          recordDate: DateTime.parse(dateStr),
          milkingSession: r['milking_session'] as String? ?? 'morning',
          quantityLiters: (r['quantity_liters'] as num).toDouble(),
        ));
      }
    } catch (e) {
      // Non-fatal
    }
  }

  Future<void> _restoreTransactions() async {
    try {
      final res = await apiClient.dio.get('/transactions', queryParameters: {'limit': '5000'});
      final rows = (res.data as List?) ?? [];
      for (final r in rows) {
        final dateStr = r['transaction_date'] as String?;
        if (dateStr == null) continue;
        await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
          id: r['id'] as String,
          transactionType: r['transaction_type'] as String? ?? r['type'] as String? ?? 'expense',
          category: r['category'] as String? ?? 'general',
          amount: (r['amount'] as num).toDouble(),
          transactionDate: DateTime.parse(dateStr),
          description: Value(r['description'] as String?),
        ));
      }
    } catch (e) {
      // Non-fatal
    }
  }

  Future<void> _restoreTasks() async {
    try {
      final res = await apiClient.dio.get('/tasks', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      for (final r in rows) {
        await db.into(db.localTasks).insertOnConflictUpdate(LocalTasksCompanion.insert(
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
    } catch (e) {
      // Non-fatal
    }
  }

  Future<void> _restoreBreedingEvents() async {
    try {
      final res = await apiClient.dio.get('/breeding_events', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      for (final r in rows) {
        final eventDateStr = r['event_date'] as String?;
        if (eventDateStr == null) continue;
        await db.into(db.localBreedingEvents).insertOnConflictUpdate(LocalBreedingEventsCompanion.insert(
          id: r['id'] as String,
          animalId: r['animal_id'] as String,
          eventType: r['event_type'] as String,
          eventDate: DateTime.parse(eventDateStr),
          notes: Value(r['notes'] as String?),
          sireId: Value(r['sire_id'] as String?),
          payload: Value(r['payload'] != null ? jsonEncode(r['payload']) : null),
        ));
      }
    } catch (e) {
      // Non-fatal
    }
  }

  Future<void> _restoreAlerts() async {
    try {
      final res = await apiClient.dio.get('/alerts', queryParameters: {'limit': '2000'});
      final rows = (res.data as List?) ?? [];
      for (final r in rows) {
        final createdStr = r['created_at'] as String?;
        await db.into(db.localAlerts).insertOnConflictUpdate(LocalAlertsCompanion.insert(
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
    } catch (e) {
      // Non-fatal
    }
  }
}
