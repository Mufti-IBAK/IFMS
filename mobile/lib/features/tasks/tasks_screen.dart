import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'tasks_bloc.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFMS WORK ORDERS'),
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksLoaded) {
            return Column(
              children: [
                _buildTaskFilters(),
                if (state.isOffline)
                  Container(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Offline Mode - Local Modifications Cached',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.tasks.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      final taskId = task is Map ? task['id'] : task.id;
                      final title = task is Map ? task['title'] : task.title;
                      final description = (task is Map ? task['description'] : task.description) ?? '';
                      final status = task is Map ? task['status'] : task.status;
                      final priority = task is Map ? task['priority'] : task.priority;
                      
                      final isCompleted = status.toString() == 'completed';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          value: isCompleted,
                          activeColor: AppColors.primary,
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (description.isNotEmpty) 
                                Text(description, style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _priorityChip(priority.toString()),
                                  const SizedBox(width: 8),
                                  const Text('Due: Today', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          onChanged: (val) {
                            final nextStatus = val == true ? 'completed' : 'in_progress';
                            BlocProvider.of<TasksBloc>(context).add(UpdateTaskStatus(taskId, nextStatus));
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is TasksError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No tasks assigned today.'));
        },
      ),
    );
  }

  Widget _buildTaskFilters() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _TaskStatCard(label: 'Assigned', count: '12', color: Colors.blue)),
          SizedBox(width: 12),
          Expanded(child: _TaskStatCard(label: 'Critical', count: '3', color: AppColors.error)),
          SizedBox(width: 12),
          Expanded(child: _TaskStatCard(label: 'Finished', count: '7', color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _priorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'urgent': color = AppColors.error; break;
      case 'high': color = Colors.orange; break;
      case 'medium': color = Colors.blue; break;
      default: color = AppColors.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _TaskStatCard extends StatelessWidget {
  final String label;
  final String count;
  final Color color;

  const _TaskStatCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
