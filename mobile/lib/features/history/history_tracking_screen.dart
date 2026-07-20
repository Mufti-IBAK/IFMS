import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/theme/app_colors.dart';

class HistoryTrackingScreen extends StatefulWidget {
  const HistoryTrackingScreen({Key? key}) : super(key: key);

  @override
  State<HistoryTrackingScreen> createState() => _HistoryTrackingScreenState();
}

class _HistoryTrackingScreenState extends State<HistoryTrackingScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;

  String _selectedModule = 'All';
  String _selectedAction = 'All';

  final List<String> _modules = [
    'All', 'Animals', 'Poultry', 'Hatchery', 'Finance', 'Staff', 'Inventory', 'Pharmacy'
  ];
  final List<String> _actions = ['All', 'CREATE', 'UPDATE', 'DELETE'];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final moduleFilter = _selectedModule == 'All' ? null : _selectedModule.toLowerCase();
      final actionFilter = _selectedAction == 'All' ? null : _selectedAction;

      final logs = await sl<AuditRepository>().getAuditLogs(
        moduleFilter: moduleFilter,
        actionFilter: actionFilter,
      );
      
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredLogs {
    return _logs.where((log) {
      final matchModule = _selectedModule == 'All' || log.moduleName.toLowerCase() == _selectedModule.toLowerCase();
      final matchAction = _selectedAction == 'All' || log.actionType.toUpperCase() == _selectedAction.toUpperCase();
      return matchModule && matchAction;
    }).toList();
  }

  IconData _getModuleIcon(String module) {
    switch (module.toLowerCase()) {
      case 'animals': return Icons.agriculture;
      case 'poultry': return Icons.egg;
      case 'hatchery': return Icons.bubble_chart;
      case 'finance': return Icons.account_balance_wallet;
      case 'staff': return Icons.groups;
      case 'inventory': return Icons.storage;
      case 'pharmacy': return Icons.local_pharmacy;
      default: return Icons.dashboard;
    }
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE': return Colors.green;
      case 'UPDATE': return Colors.amber;
      case 'DELETE': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'Just now';
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _actions.map((action) {
                final isSelected = _selectedAction == action;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(action, style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    )),
                    backgroundColor: Colors.white,
                    selectedColor: _getActionColor(action == 'All' ? 'CREATE' : action).withValues(alpha: 0.8),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.transparent : AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    onSelected: (val) {
                      setState(() => _selectedAction = action);
                      _loadLogs();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _modules.map((module) {
                final isSelected = _selectedModule == module;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (module != 'All') ...[
                          Icon(_getModuleIcon(module), size: 14, color: isSelected ? Colors.white : Colors.grey[700]),
                          const SizedBox(width: 4),
                        ],
                        Text(module, style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontSize: 12,
                        )),
                      ],
                    ),
                    backgroundColor: Colors.grey[100],
                    selectedColor: AppColors.secondary,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
                    ),
                    onSelected: (val) {
                      setState(() => _selectedModule = module);
                      _loadLogs();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(dynamic log, bool isFirst, bool isLast) {
    final actionColor = _getActionColor(log.actionType);
    final moduleIcon = _getModuleIcon(log.moduleName);
    
    Map<String, dynamic> details = {};
    if (log.detailsJson != null && log.detailsJson!.isNotEmpty) {
      try {
        details = json.decode(log.detailsJson!);
      } catch (_) {}
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Rail
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : Colors.grey[300],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: actionColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: actionColor.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0, top: 4.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                color: Colors.white,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: actionColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.actionType.toUpperCase(),
                                style: TextStyle(color: actionColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(moduleIcon, size: 10, color: Colors.grey[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.moduleName.toUpperCase(),
                                    style: TextStyle(color: Colors.grey[700], fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _getTimeAgo(log.timestamp),
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          log.description,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (log.entityName != null && log.entityName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            log.entityName!,
                            style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            log.userName,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    children: details.isNotEmpty
                        ? [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: details.entries.map((e) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${e.key}: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            e.value.toString(),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          ]
                        : [],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FARM ACTIVITY TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadLogs,
                    color: AppColors.primary,
                    child: filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history, size: 80, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No activity recorded yet',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Activities will appear here when actions are taken in the system.',
                                      style: TextStyle(color: Colors.grey[500]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 16, bottom: 32),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _buildTimelineItem(
                                filtered[index],
                                index == 0,
                                index == filtered.length - 1,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
