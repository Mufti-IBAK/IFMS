import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tasks_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';
import '../../core/sync/sync_event_bus.dart';

// EVENTS
abstract class TasksEvent {}
class LoadTasks extends TasksEvent {}
class UpdateTaskStatus extends TasksEvent {
  final String taskId;
  final String status;
  UpdateTaskStatus(this.taskId, this.status);
}
class CreateTask extends TasksEvent {
  final Map<String, dynamic> taskData;
  final bool isPublic;
  CreateTask(this.taskData, {required this.isPublic});
}

// STATES
abstract class TasksState {}
class TasksLoading extends TasksState {}
class TasksLoaded extends TasksState {
  final List<dynamic> tasks;
  final bool isOffline;
  TasksLoaded(this.tasks, {this.isOffline = false});
}
class TasksError extends TasksState {
  final String message;
  TasksError(this.message);
}

// BLOC
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksRepository repository;
  StreamSubscription<SyncCompletedEvent>? _syncSubscription;

  TasksBloc(this.repository) : super(TasksLoading()) {
    _syncSubscription = SyncEventBus().stream.listen((event) {
      if (event.containsAny(['tasks'])) {
        add(LoadTasks());
      }
    });

    on<LoadTasks>((event, emit) async {
      final currentState = state;
      if (currentState is! TasksLoaded) {
        emit(TasksLoading());
      }
      try {
        final tasks = await repository.getTasks();
        
        // Re-schedule daily notifications based on the latest local task list
        sl<NotificationService>().scheduleDailyTaskSummaries(tasks);
        
        emit(TasksLoaded(tasks));
      } catch (e) {
        if (currentState is! TasksLoaded) {
          emit(TasksError('Failed to load tasks: ${e.toString()}'));
        }
      }
    });

    on<UpdateTaskStatus>((event, emit) async {
      try {
        await repository.updateTaskStatus(event.taskId, event.status);
        add(LoadTasks());
      } catch (e) {
        emit(TasksError(e.toString().replaceAll('Exception:', '').trim()));
        add(LoadTasks());
      }
    });

    on<CreateTask>((event, emit) async {
      try {
        await repository.createTask(event.taskData, isPublic: event.isPublic);
        sl<NotificationService>().showLocalNotification(
          'New Farm Task',
          'Task "${event.taskData['title']}" successfully added.',
        );
        add(LoadTasks());
      } catch (e) {
        emit(TasksError(e.toString().replaceAll('Exception:', '').trim()));
        add(LoadTasks());
      }
    });
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
  }
}

