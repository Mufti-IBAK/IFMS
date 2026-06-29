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
      return await db.select(db.localTasks).get();
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
    await db.delete(db.localTasks).go();
    for (var task in tasks) {
      await db.into(db.localTasks).insertOnConflictUpdate(LocalTasksCompanion.insert(
        id: task['id'],
        title: task['title'],
        priority: task['priority'],
        status: task['status'],
        description: Value(task['description']),
      ));
    }
  }
}
