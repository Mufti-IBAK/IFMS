import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:io';
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
                    return sex == 'female' && species == 'cattle' && status == 'active';
                  }).toList();
                  
                  return Autocomplete<Object>(
                    displayStringForOption: (option) => option is Map ? option['tag_id'] ?? option['id'] : (option as dynamic).tagId,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return cows.cast<Object>();
                      return cows.where((c) {
                        final tag = (c is Map ? c['tag_id'] ?? c['id'] : (c as dynamic).tagId).toString().toLowerCase();
                        return tag.contains(textEditingValue.text.toLowerCase());
                      }).cast<Object>();
                    },
                    onSelected: (selection) {
                      setState(() => selectedAnimalId = selection is Map ? selection['id'] : (selection as dynamic).id);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 48, // Match padding
                            height: 200,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                final isMap = option is Map;
                                final tag = isMap ? option['tag_id'] ?? option['id'] : (option as dynamic).tagId;
                                final imagePath = isMap ? option['image_path'] : (option as dynamic).imagePath;
                                
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: imagePath != null && imagePath.isNotEmpty ? FileImage(File(imagePath)) : null,
                                    child: imagePath == null || imagePath.isEmpty ? const Icon(Icons.pets, size: 16) : null,
                                  ),
                                  title: Text(tag.toString()),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextField(textCapitalization: TextCapitalization.sentences, controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Search Cow by Tag ID',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      );
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
