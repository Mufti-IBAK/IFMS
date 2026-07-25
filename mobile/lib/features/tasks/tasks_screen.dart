import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/task_pdf_export_service.dart';
import 'tasks_bloc.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filterScope = 'current_month'; // 'current_month', 'selected_month', 'all_time'
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    // Load tasks on entry
    BlocProvider.of<TasksBloc>(context).add(LoadTasks());
  }

  String get _scopeTitle {
    if (_filterScope == 'current_month') {
      return 'Current Month (${DateFormat('MMM yyyy').format(DateTime.now())})';
    } else if (_filterScope == 'selected_month') {
      return 'Archive: ${DateFormat('MMMM yyyy').format(_selectedMonth)}';
    } else {
      return 'All Time Database Archive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TASK & OPERATION LOGS'),
          actions: [
            // Export PDF Action
            BlocBuilder<TasksBloc, TasksState>(
              builder: (context, state) {
                if (state is TasksLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    tooltip: 'Export Task Log PDF',
                    onPressed: () {
                      final tasksToExport = _applyScopeFilter(state.tasks);
                      TaskPdfExportService.exportTasksPdf(
                        tasks: tasksToExport,
                        filterTitle: _scopeTitle,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Month / Archive Scope Selector
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_alt, color: Colors.white),
              tooltip: 'Monthly Clearing & Historical Archive',
              onSelected: (val) async {
                if (val == 'current_month' || val == 'all_time') {
                  setState(() => _filterScope = val);
                } else if (val == 'pick_month') {
                  _showMonthYearPicker(context);
                }
              },
              itemBuilder: (ctx) => [
                CheckedPopupMenuItem<String>(
                  value: 'current_month',
                  checked: _filterScope == 'current_month',
                  child: const Text('Current Month (Default Clean View)'),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'pick_month',
                  checked: _filterScope == 'selected_month',
                  child: Text('Retrieve Historical Month (${DateFormat('MMM yyyy').format(_selectedMonth)})...'),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'all_time',
                  checked: _filterScope == 'all_time',
                  child: const Text('All Time Database Archive'),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'TODAY'),
              Tab(text: 'UPCOMING'),
              Tab(text: 'COMPLETED'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: BlocConsumer<TasksBloc, TasksState>(
          listener: (context, state) {
            if (state is TasksError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TasksLoaded) {
              final scopedTasks = _applyScopeFilter(state.tasks);
              
              // Categorize tasks for the tabs
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              
              final List<dynamic> todayTasks = [];
              final List<dynamic> upcomingTasks = [];
              final List<dynamic> completedTasks = [];
              
              int personalCount = 0;
              int publicCount = 0;
              int totalPending = 0;

              for (var task in scopedTasks) {
                final status = task is Map ? task['status'] : task.status;
                final assignedTo = task is Map ? task['assignedTo'] : task.assignedTo;
                
                if (status == 'pending') {
                  totalPending++;
                  if (assignedTo == 'personal') personalCount++;
                  if (assignedTo == 'public') publicCount++;
                }

                if (status == 'completed') {
                  completedTasks.add(task);
                  continue;
                }
                
                DateTime? dueDate;
                if (task is Map && task['due_date'] != null) {
                  dueDate = DateTime.tryParse(task['due_date']);
                } else if (task.dueDate != null) {
                  dueDate = task.dueDate;
                }

                if (dueDate == null) {
                  upcomingTasks.add(task);
                } else {
                  final taskDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
                  if (taskDay.isAtSameMomentAs(today) || taskDay.isBefore(today)) {
                    todayTasks.add(task);
                  } else {
                    upcomingTasks.add(task);
                  }
                }
              }

              return Column(
                children: [
                  // Active Scope Filter Header Banner
                  Container(
                    width: double.infinity,
                    color: Colors.teal.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.filter_list, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Scope: $_scopeTitle', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        if (_filterScope != 'current_month')
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            onPressed: () => setState(() => _filterScope = 'current_month'),
                            child: const Text('Reset to Current Month', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),

                  _buildStatsBanner(totalPending, personalCount, publicCount),
                  if (state.isOffline)
                    Container(
                      color: Colors.orange.shade100,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      child: const Text(
                        'Offline Mode - Showing Local Data',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTaskTabList(todayTasks, 'No tasks scheduled for today.'),
                        _buildTaskTabList(upcomingTasks, 'No upcoming tasks.'),
                        _buildTaskTabList(completedTasks, 'No completed tasks yet.'),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is TasksError) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('No farm tasks found.'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTaskSheet(context),
          label: const Text('Add Task'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatsBanner(int pending, int personal, int public) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBox('Pending', pending.toString(), AppColors.primary),
          _statBox('Personal', personal.toString(), Colors.blue),
          _statBox('Public (Team)', public.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTaskTabList(List<dynamic> tasks, String emptyMsg) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(emptyMsg, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final taskId = task is Map ? task['id'] : task.id;
        final title = task is Map ? task['title'] : task.title;
        final description = (task is Map ? task['description'] : task.description) ?? '';
        final status = task is Map ? task['status'] : task.status;
        final priority = task is Map ? task['priority'] : task.priority;
        final category = (task is Map ? task['category'] : task.category) ?? 'other';
        final visibility = task is Map ? task['assigned_to'] : task.assignedTo;
        final isActionable = task is Map ? (task['is_actionable'] ?? task['isActionable'] ?? true) : ((task as dynamic).isActionable ?? true);
        
        final isCompleted = status.toString() == 'completed';
        final isPersonal = visibility == 'personal';

        final dueDateRaw = task is Map ? task['due_date'] ?? task['dueDate'] : task.dueDate;
        String formattedDate = 'No date';
        if (dueDateRaw != null) {
          DateTime dt = dueDateRaw is DateTime ? dueDateRaw : DateTime.parse(dueDateRaw.toString());
          formattedDate = DateFormat('MMM dd, yyyy').format(dt);
        }

        IconData categoryIcon;
        Color categoryColor;
        switch (category.toString()) {
          case 'medical_record':
            categoryIcon = Icons.medical_services_outlined;
            categoryColor = Colors.red;
            break;
          case 'pharmacy':
            categoryIcon = Icons.local_pharmacy_outlined;
            categoryColor = Colors.orange;
            break;
          case 'feed':
            categoryIcon = Icons.rice_bowl_outlined;
            categoryColor = Colors.brown;
            break;
          default:
            categoryIcon = Icons.assignment_outlined;
            categoryColor = Colors.blue;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          color: isCompleted ? Colors.grey.shade50 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isActionable)
                  Checkbox(
                    value: isCompleted,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      final nextStatus = val == true ? 'completed' : 'in_progress';
                      BlocProvider.of<TasksBloc>(context).add(UpdateTaskStatus(taskId, nextStatus));
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.info_outline, color: categoryColor, size: 20),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey.shade600 : Colors.black,
                              ),
                            ),
                          ),
                          _priorityBadge(priority.toString()),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isCompleted ? Colors.grey.shade500 : Colors.black87,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(categoryIcon, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            category.toString().toUpperCase().replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const Spacer(),
                          _visibilityBadge(isPersonal),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _priorityBadge(String priority) {
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _visibilityBadge(bool isPersonal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPersonal ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPersonal ? 'PERSONAL' : 'PUBLIC',
        style: TextStyle(
          fontSize: 9, 
          color: isPersonal ? Colors.blue : Colors.green, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    String selectedPriority = 'medium';
    String selectedCategory = 'other';
    DateTime selectedDate = DateTime.now();
    bool isPublic = false; // default is client-side (personal)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) {
          final media = MediaQuery.of(context);

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: media.viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add Farm Task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title *',
                      prefixIcon: Icon(Icons.assignment),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPriority,
                          decoration: const InputDecoration(labelText: 'Priority'),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                          ],
                          onChanged: (val) => setState(() => selectedPriority = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: const [
                            DropdownMenuItem(value: 'medical_record', child: Text('Medical')),
                            DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy')),
                            DropdownMenuItem(value: 'feed', child: Text('Feed')),
                            DropdownMenuItem(value: 'other', child: Text('Other')),
                          ],
                          onChanged: (val) => setState(() => selectedCategory = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Change'),
                        onPressed: () async {
                          final picked = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Public vs Personal toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPublic ? Colors.green.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPublic ? Colors.green.shade200 : Colors.blue.shade200,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: SwitchListTile(
                        title: Text(
                          isPublic ? 'Public Task' : 'Personal Task',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPublic ? Colors.green.shade800 : Colors.blue.shade800,
                          ),
                        ),
                        subtitle: Text(
                          isPublic 
                              ? 'Visible to all farm members. Synced with the cloud server.' 
                              : 'Visible only on this device. Kept local.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPublic ? Colors.green.shade700 : Colors.blue.shade700,
                          ),
                        ),
                        value: isPublic,
                        onChanged: (val) {
                          setState(() => isPublic = val);
                        },
                        secondary: Icon(
                          isPublic ? Icons.cloud_upload : Icons.lock_outline,
                          color: isPublic ? Colors.green.shade700 : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task Title is required!')),
                              );
                              return;
                            }
                            
                            final taskId = const Uuid().v4();
                            final task = {
                              'id': taskId,
                              'title': titleController.text.trim(),
                              'description': descriptionController.text.trim().isNotEmpty 
                                  ? descriptionController.text.trim() 
                                  : null,
                              'priority': selectedPriority,
                              'status': 'pending',
                              'category': selectedCategory,
                              'due_date': selectedDate.toIso8601String().split('T')[0],
                            };

                            BlocProvider.of<TasksBloc>(context).add(
                              CreateTask(task, isPublic: isPublic),
                            );
                            Navigator.pop(sheetContext);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Create Task'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    int tempYear = _selectedMonth.year;
    int tempMonth = _selectedMonth.month;

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.calendar_month, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Historical Month Retrieval', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year Selector Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: tempYear > 2020
                            ? () => setDialogState(() => tempYear--)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$tempYear',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: tempYear < DateTime.now().year + 1
                            ? () => setDialogState(() => tempYear++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 12 Months Grid (3 columns x 4 rows)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 12,
                    itemBuilder: (mCtx, idx) {
                      final monthNum = idx + 1;
                      final isSelected = monthNum == tempMonth;
                      return ChoiceChip(
                        label: Text(
                          months[idx],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade100,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => tempMonth = monthNum);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(tempYear, tempMonth);
                      _filterScope = 'selected_month';
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Retrieve Tasks'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<dynamic> _applyScopeFilter(List<dynamic> tasks) {
    if (_filterScope == 'all_time') {
      return tasks;
    }

    final now = DateTime.now();
    final currentMonthYear = DateTime(now.year, now.month);

    return tasks.where((t) {
      // Extract task date (dueDate or completedAt)
      final dueDateRaw = t is Map ? t['due_date'] ?? t['dueDate'] : t.dueDate;
      final completedAtRaw = t is Map ? t['completed_at'] ?? t['completedAt'] : t.completedAt;

      DateTime? taskDate;
      if (dueDateRaw != null) {
        taskDate = dueDateRaw is DateTime ? dueDateRaw : DateTime.tryParse(dueDateRaw.toString());
      } else if (completedAtRaw != null) {
        taskDate = completedAtRaw is DateTime ? completedAtRaw : DateTime.tryParse(completedAtRaw.toString());
      }

      if (_filterScope == 'selected_month') {
        // STRICT HISTORICAL RETRIEVAL: Only show tasks matching selected month & year!
        if (taskDate == null) return false;
        return taskDate.year == _selectedMonth.year && taskDate.month == _selectedMonth.month;
      } else if (_filterScope == 'current_month') {
        // DEFAULT CLEAN VIEW:
        final status = (t is Map ? t['status'] : t.status)?.toString() ?? 'pending';
        // Active pending tasks stay visible on screen
        if (status != 'completed') return true;

        if (taskDate == null) return true;
        // Completed tasks only visible if completed/due in current month
        return taskDate.year == currentMonthYear.year && taskDate.month == currentMonthYear.month;
      }

      return true;
    }).toList();
  }
}
