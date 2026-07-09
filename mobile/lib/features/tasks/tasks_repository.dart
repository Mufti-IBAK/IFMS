import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class TasksRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  TasksRepository(this.apiClient, this.db);

  Future<List<dynamic>> getTasks() async {
    try {
      final response = await apiClient.dio.get('/tasks');
      final list = response.data as List;
      _updateLocalCache(list);
      return list;
    } catch (e) {
      return await (db.select(db.localTasks)
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc)]))
          .get();
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await apiClient.dio.patch('/tasks/$taskId/status', data: {'status': status});
    } catch (e) {
      // Local cache update
      await (db.update(db.localTasks)..where((t) => t.id.equals(taskId))).write(
        LocalTasksCompanion(status: Value(status))
      );
      
      // Queue sync
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/tasks/$taskId/status',
        method: 'PATCH',
        body: jsonEncode({'status': status}),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _updateLocalCache(List<dynamic> tasks) async {
    await db.transaction(() async {
      final syncItems = await (db.select(db.syncQueue)
            ..where((t) => t.endpoint.equals('/tasks') & t.method.equals('POST')))
          .get();
      final pendingIds = syncItems.map((item) {
        try {
          final data = jsonDecode(item.body);
          return data['id'] as String?;
        } catch (_) {
          return null;
        }
      }).whereType<String>().toList();

      final serverIds = tasks.map((t) => t['id'] as String).toList();
      final excludeIds = [...serverIds, ...pendingIds];

      if (excludeIds.isNotEmpty) {
        await (db.delete(db.localTasks)..where((t) => t.id.isNotIn(excludeIds))).go();
      } else {
        await db.delete(db.localTasks).go();
      }

      await db.batch((batch) {
        batch.insertAll(
          db.localTasks,
          tasks.map((task) => LocalTasksCompanion.insert(
            id: task['id'],
            title: task['title'],
            priority: task['priority'],
            status: task['status'],
            description: Value(task['description']),
            dueDate: task['due_date'] != null ? Value(DateTime.parse(task['due_date'])) : const Value.absent(),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }
}
