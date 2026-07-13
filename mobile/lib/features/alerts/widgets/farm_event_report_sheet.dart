import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/database/local_db.dart';
import 'package:drift/drift.dart' as drift;

class FarmEventReportSheet extends StatefulWidget {
  const FarmEventReportSheet({super.key});

  @override
  State<FarmEventReportSheet> createState() => _FarmEventReportSheetState();
}

class _FarmEventReportSheetState extends State<FarmEventReportSheet> {
  final _formKey = GlobalKey<FormState>();
  String _eventType = 'mortality';
  final _descriptionCtrl = TextEditingController();
  
  List<LocalAnimal> _activeAnimals = [];
  final List<String> _selectedAnimalTags = [];

  @override
  void initState() {
    super.initState();
    _loadActiveAnimals();
  }

  Future<void> _loadActiveAnimals() async {
    final db = sl<LocalDatabase>();
    final active = await (db.select(db.localAnimals)..where((a) => a.status.equals('active'))).get();
    setState(() {
      _activeAnimals = active;
    });
  }

  Future<void> _showAnimalSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Involved Animals'),
              content: SizedBox(
                width: double.maxFinite,
                child: _activeAnimals.isEmpty
                    ? const Text('No active animals found.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _activeAnimals.length,
                        itemBuilder: (context, index) {
                          final animal = _activeAnimals[index];
                          final isSelected = _selectedAnimalTags.contains(animal.tagId);
                          return CheckboxListTile(
                            title: Text('${animal.tagId} (${animal.species})'),
                            value: isSelected,
                            onChanged: (bool? val) {
                              setDialogState(() {
                                if (val == true) {
                                  _selectedAnimalTags.add(animal.tagId);
                                } else {
                                  _selectedAnimalTags.remove(animal.tagId);
                                }
                              });
                              setState(() {}); // Update parent UI
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eventType != 'morning_report' && _selectedAnimalTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one involved animal.')),
      );
      return;
    }

    final db = sl<LocalDatabase>();
    final eventId = 'ev_${DateTime.now().millisecondsSinceEpoch}';
    final involvedAnimalsStr = _selectedAnimalTags.join(', ');

    await db.into(db.localFarmEvents).insert(LocalFarmEventsCompanion.insert(
      id: eventId,
      eventType: _eventType,
      eventDate: DateTime.now(),
      description: _descriptionCtrl.text,
      involvedAnimals: drift.Value(involvedAnimalsStr),
    ));

    // Update animal status to deceased if mortality
    if (_eventType == 'mortality') {
      for (var tag in _selectedAnimalTags) {
        await (db.update(db.localAnimals)..where((a) => a.tagId.equals(tag)))
            .write(const LocalAnimalsCompanion(status: drift.Value('deceased')));
      }
    }

    // Also queue for sync
    await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
      endpoint: '/farm-events',
      method: 'POST',
      body: '{"id": "$eventId", "type": "$_eventType", "description": "${_descriptionCtrl.text}", "animals": "$involvedAnimalsStr"}',
      queuedAt: DateTime.now(),
    ));

    // Schedule an informational task in the Notification Center
    final taskId = 'task_ev_$eventId';
    await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
      id: taskId,
      title: 'Farm Event Reported: ${_eventType.toUpperCase()}',
      description: drift.Value('${_descriptionCtrl.text} (Animals: $involvedAnimalsStr)'),
      priority: 'high',
      status: 'completed',
      dueDate: drift.Value(DateTime.now()),
      category: const drift.Value('other'),
      isActionable: const drift.Value(false),
    ));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm Event logged successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Report Farm Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                initialValue: _eventType,
                items: const [
                  DropdownMenuItem(value: 'morning_report', child: Text('Morning Report')),
                  DropdownMenuItem(value: 'mortality', child: Text('Mortality (Death)')),
                  DropdownMenuItem(value: 'birth', child: Text('Birth')),
                  DropdownMenuItem(value: 'disease_outbreak', child: Text('Disease Outbreak')),
                  DropdownMenuItem(value: 'equipment_failure', child: Text('Equipment Failure')),
                  DropdownMenuItem(value: 'general', child: Text('General Event')),
                ],
                onChanged: (v) => setState(() => _eventType = v!),
              ),
              const SizedBox(height: 16),
              
              if (_eventType != 'morning_report') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedAnimalTags.isEmpty
                              ? 'Select Involved Animals'
                              : _selectedAnimalTags.join(', '),
                          style: TextStyle(color: _selectedAnimalTags.isEmpty ? Colors.grey[600] : Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: _showAnimalSelectionDialog,
                        child: const Text('SELECT'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description',
                  border: OutlineInputBorder(),
                  hintText: 'Provide full details about what happened...',
                ),
                validator: (v) => v!.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  child: const Text('Save Report'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
