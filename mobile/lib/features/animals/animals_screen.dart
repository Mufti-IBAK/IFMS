import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/utils/report_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/local_db.dart';
import 'animals_bloc.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFMS HERD REGISTRY'),
        actions: [
          BlocBuilder<AnimalsBloc, AnimalsState>(
            builder: (context, state) {
              if (state is AnimalsLoaded) {
                return IconButton(
                  onPressed: () => ReportService.generateHerdReport(
                    state.animals.whereType<LocalAnimal>().toList(),
                  ),
                  icon: const Icon(Icons.picture_as_pdf),
                );
              }
              return const SizedBox();
            },
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.sync, color: AppColors.info)),
        ],
      ),
      body: BlocBuilder<AnimalsBloc, AnimalsState>(
        builder: (context, state) {
          if (state is AnimalsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimalsLoaded) {
            return Column(
              children: [
                _buildFilterChips(),
                _buildSearchBar(),
                if (state.isOffline)
                  Container(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Ready to work offline. Actions will queue automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.animals.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final animal = state.animals[index];
                      final tagId = animal is Map ? animal['tag_id'] : animal.tagId;
                      final species = animal is Map ? animal['species'] : animal.species;
                      final sex = animal is Map ? animal['sex'] : animal.sex;
                      final breed = (animal is Map ? animal['breed'] : animal.breed) ?? 'Unknown';
                      final status = (animal is Map ? animal['current_reproductive_status'] : animal.currentReproductiveStatus) ?? 'Open';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: sex.toString().toLowerCase() == 'female' 
                                      ? Colors.pink.shade50 
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  species.toString().toLowerCase() == 'cow' 
                                      ? Icons.pets 
                                      : Icons.agriculture,
                                  color: sex.toString().toLowerCase() == 'female' 
                                      ? Colors.pink 
                                      : Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#$tagId',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      '$breed • ${status.toString().toUpperCase()}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Dairy Barn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                  Text('Yield: 24L', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is AnimalsError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No animals recorded.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAnimalDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _filterChip('All', true),
          _filterChip('Cattle (142)', false),
          _filterChip('Goats (84)', false),
          _filterChip('Sheep (60)', false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) {},
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.secondaryContainer,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.onSecondaryContainer : AppColors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Tag or Scan RFID...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: Icon(Icons.qr_code_scanner),
        ),
      ),
    );
  }

  void _showAddAnimalDialog(BuildContext context) {
    final tagController = TextEditingController();
    final breedController = TextEditingController();
    final weightController = TextEditingController();
    final colorController = TextEditingController();
    final marksController = TextEditingController();
    final vaccinationController = TextEditingController();
    
    DateTime? selectedDob;
    String selectedSpecies = 'cow';
    String selectedSex = 'female';
    String selectedPedigree = 'pure';
    String selectedPurpose = 'breeding';
    String selectedReproductive = 'open';
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final isFemale = selectedSex == 'female';
          
          return AlertDialog(
            title: const Text('Register New Animal'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Section
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setState(() => selectedImagePath = image.path);
                          }
                        },
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                            image: selectedImagePath != null
                                ? DecorationImage(image: FileImage(File(selectedImagePath!)), fit: BoxFit.cover)
                                : null,
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: selectedImagePath == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, color: AppColors.primary, size: 30),
                                    SizedBox(height: 4),
                                    Text('Take Photo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text('Basic Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Divider(),
                    
                    TextField(
                      controller: tagController, 
                      decoration: const InputDecoration(labelText: 'Tag ID / Ear Tag *', hintText: 'e.g. COW-109'),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedSpecies,
                            decoration: const InputDecoration(labelText: 'Species'),
                            items: const [
                              DropdownMenuItem(value: 'cow', child: Text('Cattle')),
                              DropdownMenuItem(value: 'goat', child: Text('Goat')),
                              DropdownMenuItem(value: 'sheep', child: Text('Sheep')),
                            ],
                            onChanged: (val) => setState(() => selectedSpecies = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedSex,
                            decoration: const InputDecoration(labelText: 'Sex'),
                            items: const [
                              DropdownMenuItem(value: 'female', child: Text('Female')),
                              DropdownMenuItem(value: 'male', child: Text('Male')),
                            ],
                            onChanged: (val) => setState(() => selectedSex = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: breedController, 
                      decoration: const InputDecoration(labelText: 'Breed', hintText: 'e.g. Holstein Friesian'),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('Physical & Pedigree', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Divider(),
                    
                    // Date of Birth Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(selectedDob == null 
                          ? 'Select Date of Birth *' 
                          : 'DOB: ${selectedDob!.toLocal().toString().split(' ')[0]}'),
                      subtitle: selectedDob != null
                          ? Text('Age: ${(DateTime.now().difference(selectedDob!).inDays / 365).toStringAsFixed(1)} years')
                          : null,
                      trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDob = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: weightController, 
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: 'e.g. 450.5'),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: colorController, 
                            decoration: const InputDecoration(labelText: 'Color', hintText: 'Black/White'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedPedigree,
                            decoration: const InputDecoration(labelText: 'Pedigree'),
                            items: const [
                              DropdownMenuItem(value: 'pure', child: Text('Purebreed')),
                              DropdownMenuItem(value: 'cross', child: Text('Crossbreed')),
                            ],
                            onChanged: (val) => setState(() => selectedPedigree = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: marksController, 
                      decoration: const InputDecoration(labelText: 'Unique Marks / Brands', hintText: 'e.g. Notch on left ear'),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('Purpose & Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Divider(),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedPurpose,
                            decoration: const InputDecoration(labelText: 'Purpose'),
                            items: const [
                              DropdownMenuItem(value: 'breeding', child: Text('Breeding')),
                              DropdownMenuItem(value: 'milk', child: Text('Dairy (Milk)')),
                              DropdownMenuItem(value: 'meat', child: Text('Beef (Meat)')),
                            ],
                            onChanged: (val) => setState(() => selectedPurpose = val!),
                          ),
                        ),
                        if (isFemale) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedReproductive,
                              decoration: const InputDecoration(labelText: 'Reprod. Status'),
                              items: const [
                                DropdownMenuItem(value: 'open', child: Text('Open')),
                                DropdownMenuItem(value: 'pregnant', child: Text('Pregnant')),
                                DropdownMenuItem(value: 'lactating', child: Text('Lactating')),
                                DropdownMenuItem(value: 'dry', child: Text('Dry')),
                              ],
                              onChanged: (val) => setState(() => selectedReproductive = val!),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: vaccinationController, 
                      decoration: const InputDecoration(labelText: 'Vaccination Notes', hintText: 'e.g. FMD booster done'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (tagController.text.isNotEmpty && selectedDob != null) {
                    final dobStr = selectedDob!.toIso8601String().split('T')[0];
                    
                    BlocProvider.of<AnimalsBloc>(context).add(AddAnimal({
                      'tag_id': tagController.text.trim(),
                      'species': selectedSpecies,
                      'sex': selectedSex,
                      'breed': breedController.text.trim().isNotEmpty ? breedController.text.trim() : null,
                      'date_of_birth': dobStr,
                      'weight': weightController.text.isNotEmpty ? double.tryParse(weightController.text) : null,
                      'color': colorController.text.trim().isNotEmpty ? colorController.text.trim() : null,
                      'unique_marks': marksController.text.trim().isNotEmpty ? marksController.text.trim() : null,
                      'pedigree_type': selectedPedigree,
                      'purpose': selectedPurpose,
                      'current_reproductive_status': isFemale ? selectedReproductive : 'open',
                      'vaccination_status': vaccinationController.text.trim().isNotEmpty ? vaccinationController.text.trim() : null,
                      'image_path': selectedImagePath,
                    }));
                    Navigator.pop(dialogContext);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tag ID and Date of Birth are required!')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          );
        },
      ),
    );
  }
}
