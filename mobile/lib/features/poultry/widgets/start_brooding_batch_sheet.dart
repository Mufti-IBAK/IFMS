import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../../../core/di/service_locator.dart';
import '../../../core/database/local_db.dart';
import '../../../core/theme/app_colors.dart';
import '../poultry_repository.dart';

class StartBroodingBatchSheet extends StatefulWidget {
  final String? initialHatcheryBatchId;
  final int? initialChickCount;
  final String? initialBreed;

  const StartBroodingBatchSheet({
    super.key,
    this.initialHatcheryBatchId,
    this.initialChickCount,
    this.initialBreed,
  });

  @override
  State<StartBroodingBatchSheet> createState() => _StartBroodingBatchSheetState();
}

class _StartBroodingBatchSheetState extends State<StartBroodingBatchSheet> {
  final _formKey = GlobalKey<FormState>();
  String _chickSource = 'hatchery_transfer'; // 'hatchery_transfer' or 'external_doc'

  List<LocalHatcheryBatche> _hatcheryBatches = [];
  LocalHatcheryBatche? _selectedHatcheryBatch;
  bool _loadingHatchery = true;

  final _batchNumCtrl = TextEditingController();
  final _penNameCtrl = TextEditingController();
  final _countCtrl = TextEditingController();
  final _costCtrl = TextEditingController(text: '0');
  final _breedCtrl = TextEditingController();
  final _initialTempCtrl = TextEditingController(text: '33.0');
  final _notesCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  int _broodingDays = 28; // 4 weeks default

  @override
  void initState() {
    super.initState();
    if (widget.initialChickCount != null) {
      _countCtrl.text = widget.initialChickCount.toString();
    }
    if (widget.initialBreed != null) {
      _breedCtrl.text = _parseBreedName(widget.initialBreed);
    }
    _loadHatcheryBatches();
  }

