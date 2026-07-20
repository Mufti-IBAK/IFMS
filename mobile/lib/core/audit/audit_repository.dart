import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../database/local_db.dart';
import '../network/api_client.dart';
import 'package:drift/drift.dart';

/// Centralized audit logging for all farm data mutations.
/// Records CREATE, UPDATE, DELETE actions across all modules
/// and syncs with Supabase for multi-user visibility.
class AuditRepository {
  final LocalDatabase db;
  final ApiClient apiClient;

  AuditRepository(this.db, this.apiClient);

  /// Log an action to the audit trail.
  /// [userName] - who performed the action (farm manager name)
  /// [actionType] - "CREATE", "UPDATE", or "DELETE"
  /// [moduleName] - "animals", "poultry", "hatchery", "finance", "staff", "inventory", "pharmacy"
  /// [entityId] - ID of the affected record (nullable)
  /// [entityName] - human-readable label e.g. tag ID, batch name
  /// [description] - summary of what happened
  /// [detailsJson] - optional JSON diff of old→new values
  Future<void> logAction({
    required String userName,
    required String actionType,
    required String moduleName,
    String? entityId,
    String? entityName,
    required String description,
    Map<String, dynamic>? details,
  }) async {
    final uuid = const Uuid().v4();
    final now = DateTime.now();

    final companion = LocalAuditLogsCompanion.insert(
      id: uuid,
      userName: userName,
      actionType: actionType,
      moduleName: moduleName,
      entityId: Value(entityId),
      entityLabel: Value(entityName),
      description: description,
      detailsJson: Value(details != null ? jsonEncode(details) : null),
      timestamp: Value(now),
    );

    // Always save locally first
    await db.into(db.localAuditLogs).insertOnConflictUpdate(companion);

    // Attempt remote sync (non-blocking)
    try {
      await apiClient.dio.post('/audit_logs', data: {
        'id': uuid,
        'user_name': userName,
        'action_type': actionType,
        'module_name': moduleName,
        'entity_id': entityId,
        'entity_name': entityName,
        'description': description,
        'details_json': details != null ? jsonEncode(details) : null,
        'timestamp': now.toIso8601String(),
      });
    } catch (_) {
      // Queue for later sync
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/audit_logs',
        method: 'POST',
        body: jsonEncode({
          'id': uuid,
          'user_name': userName,
          'action_type': actionType,
          'module_name': moduleName,
          'entity_id': entityId,
          'entity_name': entityName,
          'description': description,
          'details_json': details != null ? jsonEncode(details) : null,
          'timestamp': now.toIso8601String(),
        }),
        queuedAt: now,
      ));
    }
  }

  /// Get audit logs with optional filters and pagination.
  Future<List<LocalAuditLog>> getAuditLogs({
    int limit = 100,
    int offset = 0,
    String? moduleFilter,
    String? actionFilter,
  }) async {
    var query = db.select(db.localAuditLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(limit, offset: offset);

    if (moduleFilter != null && moduleFilter.isNotEmpty) {
      query = query..where((t) => t.moduleName.equals(moduleFilter));
    }
    if (actionFilter != null && actionFilter.isNotEmpty) {
      query = query..where((t) => t.actionType.equals(actionFilter));
    }

    return query.get();
  }

  /// Fetch audit logs from Supabase for multi-user sync.
  Future<List<Map<String, dynamic>>> fetchRemoteAuditLogs({int limit = 200}) async {
    try {
      final response = await apiClient.dio.get(
        '/audit_logs',
        queryParameters: {
          'order': 'timestamp.desc',
          'limit': limit,
        },
      );
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (_) {}
    return [];
  }

  /// Sync remote audit logs into local database.
  Future<void> syncFromRemote() async {
    final remoteLogs = await fetchRemoteAuditLogs();
    for (final log in remoteLogs) {
      final companion = LocalAuditLogsCompanion.insert(
        id: log['id'] ?? '',
        userName: log['user_name'] ?? 'Unknown',
        actionType: log['action_type'] ?? 'CREATE',
        moduleName: log['module_name'] ?? 'unknown',
        entityId: Value(log['entity_id']),
        entityLabel: Value(log['entity_name']),
        description: log['description'] ?? '',
        detailsJson: Value(log['details_json']),
        timestamp: Value(DateTime.tryParse(log['timestamp'] ?? '') ?? DateTime.now()),
      );
      await db.into(db.localAuditLogs).insertOnConflictUpdate(companion);
    }
  }
}
