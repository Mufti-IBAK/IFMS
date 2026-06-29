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
    final speciesController = TextEditingController(text: 'cow');
    final sexController = TextEditingController(text: 'female');
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Animal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() => selectedImagePath = image.path);
                    }
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      image: selectedImagePath != null
                          ? DecorationImage(image: FileImage(File(selectedImagePath!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: selectedImagePath == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: AppColors.outline),
                              Text('Tap to take photo', style: TextStyle(fontSize: 10)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: tagController, decoration: const InputDecoration(labelText: 'Tag ID')),
                TextField(controller: speciesController, decoration: const InputDecoration(labelText: 'Species')),
                TextField(controller: sexController, decoration: const InputDecoration(labelText: 'Sex')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (tagController.text.isNotEmpty) {
                  final dateStr = DateTime.now().toIso8601String().split('T')[0];
                  BlocProvider.of<AnimalsBloc>(context).add(AddAnimal({
                    'tag_id': tagController.text,
                    'species': speciesController.text.toLowerCase(),
                    'sex': sexController.text.toLowerCase(),
                    'date_of_birth': dateStr,
                    'image_path': selectedImagePath,
                  }));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
