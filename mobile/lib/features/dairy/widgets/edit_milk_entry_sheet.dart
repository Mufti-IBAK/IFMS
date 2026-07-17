import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/database/local_db.dart';
import '../dairy_bloc.dart';

class EditMilkEntrySheet extends StatefulWidget {
  final LocalMilkRecord record;
  const EditMilkEntrySheet({super.key, required this.record});

  @override
  State<EditMilkEntrySheet> createState() => _EditMilkEntrySheetState();
}

class _EditMilkEntrySheetState extends State<EditMilkEntrySheet> {
  late String selectedSession;
  late DateTime selectedDate;

  late TextEditingController litersCtrl;
  late TextEditingController fatCtrl;
  late TextEditingController proteinCtrl;

  @override
  void initState() {
    super.initState();
    selectedSession = widget.record.milkingSession;
    selectedDate = widget.record.recordDate;
    
    litersCtrl = TextEditingController(text: widget.record.quantityLiters.toString());
    fatCtrl = TextEditingController(text: widget.record.fatPercentage?.toString() ?? '');
    proteinCtrl = TextEditingController(text: widget.record.proteinPercentage?.toString() ?? '');
  }

  @override
  void dispose() {
    litersCtrl.dispose();
    fatCtrl.dispose();
    proteinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Milk Entry', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Text('Cow ID: ${widget.record.animalId}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Session & Date
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSession,
                    decoration: const InputDecoration(labelText: 'Milking Session', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'morning', child: Text('Morning')),
                      DropdownMenuItem(value: 'evening', child: Text('Evening')),
                      DropdownMenuItem(value: 'total_day', child: Text('Daily Total')),
                    ],
                    onChanged: (v) => setState(() => selectedSession = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                      child: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Metrics
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: litersCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quantity (Liters)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fatCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Fat % (Optional)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: proteinCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Protein % (Optional)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (litersCtrl.text.isEmpty) return;

                  final data = {
                    'animal_id': widget.record.animalId,
                    'record_date': selectedDate.toIso8601String(),
                    'milking_session': selectedSession,
                    'quantity_liters': double.parse(litersCtrl.text),
                    if (fatCtrl.text.isNotEmpty) 'fat_percentage': double.parse(fatCtrl.text),
                    if (proteinCtrl.text.isNotEmpty) 'protein_percentage': double.parse(proteinCtrl.text),
                  };

                  context.read<DairyBloc>().add(UpdateMilkEntry(widget.record.id, data));
                  Navigator.pop(context);
                },
                child: const Text('UPDATE RECORD'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
