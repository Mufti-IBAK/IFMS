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
    return await (db.select(db.localAlerts)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();
  }

  Future<void> _syncAlerts(List<dynamic> remoteData) async {
    await db.delete(db.localAlerts).go();
    for (var item in remoteData) {
      await db.into(db.localAlerts).insertOnConflictUpdate(LocalAlertsCompanion.insert(
        id: item['id'],
        title: item['title'],
        severity: item['severity'],
        message: item['message'],
        location: Value(item['location']),
        impact: Value(item['impact']),
        createdAt: DateTime.parse(item['created_at']),
        isResolved: Value(item['is_resolved'] ?? false),
      ));
    }
  }
}
