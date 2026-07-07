import 'package:flutter_bloc/flutter_bloc.dart';
import 'tasks_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';

// EVENTS
abstract class TasksEvent {}
class LoadTasks extends TasksEvent {}
class UpdateTaskStatus extends TasksEvent {
  final String taskId;
  final String status;
  UpdateTaskStatus(this.taskId, this.status);
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

  TasksBloc(this.repository) : super(TasksLoading()) {
    on<LoadTasks>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await repository.getTasks();
        
        // Re-schedule daily notifications based on the latest local task list
        sl<NotificationService>().scheduleDailyTaskSummaries(tasks);
        
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError('Failed to load tasks: ${e.toString()}'));
      }
    });

    on<UpdateTaskStatus>((event, emit) async {
      try {
        await repository.updateTaskStatus(event.taskId, event.status);
        add(LoadTasks());
      } catch (e) {
        emit(TasksError('Failed to update task: ${e.toString()}'));
      }
    });
  }
}
