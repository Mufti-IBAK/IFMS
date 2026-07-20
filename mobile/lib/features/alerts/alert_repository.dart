import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class AlertRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  AlertRepository(this.apiClient, this.db);

  Future<List<LocalAlert>> getAlerts() async {
    try {
      final response = await apiClient.dio.get('/alerts');
      final list = response.data as List;
      await _syncAlerts(list);
    } catch (_) {}
    
    final dbAlerts = await (db.select(db.localAlerts)
          ..where((t) => t.isResolved.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
    final dynamicAlerts = await _generateDynamicAlerts();
    
    final allAlerts = [...dynamicAlerts, ...dbAlerts];
    // Sort combined by date descending
    allAlerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allAlerts;
  }

  Future<List<LocalAlert>> _generateDynamicAlerts() async {
    final List<LocalAlert> dynamicAlerts = [];
    final now = DateTime.now();

    // Fetch resolved alert IDs from database to skip them
    final resolvedIds = (await (db.select(db.localAlerts)..where((t) => t.isResolved.equals(true))).get())
        .map((a) => a.id)
        .toSet();

    // 1. Low Inventory (Feed)
    final lowFeed = await (db.select(db.localFeedItems)..where((t) => t.currentStock.isSmallerOrEqual(t.reorderThreshold) & t.isActive.equals(true))).get();
    for (var item in lowFeed) {
      final alertId = 'dyn_feed_${item.id}';
      if (resolvedIds.contains(alertId)) continue;
      dynamicAlerts.add(LocalAlert(
        id: alertId,
        title: 'Low Feed Inventory',
        severity: 'critical',
        message: '${item.name} is running low. Current stock: ${item.currentStock} ${item.unit}.',
        createdAt: now,
        isResolved: false,
        location: null,
        impact: 'High',
      ));
    }

    // 2. Low Inventory (Medication)
    final lowMeds = await (db.select(db.localMedications)..where((t) => t.currentStock.isSmallerOrEqual(t.reorderThreshold) & t.isActive.equals(true))).get();
    for (var item in lowMeds) {
      final alertId = 'dyn_med_${item.id}';
      if (resolvedIds.contains(alertId)) continue;
      dynamicAlerts.add(LocalAlert(
        id: alertId,
        title: 'Low Medication Stock',
        severity: 'warning',
        message: '${item.name} is running low. Current stock: ${item.currentStock} ${item.unit}.',
        createdAt: now,
        isResolved: false,
        location: null,
        impact: 'Medium',
      ));
    }

    // 3. Mortality Cases
    final deceasedAnimals = await (db.select(db.localAnimals)..where((t) => t.status.equals('deceased'))).get();
    for (var animal in deceasedAnimals) {
      final alertId = 'dyn_mort_${animal.id}';
      if (resolvedIds.contains(alertId)) continue;
      dynamicAlerts.add(LocalAlert(
        id: alertId,
        title: 'Mortality Case Logged',
        severity: 'critical',
        message: 'Animal ${animal.tagId} (${animal.species}) has been recorded as deceased.',
        createdAt: now,
        isResolved: false,
        location: animal.locationId,
        impact: 'High',
      ));
    }

    // 4. Sick Animals (Recent Medical Reports in last 7 days)
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recentMedical = await (db.select(db.localAnimalMedicalRecords)..where((t) => t.treatmentDate.isBiggerOrEqualValue(sevenDaysAgo))).get();
    
    // To avoid duplicates, we group by animal id
    final sickAnimalIds = recentMedical.map((r) => r.animalId).toSet();
    
    for (var animalId in sickAnimalIds) {
      final alertId = 'dyn_sick_$animalId';
      if (resolvedIds.contains(alertId)) continue;
      final animal = await (db.select(db.localAnimals)..where((t) => t.id.equals(animalId))).getSingleOrNull();
      if (animal != null && animal.status != 'deceased') {
        dynamicAlerts.add(LocalAlert(
          id: alertId,
          title: 'Sick Animal - Medical Report',
          severity: 'warning',
          message: 'Medical report logged for ${animal.tagId} (${animal.species}). Follow-up required.',
          createdAt: now,
          isResolved: false,
          location: animal.locationId,
          impact: 'Medium',
        ));
      }
    }

    // 5. User-reported Farm Events generating active alerts
    final eventsList = await db.select(db.localFarmEvents).get();
    for (var ev in eventsList) {
      Map<String, dynamic>? meta;
      if (ev.description.startsWith('{')) {
        try {
          meta = jsonDecode(ev.description);
        } catch (_) {}
      }
      
      final severity = (meta != null ? meta['severity']?.toString() : null) ?? 'insight';
      if (severity == 'critical' || severity == 'warning') {
        final alertId = 'dyn_event_${ev.id}';
        if (resolvedIds.contains(alertId)) continue;
        
        final descText = meta != null ? meta['description']?.toString() : ev.description;
        final actionText = meta != null ? meta['action_required_details']?.toString() : null;
        
        final displayMessage = actionText != null 
            ? '$descText\nRequired Action: $actionText' 
            : descText ?? '';

        dynamicAlerts.add(LocalAlert(
          id: alertId,
          title: 'Farm Event: ${ev.eventType.replaceAll('_', ' ').toUpperCase()}',
          severity: severity,
          message: displayMessage,
          createdAt: ev.eventDate,
          isResolved: false,
          location: ev.involvedAnimals,
          impact: severity == 'critical' ? 'High' : 'Medium',
        ));
      }
    }

    return dynamicAlerts;
  }

  Future<void> _syncAlerts(List<dynamic> remoteData) async {
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(
          db.localAlerts,
          remoteData.map((item) => LocalAlertsCompanion.insert(
            id: item['id'],
            title: item['title'],
            severity: item['severity'],
            message: item['message'],
            location: Value(item['location']),
            impact: Value(item['impact']),
            createdAt: DateTime.parse(item['created_at']),
            isResolved: Value(item['is_resolved'] ?? false),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> resolveAlert(String id) async {
    final isDynamic = id.startsWith('dyn_');
    
    if (isDynamic) {
      await db.into(db.localAlerts).insertOnConflictUpdate(LocalAlertsCompanion.insert(
        id: id,
        title: 'Resolved Dynamic Alert',
        severity: 'info',
        message: 'Dynamic alert resolved',
        createdAt: DateTime.now(),
        isResolved: const Value(true),
      ));
      return;
    }

    try {
      await apiClient.dio.patch('/alerts/$id/resolve');
      
      // On success, update locally
      await (db.update(db.localAlerts)..where((t) => t.id.equals(id))).write(
        const LocalAlertsCompanion(isResolved: Value(true))
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.update(db.localAlerts)..where((t) => t.id.equals(id))).write(
          const LocalAlertsCompanion(isResolved: Value(true))
        );

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/alerts/$id/resolve',
          method: 'PATCH',
          body: '{}',
          queuedAt: DateTime.now(),
        ));
        return;
      }
      rethrow;
    }
  }
}
