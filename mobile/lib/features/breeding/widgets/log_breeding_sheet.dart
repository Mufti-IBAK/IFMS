import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../animals/animals_bloc.dart';
import '../breeding_bloc.dart';

class LogBreedingSheet extends StatefulWidget {
  const LogBreedingSheet({super.key});

  @override
  State<LogBreedingSheet> createState() => _LogBreedingSheetState();
}

class _LogBreedingSheetState extends State<LogBreedingSheet> {
  String _eventType = 'heat';
  String? _selectedAnimalId;
  String? _selectedSireId;
  String? _result;
  final _notesCtrl = TextEditingController();

  // Birth Details
  DateTime _birthDate = DateTime.now();
  TimeOfDay _birthTime = TimeOfDay.now();
  int _offspringCount = 1;
  String _offspringGender = 'mixed';
  String _healthStatus = 'healthy';
  String _motherStatus = 'normal';

  final List<String> _eventTypes = [
    'heat',
    'natural_mating',
    'ai',
    'pregnancy_check',
    'abortion',
    'birth',
    'estrus_synchronization'
  ];

  // Synchronization Details
  String _syncProtocol = 'ovsynch';
  DateTime _injectionDate = DateTime.now();
  DateTime _expectedEstrusDate = DateTime.now().add(const Duration(days: 3));
  String _estrusPeriod = 'morning';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return BlocListener<BreedingBloc, BreedingState>(
      listener: (context, state) {
        if (state is BreedingActionSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Breeding event logged successfully')));
          // Reload animals to update status
          context.read<AnimalsBloc>().add(LoadAnimals());
        } else if (state is BreedingError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Log Breeding Event', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Event Type Dropdown
            DropdownButtonFormField<String>(
              isExpanded: true,

              value: _eventType,
              decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
              items: _eventTypes.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
              onChanged: (v) => setState(() { _eventType = v!; _result = null; }),
            ),
            const SizedBox(height: 16),

            // Select Animal (Female)
            BlocBuilder<AnimalsBloc, AnimalsState>(
              builder: (context, state) {
                if (state is AnimalsLoaded) {
                  final females = state.animals.where((a) {
                    final isMap = a is Map;
                    final sex = (isMap ? a['sex'] : a.sex)?.toString().toLowerCase();
                    final status = ((isMap ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
                    return sex == 'female' && status != 'dead';
                  }).toList();

                  return DropdownButtonFormField<String>(
                    isExpanded: true,

                    value: _selectedAnimalId,
                    decoration: const InputDecoration(labelText: 'Select Female Animal', border: OutlineInputBorder()),
                    items: females.map((a) {
                      final id = (a is Map ? a['id'] : a.id).toString();
                      final tag = (a is Map ? a['tagId'] : a.tagId).toString();
                      return DropdownMenuItem(value: id, child: Text(tag, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedAnimalId = v),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 16),

            // Select Sire (If Mating or AI)
            if (_eventType == 'natural_mating' || _eventType == 'ai')
              BlocBuilder<AnimalsBloc, AnimalsState>(
                builder: (context, state) {
                  if (state is AnimalsLoaded) {
                    final males = state.animals.where((a) {
                      final isMap = a is Map;
                      final sex = (isMap ? a['sex'] : a.sex)?.toString().toLowerCase();
                      final status = ((isMap ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
                      return sex == 'male' && status != 'dead';
                    }).toList();

                    return DropdownButtonFormField<String>(
                      isExpanded: true,

                      value: _selectedSireId,
                      decoration: const InputDecoration(labelText: 'Select Sire (Optional)', border: OutlineInputBorder()),
                      items: males.map((a) {
                        final id = (a is Map ? a['id'] : a.id).toString();
                        final tag = (a is Map ? a['tagId'] : a.tagId).toString();
                        return DropdownMenuItem(value: id, child: Text(tag, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedSireId = v),
                    );
                  }
                  return const SizedBox();
                },
              ),
              
            if (_eventType == 'natural_mating' || _eventType == 'ai')
              const SizedBox(height: 16),

            // Pregnancy Check Result
            if (_eventType == 'pregnancy_check')
              DropdownButtonFormField<String>(
                isExpanded: true,

                value: _result,
                decoration: const InputDecoration(labelText: 'Result', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'pregnant', child: Text('Pregnant', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: 'open', child: Text('Open / Not Pregnant', overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _result = v),
              ),
              
            if (_eventType == 'pregnancy_check')
              const SizedBox(height: 16),

            if (_eventType == 'birth')
              ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final date = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
                            context: context,
                            initialDate: _birthDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => _birthDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Birth Date', border: OutlineInputBorder()),
                          child: Text(_birthDate.toIso8601String().split('T')[0]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _birthTime,
                          );
                          if (time != null) setState(() => _birthTime = time);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Birth Time', border: OutlineInputBorder()),
                          child: Text(_birthTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _offspringCount.toString(),
                        decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() => _offspringCount = int.tryParse(v) ?? 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,

                        value: _offspringGender,
                        decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'female', child: Text('Female', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'mixed', child: Text('Mixed', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setState(() => _offspringGender = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,

                        value: _healthStatus,
                        decoration: const InputDecoration(labelText: 'Health', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'healthy', child: Text('Healthy', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'weak', child: Text('Weak', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'stillborn', child: Text('Stillborn', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setState(() => _healthStatus = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,

                        value: _motherStatus,
                        decoration: const InputDecoration(labelText: 'Mother Status', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'normal', child: Text('Normal', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'assisted', child: Text('Assisted', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'dystocia', child: Text('Dystocia', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setState(() => _motherStatus = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

            if (_eventType == 'estrus_synchronization')
              ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,

                  value: _syncProtocol,
                  decoration: const InputDecoration(labelText: 'Synchronization Protocol', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'ovsynch', child: Text('Ovsynch', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'cosynch', child: Text('Cosynch', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'cidr', child: Text('CIDR', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'double_pg', child: Text('Double-PG', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) => setState(() => _syncProtocol = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
                            context: context,
                            initialDate: _injectionDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) setState(() => _injectionDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Injection Date', border: OutlineInputBorder()),
                          child: Text(_injectionDate.toIso8601String().split('T')[0]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
                            context: context,
                            initialDate: _expectedEstrusDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) setState(() => _expectedEstrusDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Expected Estrus', border: OutlineInputBorder()),
                          child: Text(_expectedEstrusDate.toIso8601String().split('T')[0]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,

                  value: _estrusPeriod,
                  decoration: const InputDecoration(labelText: 'Expected Estrus Period', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'morning', child: Text('Morning', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'evening', child: Text('Evening', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'all_day', child: Text('All Day', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) => setState(() => _estrusPeriod = v!),
                ),
                const SizedBox(height: 16),
              ],

            // Notes
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                if (_selectedAnimalId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select an animal')));
                  return;
                }
                if (_eventType == 'pregnancy_check' && _result == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a result')));
                  return;
                }
                String? payloadJson;
                if (_eventType == 'birth') {
                  payloadJson = jsonEncode({
                    'birthDate': _birthDate.toIso8601String(),
                    'birthTime': '${_birthTime.hour}:${_birthTime.minute}',
                    'offspringCount': _offspringCount,
                    'offspringGender': _offspringGender,
                    'healthStatus': _healthStatus,
                    'motherStatus': _motherStatus,
                  });
                }
                if (_eventType == 'estrus_synchronization') {
                  payloadJson = jsonEncode({
                    'protocol': _syncProtocol,
                    'injectionDate': _injectionDate.toIso8601String(),
                    'expectedEstrusDate': _expectedEstrusDate.toIso8601String(),
                    'estrusPeriod': _estrusPeriod,
                  });
                }

                context.read<BreedingBloc>().add(LogNewBreedingEvent(
                  animalId: _selectedAnimalId!,
                  eventType: _eventType,
                  eventDate: _eventType == 'birth' ? _birthDate : DateTime.now(),
                  sireId: _selectedSireId,
                  result: _result,
                  notes: _notesCtrl.text,
                  payload: payloadJson,
                ));
              },
              child: const Text('Log Breeding Event'),
            )
          ],
        ),
      ),
    );
  }
}
