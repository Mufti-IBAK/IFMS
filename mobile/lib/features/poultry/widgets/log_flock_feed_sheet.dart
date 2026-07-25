import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/database/local_db.dart';
import '../../../core/theme/app_colors.dart';
import '../poultry_repository.dart';

class LogFlockFeedSheet extends StatefulWidget {
  final String batchId;
  const LogFlockFeedSheet({super.key, required this.batchId});

  @override
  State<LogFlockFeedSheet> createState() => _LogFlockFeedSheetState();
}

class _LogFlockFeedSheetState extends State<LogFlockFeedSheet> {
  final _formKey = GlobalKey<FormState>();
  String _feedSourceType = 'inventory'; // 'inventory' or 'formula'

  List<LocalFeedItem> _feedItems = [];
  List<LocalFeedFormula> _formulas = [];
  LocalFeedItem? _selectedFeedItem;
  LocalFeedFormula? _selectedFormula;

  final _feedNameCtrl = TextEditingController();
  final _quantityKgCtrl = TextEditingController();
  final _costPerKgCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  DateTime _logDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedStock();
  }

  Future<void> _loadFeedStock() async {
    final db = sl<LocalDatabase>();
    final items = await db.select(db.localFeedItems).get();
    final fms = await db.select(db.localFeedFormulas).get();
    setState(() {
      _feedItems = items;
      _formulas = fms;
      _isLoading = false;
    });
  }

  double get _totalCost {
    final qty = double.tryParse(_quantityKgCtrl.text) ?? 0.0;
    final cost = double.tryParse(_costPerKgCtrl.text) ?? 0.0;
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
                    'Log Daily Feed Eaten',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Feed Source Segmented Toggle
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Store Inventory Feed'),
                      selected: _feedSourceType == 'inventory',
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _feedSourceType = 'inventory';
                            _selectedFormula = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Milled Formula'),
                      selected: _feedSourceType == 'formula',
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _feedSourceType = 'formula';
                            _selectedFeedItem = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selection Dropdown
              _isLoading
                  ? const LinearProgressIndicator()
                  : _feedSourceType == 'inventory'
                      ? DropdownButtonFormField<LocalFeedItem>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.inventory_2, color: Colors.orange),
                            hintText: _feedItems.isEmpty ? 'No Feed Items in Store' : 'Select Feed Item',
                          ),
                          value: _selectedFeedItem,
                          items: _feedItems.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text('${item.name} (${item.currentStock} kg | ₦${item.costPerKg}/kg)'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedFeedItem = val;
                              if (val != null) {
                                _feedNameCtrl.text = val.name;
                                _costPerKgCtrl.text = val.costPerKg.toString();
                              }
                            });
                          },
                        )
                      : DropdownButtonFormField<LocalFeedFormula>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.science, color: Colors.purple),
                            hintText: _formulas.isEmpty ? 'No Milled Formulas Available' : 'Select Milled Feed Formula',
                          ),
                          value: _selectedFormula,
                          items: _formulas.map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text('${f.name} (Stock: ${f.currentStock} kg)'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedFormula = val;
                              if (val != null) {
                                _feedNameCtrl.text = val.name;
                                _costPerKgCtrl.text = '0';
                              }
                            });
                          },
                        ),
              const SizedBox(height: 14),

              // Feed Name
              TextFormField(
                controller: _feedNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Feed Description / Brand',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.grass),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter feed name' : null,
              ),
              const SizedBox(height: 14),

              // Quantity (kg) & Cost per kg
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityKgCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity (kg)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.scale),
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
                    child: TextFormField(
                      controller: _costPerKgCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Cost / kg (₦)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.payments),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Cost Preview Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Feed Cost', style: TextStyle(fontSize: 13, color: Colors.orange)),
                    Text('₦${_totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Log Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_logDate)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _logDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _logDate = DateTime(date.year, date.month, date.day, _logDate.hour, _logDate.minute);
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
                  labelText: 'Notes / Remarks',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('SAVE FEED LOG', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final payload = {
                        'batch_id': widget.batchId,
                        'feed_source_type': _feedSourceType,
                        'feed_item_id': _selectedFeedItem?.id,
                        'formula_id': _selectedFormula?.id,
                        'feed_name': _feedNameCtrl.text.trim(),
                        'quantity_kg': double.parse(_quantityKgCtrl.text.trim()),
                        'cost_per_kg': double.tryParse(_costPerKgCtrl.text.trim()) ?? 0.0,
                        'total_cost': _totalCost,
                        'log_date': _logDate.toIso8601String(),
                        'notes': _notesCtrl.text.trim(),
                      };
                      await sl<PoultryRepository>().logFlockFeedConsumption(payload);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Flock feed log saved successfully!'), backgroundColor: Colors.orange),
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
