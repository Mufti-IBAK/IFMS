import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../dairy_bloc.dart';
import '../../animals/animals_bloc.dart';

class AddMilkEntrySheet extends StatefulWidget {
  const AddMilkEntrySheet({super.key});

  @override
  State<AddMilkEntrySheet> createState() => _AddMilkEntrySheetState();
}

class _AddMilkEntrySheetState extends State<AddMilkEntrySheet> {
  String? selectedAnimalId;
  String selectedSession = 'morning';
  DateTime selectedDate = DateTime.now();

  final litersCtrl = TextEditingController();
  final fatCtrl = TextEditingController();
  final proteinCtrl = TextEditingController();

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
            const Text('Record Milk Entry', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Cow Selection
            BlocBuilder<AnimalsBloc, AnimalsState>(
              builder: (context, state) {
                if (state is AnimalsLoaded) {
                  // Filter for active female cattle
                  final cows = state.animals.where((a) {
                    final isMap = a is Map;
                    final sex = (isMap ? a['sex'] : (a as dynamic).sex).toString().toLowerCase();
                    final species = (isMap ? a['species'] : (a as dynamic).species).toString().toLowerCase();
                    final status = (isMap ? a['status'] : (a as dynamic).status).toString().toLowerCase();
                    final repro = (isMap ? a['current_reproductive_status'] ?? a['currentReproductiveStatus'] : (a as dynamic).currentReproductiveStatus).toString().toLowerCase();
                    
                    return sex == 'female' && 
                           (species == 'cow' || species == 'bovine' || species == 'cattle') && 
                           status == 'active' && 
                           repro == 'lactating';
                  }).toList();
                  
                  return DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width - 48,
                    enableSearch: true,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    leadingIcon: const Icon(Icons.search),
                    label: const Text('Search Cow by Tag ID'),
                    inputDecorationTheme: const InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                    dropdownMenuEntries: cows.map((c) {
                      final isMap = c is Map;
                      final id = isMap ? c['id'] : (c as dynamic).id;
                      final tag = isMap ? c['tag_id'] ?? c['id'] : (c as dynamic).tagId;
                      return DropdownMenuEntry<String>(
                        value: id.toString(),
                        label: tag.toString(),
                      );
                    }).toList(),
                    onSelected: (selection) {
                      setState(() => selectedAnimalId = selection);
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 16),

            // Session & Date
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSession,
                    decoration: const InputDecoration(labelText: 'Milking Session', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'morning', child: Text('Morning')),
                      DropdownMenuItem(value: 'evening', child: Text('Evening')),
                      DropdownMenuItem(value: 'total_day', child: Text('Daily Total')),
                    ],
                    onChanged: (v) => setState(() => selectedSession = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Production & Quality
            TextField(textCapitalization: TextCapitalization.sentences, controller: litersCtrl,
              decoration: const InputDecoration(labelText: 'Quantity (Liters)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.water_drop)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(textCapitalization: TextCapitalization.sentences, controller: fatCtrl,
                    decoration: const InputDecoration(labelText: 'Fat (%)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(textCapitalization: TextCapitalization.sentences, controller: proteinCtrl,
                    decoration: const InputDecoration(labelText: 'Protein (%)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedAnimalId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a cow.')));
                    return;
                  }
                  final liters = double.tryParse(litersCtrl.text);
                  if (liters == null || liters <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid liters.')));
                    return;
                  }

                  context.read<DairyBloc>().add(AddMilkEntry({
                    'animal_id': selectedAnimalId,
                    'record_date': selectedDate.toIso8601String(),
                    'milking_session': selectedSession,
                    'quantity_liters': liters,
                    'fat_percentage': double.tryParse(fatCtrl.text),
                    'protein_percentage': double.tryParse(proteinCtrl.text),
                  }));

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Milk Record'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
