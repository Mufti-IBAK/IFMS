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
    String selectedSpecies = 'bovine';
    String selectedSex = 'female';
    String selectedPedigree = 'pure';
    String selectedPurpose = 'milk';
    String selectedReproductive = 'open';
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setState) {
          final media = MediaQuery.of(context);
          final isTablet = media.size.width > 600;
          final isFemale = selectedSex == 'female';

          // Helper to render form fields with consistent styling
          Widget buildInputField({
            required String label,
            required Widget child,
          }) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outline),
                  ),
                  const SizedBox(height: 6),
                  child,
                ],
              ),
            );
          }

          // Responsive layout grid helper
          Widget buildRowIfResponsive(Widget w1, Widget w2) {
            if (isTablet) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: w1),
                  const SizedBox(width: 16),
                  Expanded(child: w2),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [w1, w2],
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(20, 16, 20, media.viewInsets.bottom + 20),
            child: FractionallySizedBox(
              heightFactor: 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Register New Animal',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Form Fields List
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo & Tag Section
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
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                  image: selectedImagePath != null
                                      ? DecorationImage(image: FileImage(File(selectedImagePath!)), fit: BoxFit.cover)
                                      : null,
                                  border: Border.all(color: AppColors.outlineVariant, width: 2),
                                ),
                                child: selectedImagePath == null
                                    ? const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, color: AppColors.primary, size: 28),
                                          SizedBox(height: 4),
                                          Text('Add Photo', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Basic Info Card
                          Card(
                            elevation: 0,
                            color: AppColors.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('1. BASIC IDENTITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const SizedBox(height: 12),
                                  
                                  buildInputField(
                                    label: 'Ear Tag / Identifier *',
                                    child: TextField(
                                      controller: tagController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. COW-204',
                                        prefixIcon: Icon(Icons.tag, size: 20),
                                      ),
                                    ),
                                  ),
                                  
                                  buildRowIfResponsive(
                                    buildInputField(
                                      label: 'Species *',
                                      child: DropdownButtonFormField<String>(
                                        value: selectedSpecies,
                                        items: const [
                                          DropdownMenuItem(value: 'bovine', child: Text('Bovine (Cattle)')),
                                          DropdownMenuItem(value: 'avian', child: Text('Avian (Poultry)')),
                                          DropdownMenuItem(value: 'caprine', child: Text('Caprine (Goat)')),
                                          DropdownMenuItem(value: 'ovine', child: Text('Ovine (Sheep)')),
                                          DropdownMenuItem(value: 'porcine', child: Text('Porcine (Pig)')),
                                          DropdownMenuItem(value: 'others', child: Text('Others')),
                                        ],
                                        onChanged: (val) => setState(() => selectedSpecies = val!),
                                      ),
                                    ),
                                    buildInputField(
                                      label: 'Sex *',
                                      child: Row(
                                        children: [
                                          ChoiceChip(
                                            label: const Text('Female'),
                                            selected: selectedSex == 'female',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedSex = 'female');
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          ChoiceChip(
                                            label: const Text('Male'),
                                            selected: selectedSex == 'male',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedSex = 'male');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  buildInputField(
                                    label: 'Breed',
                                    child: TextField(
                                      controller: breedController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Holstein Friesian / Cobb 500',
                                        prefixIcon: Icon(Icons.pets, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Characteristics Card
                          Card(
                            elevation: 0,
                            color: AppColors.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('2. PHYSICAL CHARACTERISTICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const SizedBox(height: 12),
                                  
                                  buildInputField(
                                    label: 'Date of Birth *',
                                    child: InkWell(
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.outlineVariant),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              selectedDob == null
                                                  ? 'Choose Date'
                                                  : selectedDob!.toLocal().toString().split(' ')[0],
                                              style: TextStyle(
                                                color: selectedDob == null ? AppColors.outline : AppColors.onSurface,
                                              ),
                                            ),
                                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  buildRowIfResponsive(
                                    buildInputField(
                                      label: 'Weight (kg)',
                                      child: TextField(
                                        controller: weightController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 350.2',
                                          prefixIcon: Icon(Icons.scale, size: 20),
                                        ),
                                      ),
                                    ),
                                    buildInputField(
                                      label: 'Color / Pattern',
                                      child: TextField(
                                        controller: colorController,
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Brown with white spot',
                                          prefixIcon: Icon(Icons.palette, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  buildInputField(
                                    label: 'Unique Distinguishing Marks',
                                    child: TextField(
                                      controller: marksController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Slit on right ear / Branding #40',
                                        prefixIcon: Icon(Icons.visibility, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Pedigree & Operations Card
                          Card(
                            elevation: 0,
                            color: AppColors.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('3. PURPOSE & PRODUCTION STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const SizedBox(height: 12),
                                  
                                  buildRowIfResponsive(
                                    buildInputField(
                                      label: 'Pedigree Type',
                                      child: Row(
                                        children: [
                                          ChoiceChip(
                                            label: const Text('Purebreed'),
                                            selected: selectedPedigree == 'pure',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedPedigree = 'pure');
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          ChoiceChip(
                                            label: const Text('Crossbreed'),
                                            selected: selectedPedigree == 'cross',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedPedigree = 'cross');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    buildInputField(
                                      label: 'Operational Purpose',
                                      child: DropdownButtonFormField<String>(
                                        value: selectedPurpose,
                                        items: const [
                                          DropdownMenuItem(value: 'breeding', child: Text('Breeding')),
                                          DropdownMenuItem(value: 'milk', child: Text('Dairy (Milk)')),
                                          DropdownMenuItem(value: 'meat', child: Text('Beef (Meat)')),
                                          DropdownMenuItem(value: 'eggs', child: Text('Layers (Eggs)')),
                                          DropdownMenuItem(value: 'others', child: Text('Others')),
                                        ],
                                        onChanged: (val) => setState(() => selectedPurpose = val!),
                                      ),
                                    ),
                                  ),
                                  
                                  if (isFemale)
                                    buildInputField(
                                      label: 'Reproductive Status',
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          ChoiceChip(
                                            label: const Text('Open (Not Preg.)'),
                                            selected: selectedReproductive == 'open',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedReproductive = 'open');
                                            },
                                          ),
                                          ChoiceChip(
                                            label: const Text('Pregnant'),
                                            selected: selectedReproductive == 'pregnant',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedReproductive = 'pregnant');
                                            },
                                          ),
                                          ChoiceChip(
                                            label: const Text('Lactating'),
                                            selected: selectedReproductive == 'lactating',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedReproductive = 'lactating');
                                            },
                                          ),
                                          ChoiceChip(
                                            label: const Text('Dry'),
                                            selected: selectedReproductive == 'dry',
                                            onSelected: (selected) {
                                              if (selected) setState(() => selectedReproductive = 'dry');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  buildInputField(
                                    label: 'Current Vaccination Notes',
                                    child: TextField(
                                      controller: vaccinationController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Dewormed 2 weeks ago',
                                        prefixIcon: Icon(Icons.vaccines, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Actions Banner
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
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
                              Navigator.pop(bottomSheetContext);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tag ID and Date of Birth are required!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
