import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../animals_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/database/local_db.dart';
import '../../../core/network/notification_service.dart';
import '../../pharmacy/pharmacy_repository.dart';
import '../../finance/finance_repository.dart';
import '../../tasks/tasks_repository.dart';

class MedicationEntry {
  LocalMedication? medication;
  final dosageCtrl = TextEditingController();
  final routeCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  String frequency = 'Once Daily';

  void dispose() {
    dosageCtrl.dispose();
    routeCtrl.dispose();
    durationCtrl.dispose();
  }
}

class MedicalReportSheet extends StatefulWidget {
  final dynamic animal;
  const MedicalReportSheet({super.key, required this.animal});

  @override
  State<MedicalReportSheet> createState() => _MedicalReportSheetState();
}

class _MedicalReportSheetState extends State<MedicalReportSheet> {
  final _formKey = GlobalKey<FormState>();

  // Vitals
  final tempCtrl = TextEditingController();
  final heartRateCtrl = TextEditingController();
  final respRateCtrl = TextEditingController();

  // Diagnostics
  final obsCtrl = TextEditingController();
  final examGeneralCtrl = TextEditingController();
  final examRespCtrl = TextEditingController();
  final examLymphCtrl = TextEditingController();
  final examEyeEarCtrl = TextEditingController();
  final examDigestiveCtrl = TextEditingController();
  final examMusculoCtrl = TextEditingController();
  final examCardioCtrl = TextEditingController();
  final examReproCtrl = TextEditingController();
  final examNervousCtrl = TextEditingController();
  final examIntegumentaryCtrl = TextEditingController();
  final examMucousCtrl = TextEditingController();
  final examMammaryCtrl = TextEditingController();
  final labCtrl = TextEditingController();

  // Outcome
  bool isDeceased = false;
  final postmortemCtrl = TextEditingController();

