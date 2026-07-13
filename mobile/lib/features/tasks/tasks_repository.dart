import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class TasksRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  TasksRepository(this.apiClient, this.db);

  Future<List<LocalTask>> getTasks() async {
    try {
      final response = await apiClient.dio.get('/tasks');
      final list = response.data as List;
      await _updateLocalCache(list);
    } catch (_) {}
    try {
      await autoGenerateTasks();
    } catch (_) {}
    return await (db.select(db.localTasks)
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc)]))
        .get();
  }

  Future<void> autoGenerateTasks() async {
    // 1. Scan hatchery batches
    try {
      final batches = await db.select(db.localHatcheryBatches).get();
      for (var batch in batches) {
        DateTime? transferDate;
        DateTime? hatchDate;
        try {
          if (batch.breed.startsWith('{')) {
            final meta = jsonDecode(batch.breed);
            if (meta['transfer_date'] != null) {
              transferDate = DateTime.parse(meta['transfer_date']);
            }
            if (meta['expected_hatch_date'] != null) {
              hatchDate = DateTime.parse(meta['expected_hatch_date']);
            }
          }
        } catch (_) {}
        
        if (transferDate == null || hatchDate == null) {
          final placementDate = batch.startDate;
          transferDate = placementDate.add(const Duration(days: 18));
          hatchDate = placementDate.add(const Duration(days: 21));
        }

        if (batch.status == 'active') {
          final transferTaskId = 'auto_hatchery_transfer_${batch.id}';
          final transferExists = await (db.select(db.localTasks)..where((t) => t.id.equals(transferTaskId))).getSingleOrNull();
          if (transferExists == null) {
            await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
              id: transferTaskId,
              title: 'Transfer Batch #${batch.batchNumber} to Hatchery',
              description: const Value('Move eggs from incubator to hatchery compartment.'),
              priority: 'high',
              status: 'pending',
              category: const Value('other'),
              dueDate: Value(transferDate),
              assignedTo: const Value('personal'),
              isActionable: const Value(true),
            ));
          }

          final hatchTaskId = 'auto_hatchery_hatch_${batch.id}';
          final hatchExists = await (db.select(db.localTasks)..where((t) => t.id.equals(hatchTaskId))).getSingleOrNull();
          if (hatchExists == null) {
            await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
              id: hatchTaskId,
              title: 'Hatch / Chick Collection for Batch #${batch.batchNumber}',
              description: const Value('Expected hatch date. Collect chicks and record hatchery results.'),
              priority: 'urgent',
              status: 'pending',
              category: const Value('other'),
              dueDate: Value(hatchDate),
              assignedTo: const Value('personal'),
              isActionable: const Value(true),
            ));
          }
        }
      }
    } catch (_) {}

    // 2. Scan low stock items
    try {
      final feedItems = await db.select(db.localFeedItems).get();
      for (var item in feedItems) {
        if (item.currentStock <= item.reorderThreshold && item.isActive) {
          final reorderTaskId = 'auto_reorder_${item.id}';
          final reorderExists = await (db.select(db.localTasks)..where((t) => t.id.equals(reorderTaskId))).getSingleOrNull();
          if (reorderExists == null) {
            await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
              id: reorderTaskId,
              title: 'Reorder Item: ${item.name}',
              description: Value('Stock level (${item.currentStock} ${item.unit}) is below reorder threshold (${item.reorderThreshold} ${item.unit}).'),
              priority: 'medium',
              status: 'pending',
              category: const Value('feed'),
              dueDate: Value(DateTime.now()),
              assignedTo: const Value('personal'),
              isActionable: const Value(true),
            ));
          }
        }
      }
    } catch (_) {}

    // 3. Scan medical and deworming schedules of animals
    try {
      final animals = await db.select(db.localAnimals).get();
      for (var animal in animals) {
        if (animal.vaccinationStatus != null && animal.vaccinationStatus!.isNotEmpty) {
          try {
            final vac = jsonDecode(animal.vaccinationStatus!);
            if (vac['next_date'] != null && vac['next_date'].toString().isNotEmpty) {
              final nextVacDate = DateTime.parse(vac['next_date'].toString());
              final vacName = vac['next_vaccine'] ?? 'Scheduled Vaccine';
              final vacTaskId = 'auto_vac_${animal.id}_${nextVacDate.toIso8601String().split('T')[0]}';
              final vacExists = await (db.select(db.localTasks)..where((t) => t.id.equals(vacTaskId))).getSingleOrNull();
              if (vacExists == null) {
                await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
                  id: vacTaskId,
                  title: 'Administer $vacName to Animal #${animal.tagId}',
                  description: const Value('Scheduled vaccination due.'),
                  priority: 'high',
                  status: 'pending',
                  category: const Value('medical_record'),
                  dueDate: Value(nextVacDate),
                  assignedTo: const Value('personal'),
                  isActionable: const Value(true),
                ));
              }
            }
          } catch (_) {}
        }
        
        if (animal.dewormingStatus != null && animal.dewormingStatus!.isNotEmpty) {
          try {
            final dw = jsonDecode(animal.dewormingStatus!);
            if (dw['next_date'] != null && dw['next_date'].toString().isNotEmpty) {
              final nextDwDate = DateTime.parse(dw['next_date'].toString());
              final drug = dw['drug'] ?? 'Dewormer';
              final dwTaskId = 'auto_dw_${animal.id}_${nextDwDate.toIso8601String().split('T')[0]}';
              final dwExists = await (db.select(db.localTasks)..where((t) => t.id.equals(dwTaskId))).getSingleOrNull();
              if (dwExists == null) {
                await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
                  id: dwTaskId,
                  title: 'Administer Dewormer ($drug) to Animal #${animal.tagId}',
                  description: const Value('Scheduled deworming treatment due.'),
                  priority: 'high',
                  status: 'pending',
                  category: const Value('medical_record'),
                  dueDate: Value(nextDwDate),
                  assignedTo: const Value('personal'),
                  isActionable: const Value(true),
                ));
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
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

  Future<void> createTask(Map<String, dynamic> taskData, {required bool isPublic}) async {
    final companion = LocalTasksCompanion.insert(
      id: taskData['id'],
      title: taskData['title'],
      priority: taskData['priority'] ?? 'medium',
      status: taskData['status'] ?? 'pending',
      description: Value(taskData['description']),
      dueDate: taskData['due_date'] != null ? Value(DateTime.parse(taskData['due_date'])) : const Value.absent(),
      assignedTo: Value(isPublic ? 'public' : 'personal'),
      category: Value(taskData['category'] ?? 'other'),
    );

    // Save to local database
    await db.into(db.localTasks).insertOnConflictUpdate(companion);

    if (isPublic) {
      try {
        await apiClient.dio.post('/tasks', data: {
          'id': taskData['id'],
          'title': taskData['title'],
          'description': taskData['description'],
          'priority': taskData['priority'] ?? 'medium',
          'status': taskData['status'] ?? 'pending',
          'due_date': taskData['due_date'],
          'category': taskData['category'] ?? 'other',
        });
      } catch (e) {
        // Queue synchronization
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/tasks',
          method: 'POST',
          body: jsonEncode({
            'id': taskData['id'],
            'title': taskData['title'],
            'description': taskData['description'],
            'priority': taskData['priority'] ?? 'medium',
            'status': taskData['status'] ?? 'pending',
            'due_date': taskData['due_date'],
            'category': taskData['category'] ?? 'other',
          }),
          queuedAt: DateTime.now(),
        ));
      }
    }
  }

  Future<void> _updateLocalCache(List<dynamic> tasks) async {
    await db.transaction(() async {
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
