import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'tasks_bloc.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showUpcoming = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NOTIFICATION CENTER'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'ALL'),
              Tab(text: 'MEDICAL'),
              Tab(text: 'PHARMACY'),
              Tab(text: 'FEED'),
              Tab(text: 'OTHER'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        body: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TasksLoaded) {
              int assignedCount = 0;
              int criticalCount = 0;
              int finishedCount = 0;

              // Compute global stats
              for (var task in state.tasks) {
                final status = task is Map ? task['status'] : task.status;
                final priority = task is Map ? task['priority'] : task.priority;
                
                if (status == 'completed') {
                  finishedCount++;
                } else {
                  assignedCount++;
                  if (priority == 'urgent' || priority == 'high') {
                    criticalCount++;
                  }
                }
              }

              return Column(
                children: [
                  _buildTaskFilters(assignedCount, criticalCount, finishedCount),
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
                    child: TabBarView(
                      children: [
                        _buildCategoryView(state.tasks, 'all'),
                        _buildCategoryView(state.tasks, 'medical_record'),
                        _buildCategoryView(state.tasks, 'pharmacy'),
                        _buildCategoryView(state.tasks, 'feed'),
                        _buildCategoryView(state.tasks, 'other'),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is TasksError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No updates available.'));
          },
        ),
      ),
    );
  }

  Widget _buildCategoryView(List<dynamic> allTasks, String categoryFilter) {
    Map<String, List<dynamic>> groupedTasks = {};
    
    // Filter and group
    for (var task in allTasks) {
      final category = task is Map ? task['category'] : (task as dynamic).category;
      
      if (categoryFilter != 'all') {
        if (categoryFilter == 'other') {
          if (category == 'medical_record' || category == 'pharmacy' || category == 'feed') {
            continue; // Skip known categories
          }
        } else {
          if (category != categoryFilter) {
            continue; // Skip if it doesn't match
          }
        }
      }

      final dueDateRaw = task is Map ? task['due_date'] ?? (task.containsKey('dueDate') ? task['dueDate'] : null) : (task as dynamic).dueDate;
      String group = 'Upcoming';
      if (dueDateRaw != null) {
          DateTime dt;
          if (dueDateRaw is DateTime) {
            dt = dueDateRaw;
          } else {
            dt = DateTime.parse(dueDateRaw.toString());
          }
          
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final taskDate = DateTime(dt.year, dt.month, dt.day);
          
          if (taskDate.isBefore(today)) {
            group = 'Overdue';
          } else if (taskDate.isAtSameMomentAs(today)) {
            group = 'Today';
          } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
            group = 'Tomorrow';
          } else {
            group = 'Upcoming';
          }
      } else {
          group = 'Today'; // Informational updates default to Today
      }
      
      groupedTasks.putIfAbsent(group, () => []).add(task);
    }

    final List<String> groupOrder;
    if (_showUpcoming) {
      groupOrder = ['Overdue', 'Today', 'Tomorrow', 'Upcoming'];
    } else {
      groupOrder = ['Overdue', 'Today'];
    }

    bool hasAnyTasks = false;
    for (var group in groupOrder) {
      if ((groupedTasks[group] ?? []).isNotEmpty) hasAnyTasks = true;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showUpcoming = !_showUpcoming;
                  });
                },
                icon: Icon(_showUpcoming ? Icons.visibility_off : Icons.visibility, size: 16),
                label: Text(_showUpcoming ? 'Hide Upcoming' : 'Show Upcoming Reminders'),
              )
            ],
          ),
        ),
        if (!hasAnyTasks)
          const Expanded(child: Center(child: Text('No updates for this period.')))
        else
          Expanded(
            child: ListView.builder(
              itemCount: groupOrder.length,
              itemBuilder: (context, sectionIndex) {
                final groupName = groupOrder[sectionIndex];
                final tasksInGroup = groupedTasks[groupName] ?? [];
                
                if (tasksInGroup.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        groupName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: groupName == 'Overdue' ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                    ...tasksInGroup.map((task) {
                      final taskId = task is Map ? task['id'] : task.id;
                      final title = task is Map ? task['title'] : task.title;
                      final description = (task is Map ? task['description'] : task.description) ?? '';
                      final status = task is Map ? task['status'] : task.status;
                      final priority = task is Map ? task['priority'] : task.priority;
                      final isActionable = task is Map ? (task['is_actionable'] ?? task['isActionable'] ?? true) : ((task as dynamic).isActionable ?? true);
                      
                      final isCompleted = status.toString() == 'completed';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: isActionable 
                            ? CheckboxListTile(
                                value: isCompleted,
                                activeColor: AppColors.primary,
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    color: isCompleted ? Colors.grey : Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (description.isNotEmpty) 
                                      Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isCompleted ? Colors.grey : null)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _priorityChip(priority.toString()),
                                      ],
                                    ),
                                  ],
                                ),
                                onChanged: (val) {
                                  final nextStatus = val == true ? 'completed' : 'in_progress';
                                  BlocProvider.of<TasksBloc>(context).add(UpdateTaskStatus(taskId, nextStatus));
                                },
                              )
                            : ListTile(
                                leading: Icon(Icons.info_outline, color: AppColors.primary),
                                title: Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTaskFilters(int assignedCount, int criticalCount, int finishedCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Assigned', assignedCount.toString(), Colors.blue),
          _statItem('Critical', criticalCount.toString(), AppColors.error),
          _statItem('Finished', finishedCount.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _priorityChip(String priority) {
    Color color;
    switch (priority) {
      case 'urgent':
        color = AppColors.error;
        break;
      case 'high':
        color = AppColors.warning;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
