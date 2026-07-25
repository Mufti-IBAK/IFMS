import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../poultry_repository.dart';

class LogFlockAdjustmentSheet extends StatefulWidget {
  final String batchId;
  const LogFlockAdjustmentSheet({super.key, required this.batchId});

  @override
  State<LogFlockAdjustmentSheet> createState() => _LogFlockAdjustmentSheetState();
}

class _LogFlockAdjustmentSheetState extends State<LogFlockAdjustmentSheet> {
  final _formKey = GlobalKey<FormState>();
  String _adjustmentType = 'mortality'; // 'mortality', 'addition', 'cull'
  final _countCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  DateTime _adjustmentDate = DateTime.now();

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
                    'Flock Headcount Adjustment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Adjustment Type Selector Chips
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Mortality (-)', style: TextStyle(fontWeight: FontWeight.bold)),
                      selected: _adjustmentType == 'mortality',
                      selectedColor: Colors.red.shade100,
                      onSelected: (val) {
                        if (val) setState(() => _adjustmentType = 'mortality');
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Restock (+)', style: TextStyle(fontWeight: FontWeight.bold)),
                      selected: _adjustmentType == 'addition',
                      selectedColor: Colors.green.shade100,
                      onSelected: (val) {
                        if (val) setState(() => _adjustmentType = 'addition');
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Cull (-)', style: TextStyle(fontWeight: FontWeight.bold)),
                      selected: _adjustmentType == 'cull',
                      selectedColor: Colors.orange.shade100,
                      onSelected: (val) {
                        if (val) setState(() => _adjustmentType = 'cull');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Number of Birds
              TextFormField(
                controller: _countCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _adjustmentType == 'addition' ? 'Number of Birds Added' : 'Number of Birds Lost / Culled',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(
                    _adjustmentType == 'addition' ? Icons.add_circle : Icons.remove_circle,
                    color: _adjustmentType == 'addition' ? Colors.green : Colors.red,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  final count = int.tryParse(val.trim());
                  if (count == null || count <= 0) return 'Enter valid count > 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Adjustment Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_adjustmentDate)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _adjustmentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _adjustmentDate = DateTime(date.year, date.month, date.day, _adjustmentDate.hour, _adjustmentDate.minute);
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Reason Notes
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: _adjustmentType == 'mortality' ? 'Cause of Death / Symptoms' : 'Reason / Notes',
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
                    backgroundColor: _adjustmentType == 'addition' ? Colors.green : (_adjustmentType == 'mortality' ? AppColors.error : Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text('SAVE ${_adjustmentType.toUpperCase()} ADJUSTMENT', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final payload = {
                        'batch_id': widget.batchId,
                        'adjustment_type': _adjustmentType,
                        'head_count': int.parse(_countCtrl.text.trim()),
                        'adjustment_date': _adjustmentDate.toIso8601String(),
                        'reason_notes': _reasonCtrl.text.trim(),
                      };
                      await sl<PoultryRepository>().logFlockAdjustment(payload);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Flock $_adjustmentType adjustment saved successfully!'), backgroundColor: AppColors.primary),
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
