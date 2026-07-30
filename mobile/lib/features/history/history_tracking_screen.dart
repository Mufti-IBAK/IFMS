import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/database/local_db.dart';
import '../../core/theme/app_colors.dart';

class HistoryTrackingScreen extends StatefulWidget {
  const HistoryTrackingScreen({Key? key}) : super(key: key);

  @override
  State<HistoryTrackingScreen> createState() => _HistoryTrackingScreenState();
}

class _HistoryTrackingScreenState extends State<HistoryTrackingScreen> {
  String _selectedModule = 'All';
  String _selectedAction = 'All';
  final TextEditingController _searchController = TextEditingController();

  Timer? _realtimeTimer;
  Map<String, String> _animalLabelMap = {}; // UUID -> "Species (#TagID)" e.g. "Cattle (#022)"
  Map<String, String> _medicationNames = {};
  Map<String, String> _feedNames = {};

  final List<String> _modules = [
    'All', 'Animals', 'Poultry', 'Hatchery', 'Finance', 'Staff', 'Inventory', 'Pharmacy'
  ];
  final List<String> _actions = ['All', 'CREATE', 'UPDATE', 'DELETE'];

  @override
  void initState() {
    super.initState();
    _loadEntityMaps();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<AuditRepository>().syncFromRemote();
    });

    // Real-time ticker: Polls cloud changes every 3 seconds while viewing screen
    _realtimeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        sl<AuditRepository>().syncFromRemote();
        _loadEntityMaps();
      }
    });
  }

  Future<void> _loadEntityMaps() async {
    try {
      final db = sl<LocalDatabase>();

      final animals = await db.select(db.localAnimals).get();
      final animalMap = <String, String>{};
      for (var a in animals) {
        final sp = a.species.isNotEmpty
            ? '${a.species[0].toUpperCase()}${a.species.substring(1).toLowerCase()}'
            : 'Animal';
        animalMap[a.id] = '$sp (#${a.tagId})';
      }

      final meds = await db.select(db.localMedications).get();
      final medMap = <String, String>{};
      for (var m in meds) {
        medMap[m.id] = m.name;
      }

      final feeds = await db.select(db.localFeedItems).get();
      final feedMap = <String, String>{};
      for (var f in feeds) {
        feedMap[f.id] = f.name;
      }

      if (mounted) {
        setState(() {
          _animalLabelMap = animalMap;
          _medicationNames = medMap;
          _feedNames = feedMap;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    _searchController.dispose();
    super.dispose();
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

  String _formatKeyName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  /// Resolves raw UUID strings or generic terms into "Species (#TagID)" e.g. "Cattle (#022)"
  String _resolveLabel(String? text, {dynamic entityId, Map<String, dynamic>? details, String? moduleName}) {
    if (text == null || text.isEmpty) return '';
    String result = text;

    // Extract species and tag from details map if present
    final String? detailSpecies = details != null && details['species'] != null && details['species'].toString().isNotEmpty
        ? '${details['species'].toString()[0].toUpperCase()}${details['species'].toString().substring(1).toLowerCase()}'
        : null;
    final String? detailTag = details != null
        ? (details['tag_id']?.toString() ?? details['tagId']?.toString() ?? details['tag']?.toString())
        : null;

    final String? detailsAnimalLabel = (detailTag != null && detailTag.isNotEmpty)
        ? '${detailSpecies ?? 'Animal'} (#$detailTag)'
        : null;

    // 1. If text is generic 'Animal Record' or bare UUID, attempt immediate resolution
    if (result == 'Animal Record' || result.startsWith('Animal ID ') || result.startsWith('Animal Tag #')) {
      if (entityId != null && _animalLabelMap.containsKey(entityId.toString())) {
        return _animalLabelMap[entityId.toString()]!;
      }
      if (detailsAnimalLabel != null) {
        return detailsAnimalLabel;
      }
    }

    // 2. Replace known animal UUIDs with "Species (#TagID)"
    _animalLabelMap.forEach((uuid, fullLabel) {
      if (result.contains(uuid)) {
        result = result.replaceAll(uuid, fullLabel);
      }
    });

    // 3. Replace known medication UUIDs with medication name
    _medicationNames.forEach((uuid, medName) {
      if (result.contains(uuid)) {
        result = result.replaceAll(uuid, medName);
      }
    });

    // 4. Replace known feed item UUIDs with feed item name
    _feedNames.forEach((uuid, feedName) {
      if (result.contains(uuid)) {
        result = result.replaceAll(uuid, feedName);
      }
    });

    // 5. Handle any remaining raw UUID strings
    final uuidRegex = RegExp(r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}');
    result = result.replaceAllMapped(uuidRegex, (match) {
      final id = match.group(0)!;
      if (_animalLabelMap.containsKey(id)) {
        return _animalLabelMap[id]!;
      }
      if (_medicationNames.containsKey(id)) {
        return _medicationNames[id]!;
      }
      if (_feedNames.containsKey(id)) {
        return _feedNames[id]!;
      }
      if (detailsAnimalLabel != null) {
        return detailsAnimalLabel;
      }
      if (moduleName?.toLowerCase() == 'animals') {
        return detailsAnimalLabel ?? (detailTag != null ? 'Animal (#$detailTag)' : 'Animal Record');
      }
      return 'Ref #${id.substring(0, 6)}';
    });

    // Cleanup redundant prefixes
    result = result
        .replaceAll('Animal ID Animal ', 'Animal ')
        .replaceAll('Animal ID ', '')
        .replaceAll('Animal Tag #', '');

    return result;
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search timeline by species, tag #, description, or user...',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Action & Module Dropdowns
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Action Type', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedAction,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                          items: _actions.map((action) {
                            return DropdownMenuItem<String>(
                              value: action,
                              child: Text(action, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedAction = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Module', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedModule,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                          items: _modules.map((module) {
                            return DropdownMenuItem<String>(
                              value: module,
                              child: Row(
                                children: [
                                  if (module != 'All') ...[
                                    Icon(_getModuleIcon(module), size: 14, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(module, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedModule = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

    final resolvedDesc = _resolveLabel(log.description, entityId: log.entityId, details: details, moduleName: log.moduleName);
    final resolvedEntity = _resolveLabel(log.entityLabel, entityId: log.entityId, details: details, moduleName: log.moduleName);

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
                          resolvedDesc,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (resolvedEntity.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            resolvedEntity,
                            style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
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
                                  final valStr = _resolveLabel(e.value.toString(), entityId: log.entityId, details: details, moduleName: log.moduleName);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_formatKeyName(e.key)}: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            valStr,
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('FARM ACTIVITY TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade700.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent, width: 0.8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Cloud Activity',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing activity logs from cloud...'), duration: Duration(seconds: 1)),
              );
              await sl<AuditRepository>().syncFromRemote();
              await _loadEntityMaps();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await sl<AuditRepository>().syncFromRemote();
                await _loadEntityMaps();
              },
              child: StreamBuilder<List<dynamic>>(
                stream: sl<AuditRepository>().watchAuditLogs(
                  moduleFilter: _selectedModule == 'All' ? null : _selectedModule,
                  actionFilter: _selectedAction == 'All' ? null : _selectedAction,
                  searchQuery: _searchController.text,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  final logs = snapshot.data ?? [];
                  
                  if (logs.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No activity recorded',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'No results match "${_searchController.text}".'
                                    : 'Activities will appear here when actions are taken in the system.',
                                style: TextStyle(color: Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16, bottom: 32),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return _buildTimelineItem(
                        logs[index],
                        index == 0,
                        index == logs.length - 1,
                      );
                    },
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
