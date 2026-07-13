import 'package:drift/drift.dart';
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
    
    final dbAlerts = await (db.select(db.localAlerts)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();
    final dynamicAlerts = await _generateDynamicAlerts();
    
    final allAlerts = [...dynamicAlerts, ...dbAlerts];
    // Sort combined by date descending
    allAlerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allAlerts;
  }

  Future<List<LocalAlert>> _generateDynamicAlerts() async {
    final List<LocalAlert> dynamicAlerts = [];
    final now = DateTime.now();

    // 1. Low Inventory (Feed)
    final lowFeed = await (db.select(db.localFeedItems)..where((t) => t.currentStock.isSmallerOrEqual(t.reorderThreshold) & t.isActive.equals(true))).get();
    for (var item in lowFeed) {
      dynamicAlerts.add(LocalAlert(
        id: 'dyn_feed_${item.id}',
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
      dynamicAlerts.add(LocalAlert(
        id: 'dyn_med_${item.id}',
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
      dynamicAlerts.add(LocalAlert(
        id: 'dyn_mort_${animal.id}',
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
      final animal = await (db.select(db.localAnimals)..where((t) => t.id.equals(animalId))).getSingleOrNull();
      if (animal != null && animal.status != 'deceased') {
        dynamicAlerts.add(LocalAlert(
          id: 'dyn_sick_$animalId',
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
}