  // Medications
  final List<MedicationEntry> _medications = [MedicationEntry()];
  List<LocalMedication> _availableMedications = [];
  bool _isLoadingMeds = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final pharmacyRepo = sl<PharmacyRepository>();
    final meds = await pharmacyRepo.getMedications();
    setState(() {
      _availableMedications = meds.where((m) => m.isActive).toList();
      _isLoadingMeds = false;
    });
  }

  @override
  void dispose() {
    tempCtrl.dispose();
    heartRateCtrl.dispose();
    respRateCtrl.dispose();
    obsCtrl.dispose();
    examGeneralCtrl.dispose();
    examRespCtrl.dispose();
    examLymphCtrl.dispose();
    examEyeEarCtrl.dispose();
    examDigestiveCtrl.dispose();
    examMusculoCtrl.dispose();
    examCardioCtrl.dispose();
    examReproCtrl.dispose();
    examNervousCtrl.dispose();
    examIntegumentaryCtrl.dispose();
    examMucousCtrl.dispose();
    examMammaryCtrl.dispose();
    labCtrl.dispose();
    postmortemCtrl.dispose();
    for (var m in _medications) {
      m.dispose();
    }
    super.dispose();
  }

  void _addMedication() {
    setState(() {
      _medications.add(MedicationEntry());
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications[index].dispose();
      _medications.removeAt(index);
    });
  }

  Future<void> _scheduleReminderTask(
    String animalId,
    String title,
    String description,
    DateTime dueDate,
    {String category = 'medical_record', bool isActionable = true}
  ) async {
    final tasksRepo = sl<TasksRepository>();
    final taskId = 'rem_${animalId}_${title.hashCode}_${dueDate.millisecondsSinceEpoch}';
    
    try {
      await tasksRepo.createTask({
        'id': taskId,
        'title': title,
        'description': description,
        'priority': 'high',
        'status': 'pending',
        'due_date': dueDate.toIso8601String().substring(0, 10),
        'category': category,
        'assignedTo': 'personal',
        'isActionable': isActionable,
      }, isPublic: true);
    } catch (e) {
      // Ignored for background scheduling from UI, or show a snackbar if critical
      debugPrint('Error scheduling task: $e');
    }
  }

  Future<void> _saveReport(String animalId) async {
    if (!_formKey.currentState!.validate()) return;
    
    for (var i = 0; i < _medications.length; i++) {
      if (_medications[i].medication == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select a medication for Medication #${i + 1}'),
          backgroundColor: AppColors.error,
        ));
        return;
      }
    }
    
    // Validate medications
    for (var i = 0; i < _medications.length; i++) {
      final entry = _medications[i];
      if (entry.medication == null) continue; // Skip empty rows
      
      final dose = double.tryParse(entry.dosageCtrl.text) ?? 0;
      if (dose <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid dosage for ${entry.medication!.name}')));
        return;
      }
      if (entry.medication!.currentStock < dose) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insufficient stock for ${entry.medication!.name}. Required: $dose, Available: ${entry.medication!.currentStock}')));
        return;
      }
    }

    final pharmacyRepo = sl<PharmacyRepository>();
    final financeRepo = sl<FinanceRepository>();

    final treatmentList = [];

    // Process medications
    for (var entry in _medications) {
      if (entry.medication == null) continue;

      final dose = double.parse(entry.dosageCtrl.text);
      final duration = int.tryParse(entry.durationCtrl.text) ?? 1;
      
      // 1. Log Treatment & Deduct Inventory
      await pharmacyRepo.logAnimalTreatment({
        'animal_id': animalId,
        'medication_id': entry.medication!.id,
        'administered_dose': dose,
        'treatment_date': DateTime.now().toIso8601String(),
        'diagnosed_condition': obsCtrl.text.isNotEmpty ? obsCtrl.text : 'Routine/Follow-up',
        'administered_by': 'Veterinarian',
        'notes': 'Route: ${entry.routeCtrl.text}, Freq: ${entry.frequency}, Duration: $duration days',
      });

      // 2. Log Financial Expense
      final cost = dose * entry.medication!.costPerUnit;
      if (cost > 0) {
        await financeRepo.addTransaction({
          'transaction_type': 'expense',
          'category': 'medication',
          'amount': cost,
          'transaction_date': DateTime.now().toIso8601String(),
          'related_entity_type': 'animal',
          'related_entity_id': animalId,
          'description': 'Administered $dose ${entry.medication!.unit} of ${entry.medication!.name}',
        });
      }

      // 3. Generate Follow-up Task Schedules
      if (duration > 0) {
        int dosesPerDay = 1;
        if (entry.frequency == 'Morning & Evening' || entry.frequency == 'Every 12 Hours') dosesPerDay = 2;
        if (entry.frequency == 'Every 8 Hours') dosesPerDay = 3;
        if (entry.frequency == 'Every 6 Hours') dosesPerDay = 4;

        final now = DateTime.now();
        // Start scheduling from tomorrow if today's dose is already given (assumed first dose is now)
        // Or we schedule all future doses starting a few hours from now depending on frequency.
        // For simplicity, schedule daily reminders for the remaining duration.
        for (int day = 0; day < duration; day++) {
          if (day == 0 && dosesPerDay == 1) continue; // Already gave today's single dose

          for (int doseNum = 1; doseNum <= dosesPerDay; doseNum++) {
            if (day == 0 && doseNum == 1) continue; // Skip the very first dose (just administered)
            
            DateTime reminderTime = now.add(Duration(days: day));
            // Adjust time roughly based on dose number (e.g., 8 AM, 2 PM, 8 PM)
            if (dosesPerDay == 2) {
              reminderTime = DateTime(now.year, now.month, now.day + day, doseNum == 1 ? 8 : 18, 0); // 8 AM & 6 PM
            } else if (dosesPerDay == 3) {
              reminderTime = DateTime(now.year, now.month, now.day + day, doseNum == 1 ? 8 : (doseNum == 2 ? 16 : 23), 0); // 8 AM, 4 PM, 11 PM
            }
            
            if (reminderTime.isAfter(now)) {
              await _scheduleReminderTask(
                animalId,
                'Medication Due: ${entry.medication!.name}',
                'Administer $dose ${entry.medication!.unit} of ${entry.medication!.name} (${entry.routeCtrl.text})',
                reminderTime,
              );
            }
          }
        }
      }

      treatmentList.add({
        'drug': entry.medication!.name,
        'dosage': dose,
        'route': entry.routeCtrl.text,
        'duration_days': duration,
        'frequency': entry.frequency,
      });
    }

    // 4. Log an Informational Task for the report
    await _scheduleReminderTask(
      animalId,
      'Medical Report Logged',
      'Report saved with ${treatmentList.length} treatments.',
      DateTime.now(),
      category: 'medical_record',
      isActionable: false, // Purely informational
    );

    final report = {
      'vitals': {
        'temp': tempCtrl.text,
        'heart_rate': heartRateCtrl.text,
        'resp_rate': respRateCtrl.text,
      },
      'diagnostics': {
        'observations': obsCtrl.text,
        'physical_exam': {
          'general_appearance': examGeneralCtrl.text,
          'mucous_membranes': examMucousCtrl.text,
          'integumentary': examIntegumentaryCtrl.text,
          'respiratory': examRespCtrl.text,
          'cardiovascular': examCardioCtrl.text,
          'digestive': examDigestiveCtrl.text,
          'musculoskeletal': examMusculoCtrl.text,
          'nervous': examNervousCtrl.text,
          'lymph_nodes': examLymphCtrl.text,
          'eyes_ears': examEyeEarCtrl.text,
          'reproductive': examReproCtrl.text,
          'mammary': examMammaryCtrl.text,
        },
        'lab_results': labCtrl.text,
      },
      'treatments': treatmentList,
      'outcome': {
        'is_deceased': isDeceased,
        'postmortem': isDeceased ? postmortemCtrl.text : null,
      }
    };

    if (mounted) {
      context.read<AnimalsBloc>().add(AddAnimalEvent(animalId, 'medical_report', report));
      Navigator.pop(context);
      
      sl<NotificationService>().showLocalNotification(
        'Medical Report Saved', 
        'Follow-ups scheduled for ${treatmentList.length} medications',
        payload: '/tasks',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMap = widget.animal is Map;
    final tag = isMap ? widget.animal['tag_id'] : widget.animal.tagId;
    final animalId = isMap ? widget.animal['id'] : widget.animal.id;
    final String sex = (isMap ? widget.animal['sex'] : widget.animal.sex).toString().toLowerCase();
    final bool isFemale = sex == 'female';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medical Report: $tag', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // VITALS
              const Text('Vitals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildField(tempCtrl, 'Temp (°C)', TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildField(heartRateCtrl, 'HR (bpm)', TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildField(respRateCtrl, 'RR (rpm)', TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),

              // DIAGNOSTICS & EXAM
              const Text('Diagnostics & Physical Exam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              _buildField(obsCtrl, 'General Observations / Symptoms', TextInputType.text, maxLines: 2),
              const SizedBox(height: 16),
              
              const Text('Systems Examination', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildField(examGeneralCtrl, 'General Appearance (BCS, Posture, Coat)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examMucousCtrl, 'Mucous Membranes (Color, CRT)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examIntegumentaryCtrl, 'Integumentary (Skin, Hair, Hooves)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examRespCtrl, 'Respiratory System (Cough, Discharge, Sounds)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examCardioCtrl, 'Cardiovascular (Pulse, Murmurs)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examDigestiveCtrl, 'Digestive (Rumen, Manure, Appetite)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examMusculoCtrl, 'Musculoskeletal (Lameness, Joints)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examNervousCtrl, 'Nervous System (Mentation, Gait, Reflexes)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examLymphCtrl, 'Lymph Nodes (Swelling, Pain)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examEyeEarCtrl, 'Eyes & Ears (Discharge, Vision)', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(examReproCtrl, 'Reproductive / Urogenital', TextInputType.text),
              if (isFemale) ...[
                const SizedBox(height: 8),
                _buildField(examMammaryCtrl, 'Mammary System (Udder, Teats, Mastitis)', TextInputType.text),
              ],
              const SizedBox(height: 16),
              
              _buildField(labCtrl, 'Lab Results (Optional)', TextInputType.text, maxLines: 2),
              const SizedBox(height: 16),

              // TREATMENT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: Text('Prescription / Treatment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary))),
                  TextButton.icon(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Drug'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              if (_isLoadingMeds)
                const Center(child: CircularProgressIndicator())
              else if (_availableMedications.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No medications available in Pharmacy. Please add stock first.', style: TextStyle(color: AppColors.error)),
                )
              else
                ..._medications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medEntry = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Medication #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (_medications.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                                  onPressed: () => _removeMedication(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownMenu<LocalMedication>(
                            expandedInsets: EdgeInsets.zero,
                            enableFilter: true,
                            enableSearch: true,
                            label: const Text('Search Drug/Vaccine'),
                            dropdownMenuEntries: _availableMedications.map((m) {
                              return DropdownMenuEntry<LocalMedication>(
                                value: m,
                                label: '${m.name} (Stock: ${m.currentStock} ${m.unit})',
                              );
                            }).toList(),
                            onSelected: (val) {
                              setState(() {
                                medEntry.medication = val;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildField(medEntry.dosageCtrl, 'Dosage (${medEntry.medication?.unit ?? "units"})', TextInputType.number, isRequired: true)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildField(medEntry.routeCtrl, 'Route (IM, IV, PO)', TextInputType.text)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Frequency',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  initialValue: medEntry.frequency,
                                  items: ['Once Daily', 'Morning & Evening', 'Every 12 Hours', 'Every 8 Hours', 'Every 6 Hours'].map((f) {
                                    return DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13)));
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      medEntry.frequency = val!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _buildField(medEntry.durationCtrl, 'Duration (Days)', TextInputType.number, isRequired: true)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 16),

              // OUTCOME
              const Text('Outcome', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Animal Died (Requires Postmortem)'),
                value: isDeceased,
                activeTrackColor: AppColors.error.withValues(alpha: 0.5),
                activeThumbColor: AppColors.error,
                onChanged: (v) => setState(() => isDeceased = v),
              ),
              if (isDeceased) ...[
                const SizedBox(height: 8),
                _buildField(postmortemCtrl, 'Postmortem Results / Cause of Death', TextInputType.text, maxLines: 3, isRequired: true),
              ],
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveReport(animalId),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  child: const Text('Save Medical Report', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, TextInputType type, {int maxLines = 1, bool isRequired = false}) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (v) {
        if (isRequired && (v == null || v.isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