  String _parseBreedName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Chicks';
    if (raw.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['breed'] != null && decoded['breed'].toString().isNotEmpty) {
          return decoded['breed'].toString();
        }
      } catch (_) {}
    }
    return raw;
  }

  Future<void> _loadHatcheryBatches() async {
    final db = sl<LocalDatabase>();
    // First query completed hatchery batches
    var batches = await (db.select(db.localHatcheryBatches)
      ..where((t) => t.status.equals('completed'))
      ..orderBy([(t) => OrderingTerm.desc(t.expectedHatchDate)]))
        .get();

    // Fallback: If no completed batches exist yet, retrieve all batches
    if (batches.isEmpty) {
      batches = await (db.select(db.localHatcheryBatches)
        ..orderBy([(t) => OrderingTerm.desc(t.setDate)]))
          .get();
    }

    setState(() {
      _hatcheryBatches = batches;
      _loadingHatchery = false;

      if (batches.isNotEmpty) {
        LocalHatcheryBatche match = batches.first;
        if (widget.initialHatcheryBatchId != null) {
          match = batches.firstWhere(
            (b) => b.id == widget.initialHatcheryBatchId,
            orElse: () => batches.first,
          );
        }
        _selectedHatcheryBatch = match;
        _chickSource = 'hatchery_transfer';
        _breedCtrl.text = _parseBreedName(match.breed);
        final count = match.hatchedChicks ?? match.eggCount;
        if (_countCtrl.text.isEmpty || _countCtrl.text == '0') {
          _countCtrl.text = count.toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Start Brooding Pen Batch (0-4 Wks)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Source Selector
              const Text('Chick Source / Origin *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('In-House Hatchery Transfer', style: TextStyle(fontSize: 11)),
                      selected: _chickSource == 'hatchery_transfer',
                      selectedColor: Colors.purple.shade100,
                      onSelected: (val) {
                        if (val) setState(() => _chickSource = 'hatchery_transfer');
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('External Day-Old Chicks', style: TextStyle(fontSize: 11)),
                      selected: _chickSource == 'external_doc',
                      selectedColor: Colors.teal.shade100,
                      onSelected: (val) {
                        if (val) setState(() => _chickSource = 'external_doc');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Hatchery Batch Selector
              if (_chickSource == 'hatchery_transfer') ...[
                _loadingHatchery
                    ? const LinearProgressIndicator()
                    : _hatcheryBatches.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'No completed hatchery batches found in database. You can start a batch using "External Day-Old Chicks" or complete a hatchery batch first.',
                              style: TextStyle(fontSize: 12, color: Colors.purple),
                            ),
                          )
                        : DropdownButtonFormField<LocalHatcheryBatche>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Select Completed Hatchery Batch Source *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.egg, color: Colors.purple),
                            ),
                            value: _selectedHatcheryBatch,
                            items: _hatcheryBatches.map((h) {
                              final hatched = h.hatchedChicks ?? h.eggCount;
                              final statusTag = h.status == 'completed' ? 'COMPLETED' : 'INCUBATING';
                              final breedStr = _parseBreedName(h.breed);
                              final crateStr = (h.crateNumber != null && h.crateNumber!.isNotEmpty)
                                  ? ' (Crate ${h.crateNumber})'
                                  : '';
                              return DropdownMenuItem(
                                value: h,
                                child: Text(
                                  '${h.eggSource}$crateStr — $breedStr ($hatched Chicks) [$statusTag]',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedHatcheryBatch = val;
                                if (val != null) {
                                  _breedCtrl.text = _parseBreedName(val.breed);
                                  final count = val.hatchedChicks ?? val.eggCount;
                                  _countCtrl.text = count.toString();
                                }
                              });
                            },
                          ),
                const SizedBox(height: 14),
              ],

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _batchNumCtrl,
                      decoration: InputDecoration(
                        labelText: 'Brooder Batch #',
                        hintText: 'e.g. BR-101',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _penNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Pen / House Name',
                        hintText: 'e.g. Pen A',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _countCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Chick Count',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.flutter_dash),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _costCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _chickSource == 'external_doc' ? 'Purchase Cost (₦)' : 'Transfer Valuation (₦)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.payments),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _breedCtrl,
                      decoration: InputDecoration(
                        labelText: 'Breed / Strain',
                        hintText: 'e.g. Cobb 500 / ISA Brown',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.pets),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _initialTempCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Initial Temp (°C) *',
                        hintText: 'e.g. 33.0',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.thermostat, color: Colors.deepOrange),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Brooding Duration Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Target Brooding Period:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('$_broodingDays Days (${_broodingDays ~/ 7} Weeks)', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              Slider(
                value: _broodingDays.toDouble(),
                min: 14,
                max: 42,
                divisions: 4,
                label: '$_broodingDays Days',
                onChanged: (val) => setState(() => _broodingDays = val.toInt()),
              ),
              const SizedBox(height: 10),

              // Start Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Brooding Start Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Brooding Notes / Heating Setup',
                  hintText: 'e.g. Infrared lamps installed, temp set to 33°C',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('START BROODING BATCH', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final payload = {
                        'batch_number': _batchNumCtrl.text.trim(),
                        'pen_name': _penNameCtrl.text.trim(),
                        'chick_source': _chickSource,
                        'hatchery_batch_id': _selectedHatcheryBatch?.id,
                        'initial_count': int.parse(_countCtrl.text.trim()),
                        'initial_chick_cost': double.tryParse(_costCtrl.text.trim()) ?? 0.0,
                        'initial_temp': double.tryParse(_initialTempCtrl.text.trim()) ?? 33.0,
                        'breed': _breedCtrl.text.trim(),
                        'start_date': _startDate.toIso8601String().substring(0, 10),
                        'brooding_days': _broodingDays,
                        'notes': _notesCtrl.text.trim(),
                      };
                      await sl<PoultryRepository>().createBroodingBatch(payload);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Brooding batch started successfully!'), backgroundColor: Colors.purple),
                        );
                        Navigator.pop(context, true);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
