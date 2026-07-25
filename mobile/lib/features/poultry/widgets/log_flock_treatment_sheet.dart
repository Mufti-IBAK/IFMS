import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/database/local_db.dart';
import '../../../core/theme/app_colors.dart';
import '../poultry_repository.dart';

class LogFlockTreatmentSheet extends StatefulWidget {
  final String batchId;
  const LogFlockTreatmentSheet({super.key, required this.batchId});

  @override
  State<LogFlockTreatmentSheet> createState() => _LogFlockTreatmentSheetState();
}

class _LogFlockTreatmentSheetState extends State<LogFlockTreatmentSheet> {
  final _formKey = GlobalKey<FormState>();
  LocalMedication? _selectedMedication;
  final _medNameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'vials');
  final _costPerUnitCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  DateTime _treatmentDate = DateTime.now();

  List<LocalMedication> _medications = [];
  bool _loadingMeds = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacyMedications();
  }

  Future<void> _loadPharmacyMedications() async {
    final db = sl<LocalDatabase>();
    final meds = await db.select(db.localMedications).get();
    setState(() {
      _medications = meds;
      _loadingMeds = false;
    });
  }

  double get _totalCost {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0.0;
    final cost = double.tryParse(_costPerUnitCtrl.text) ?? 0.0;
    return qty * cost;
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
                    'Log Flock Treatment & Medication',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pharmacy Selection Dropdown
              const Text('Select Medication from Pharmacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              _loadingMeds
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<LocalMedication>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.local_pharmacy, color: Colors.teal),
                        hintText: _medications.isEmpty ? 'No Pharmacy Stock (Enter custom name)' : 'Select Pharmacy Medication',
                      ),
                      value: _selectedMedication,
                      items: _medications.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text('${m.name} (Stock: ${m.currentStock} ${m.unit} | ₦${m.costPerUnit}/${m.unit})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMedication = val;
                          if (val != null) {
                            _medNameCtrl.text = val.name;
                            _unitCtrl.text = val.unit;
                            _costPerUnitCtrl.text = val.costPerUnit.toString();
                          }
                        });
                      },
                    ),
              const SizedBox(height: 14),

              // Custom Medication Name
              TextFormField(
                controller: _medNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Medication / Vaccine Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medication),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter medication name' : null,
              ),
              const SizedBox(height: 14),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity Used',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitCtrl,
                      decoration: InputDecoration(
                        labelText: 'Unit (e.g. vials, ml)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Cost Per Unit & Total Cost Preview
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPerUnitCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Unit Cost (₦)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.payments),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Cost Entry', style: TextStyle(fontSize: 11, color: Colors.teal)),
                          Text('₦${_totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Treatment Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Treatment Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_treatmentDate)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _treatmentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _treatmentDate = DateTime(date.year, date.month, date.day, _treatmentDate.hour, _treatmentDate.minute);
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Diagnosis / Treatment Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('SAVE FLOCK TREATMENT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final payload = {
                        'batch_id': widget.batchId,
                        'medication_id': _selectedMedication?.id,
                        'medication_name': _medNameCtrl.text.trim(),
                        'quantity_used': double.parse(_quantityCtrl.text.trim()),
                        'unit': _unitCtrl.text.trim(),
                        'cost_per_unit': double.tryParse(_costPerUnitCtrl.text.trim()) ?? 0.0,
                        'total_cost': _totalCost,
                        'treatment_date': _treatmentDate.toIso8601String(),
                        'notes': _notesCtrl.text.trim(),
                      };
                      await sl<PoultryRepository>().logFlockTreatment(payload);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Flock treatment saved successfully!'), backgroundColor: Colors.teal),
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
