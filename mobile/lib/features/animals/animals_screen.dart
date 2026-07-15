import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/report_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/di/service_locator.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/database/local_db.dart';
import 'package:ifms_mobile/features/pharmacy/pharmacy_repository.dart';
import 'package:ifms_mobile/core/widgets/animal_silhouette.dart';
import 'animal_profile_screen.dart';
import 'animals_bloc.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  String _sortBy = 'tag_id';
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getSpeciesDisplayName(String sp) {
    switch (sp.toLowerCase()) {
      case 'bovine':
      case 'cow':
        return 'Cattle';
      case 'avian':
        return 'Avian';
      case 'caprine':
      case 'goat':
        return 'Goats';
      case 'ovine':
      case 'sheep':
        return 'Sheep';
      case 'feline':
        return 'Cats';
      case 'canine':
        return 'Dogs';
      case 'leprine':
        return 'Rabbits';
      default:
        return sp.isNotEmpty ? (sp[0].toUpperCase() + sp.substring(1)) : 'Others';
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFMS FARM REGISTRY PRO'),
        actions: [
          BlocBuilder<AnimalsBloc, AnimalsState>(
            builder: (context, state) {
              if (state is AnimalsLoaded) {
                return IconButton(
                  onPressed: () => ReportService.generateHerdReport(
                    state.animals.cast<LocalAnimal>(),
                  ),
                  icon: const Icon(Icons.picture_as_pdf),
                );
              }
              return const SizedBox();
            },
          ),
          IconButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Synchronizing records with Namanzo Farms cloud...'),
                  duration: Duration(seconds: 1),
                ),
              );
              // Trigger local-to-remote queue sync
              await sl<SyncManager>().triggerSync();
              // Reload page data
              if (context.mounted) {
                BlocProvider.of<AnimalsBloc>(context).add(LoadAnimals());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Synchronization complete!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            icon: const Icon(Icons.sync, color: AppColors.info),
          ),
        ],
      ),
      body: BlocConsumer<AnimalsBloc, AnimalsState>(
        listener: (context, state) {
          if (state is AnimalsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnimalsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimalsLoaded) {
            // Apply search query
            final filtered = state.animals.where((animal) {
              if (_searchQuery.isEmpty) return true;
              
              final tagId = animal.tagId.toString().toLowerCase();
              final breed = (animal.breed ?? '').toString().toLowerCase();
              final species = animal.species.toString().toLowerCase();
              final sex = animal.sex.toString().toLowerCase();
              final color = (animal.color ?? '').toString().toLowerCase();
              final marks = (animal.uniqueMarks ?? '').toString().toLowerCase();
              final purpose = (animal.purpose ?? '').toString().toLowerCase();
              final pedigree = (animal.pedigreeType ?? '').toString().toLowerCase();
              final status = (animal.status ?? '').toString().toLowerCase();
              final repro = (animal.currentReproductiveStatus ?? '').toString().toLowerCase();
              final vac = (animal.vaccinationStatus ?? '').toString().toLowerCase();
              final dew = (animal.dewormingStatus ?? '').toString().toLowerCase();
              final weight = animal.weight?.toString().toLowerCase() ?? '';
              
              return tagId.contains(_searchQuery) ||
                  breed.contains(_searchQuery) ||
                  species.contains(_searchQuery) ||
                  sex.contains(_searchQuery) ||
                  color.contains(_searchQuery) ||
                  marks.contains(_searchQuery) ||
                  purpose.contains(_searchQuery) ||
                  pedigree.contains(_searchQuery) ||
                  status.contains(_searchQuery) ||
                  repro.contains(_searchQuery) ||
                  vac.contains(_searchQuery) ||
                  dew.contains(_searchQuery) ||
                  weight.contains(_searchQuery);
            }).toList();

            // Apply species filter
            final speciesFiltered = filtered.where((animal) {
              if (_selectedFilter == 'all') return true;
              final sp = animal.species.toString().toLowerCase();
              String norm = sp;
              if (sp == 'cow') norm = 'bovine';
              if (sp == 'goat') norm = 'caprine';
              if (sp == 'sheep') norm = 'ovine';
              return norm == _selectedFilter;
            }).toList();

            // Apply sorting
            speciesFiltered.sort((a, b) {
              dynamic valA;
              dynamic valB;
              
              switch (_sortBy) {
                case 'tag_id':
                  valA = a.tagId.toString();
                  valB = b.tagId.toString();
                  break;
                case 'sex':
                  valA = a.sex.toString();
                  valB = b.sex.toString();
                  break;
                case 'weight':
                  valA = a.weight ?? 0.0;
                  valB = b.weight ?? 0.0;
                  break;
                case 'species':
                  valA = a.species.toString();
                  valB = b.species.toString();
                  break;
                case 'breed':
                  valA = a.breed?.toString() ?? '';
                  valB = b.breed?.toString() ?? '';
                  break;
                case 'color':
                  valA = a.color?.toString() ?? '';
                  valB = b.color?.toString() ?? '';
                  break;
                case 'unique_marks':
                  valA = a.uniqueMarks?.toString() ?? '';
                  valB = b.uniqueMarks?.toString() ?? '';
                  break;
                case 'date_of_birth':
                  valA = a.dateOfBirth;
                  valB = b.dateOfBirth;
                  break;
                case 'status':
                  valA = a.status.toString();
                  valB = b.status.toString();
                  break;
                case 'current_reproductive_status':
                  valA = a.currentReproductiveStatus.toString();
                  valB = b.currentReproductiveStatus.toString();
                  break;
                case 'purpose':
                  valA = a.purpose?.toString() ?? '';
                  valB = b.purpose?.toString() ?? '';
                  break;
                case 'pedigree_type':
                  valA = a.pedigreeType?.toString() ?? '';
                  valB = b.pedigreeType?.toString() ?? '';
                  break;
                case 'vaccination_status':
                  valA = a.vaccinationStatus?.toString() ?? '';
                  valB = b.vaccinationStatus?.toString() ?? '';
                  break;
                case 'deworming_status':
                  valA = a.dewormingStatus?.toString() ?? '';
                  valB = b.dewormingStatus?.toString() ?? '';
                  break;
                default:
                  valA = '';
                  valB = '';
              }
              
              int comparison;
              if (valA is Comparable && valB is Comparable) {
                comparison = valA.compareTo(valB);
              } else if (valA is num && valB is num) {
                comparison = valA.compareTo(valB);
              } else if (valA is DateTime && valB is DateTime) {
                comparison = valA.compareTo(valB);
              } else if (valA == null && valB != null) {
                comparison = -1;
              } else if (valA != null && valB == null) {
                comparison = 1;
              } else {
                comparison = 0;
              }
              
              return _sortAscending ? comparison : -comparison;
            });

            // Group by species
            final Map<String, List<dynamic>> grouped = {};
            for (var animal in speciesFiltered) {
              final sp = (animal is Map ? animal['species'] : animal.species).toString().toLowerCase();
              String norm = sp;
              if (sp == 'cow') norm = 'bovine';
              if (sp == 'goat') norm = 'caprine';
              if (sp == 'sheep') norm = 'ovine';
              grouped.putIfAbsent(norm, () => []).add(animal);
            }

            // Flatten into list items
            final List<dynamic> items = [];
            grouped.forEach((speciesKey, animalList) {
              items.add(speciesKey); // Header string
              items.addAll(animalList); // animal entries
            });

            return Column(
              children: [
                _buildFilterChips(state.animals),
                _buildSearchBar(),
                _buildSortOptionsBar(),
                const SizedBox(height: 8),
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
                  child: items.isEmpty
                      ? const Center(child: Text('No matching animals found.'))
                      : ListView.builder(
                          itemCount: items.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            // Section Header UI
                            if (item is String) {
                              final displayName = _getSpeciesDisplayName(item).toUpperCase();
                              final count = grouped[item]?.where((a) {
                                final status = (a.status ?? 'active').toString().toLowerCase();
                                return status != 'dead';
                              }).length ?? 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 0.5),
                                      ),
                                      child: Text(
                                        '$displayName ($count)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 0.5)),
                                  ],
                                ),
                              );
                            }

                            // Animal Card UI
                            final animal = item as LocalAnimal;
                            final id = animal.id;
                            final tagId = animal.tagId;
                            final species = animal.species;
                            final sex = animal.sex;
                            final breed = animal.breed ?? 'Unknown';
                            final status = animal.currentReproductiveStatus;
                            final liveStatus = animal.status;
                            final isDead = liveStatus.toString().toLowerCase() == 'dead';
                            final imagePath = animal.imagePath;

                            return Opacity(
                              opacity: isDead ? 0.65 : 1.0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnimalProfileScreen(animal: animal),
                                    ),
                                  ).then((_) {
                                    if (context.mounted) {
                                      BlocProvider.of<AnimalsBloc>(context).add(LoadAnimals());
                                    }
                                  });
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isDead ? Colors.grey.shade300 : AppColors.outlineVariant,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                      imagePath == null
                                          ? AnimalSilhouette(
                                              species: species.toString(),
                                              sex: sex.toString(),
                                              size: 48,
                                              backgroundColor: isDead ? Colors.grey.shade100 : null,
                                              color: isDead ? Colors.grey : null,
                                            )
                                          : Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: isDead 
                                                    ? Colors.grey.shade100
                                                    : (sex.toString().toLowerCase() == 'female' 
                                                        ? Colors.pink.shade50 
                                                        : Colors.blue.shade50),
                                                borderRadius: BorderRadius.circular(12),
                                                image: DecorationImage(
                                                  image: imagePath.startsWith('http')
                                                      ? NetworkImage(imagePath) as ImageProvider
                                                      : imagePath.startsWith('/uploads')
                                                          ? NetworkImage('${ApiClient.baseUrl.replaceAll('/api/v1', '')}$imagePath')
                                                          : FileImage(File(imagePath)) as ImageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),

                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '#$tagId',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                FutureBuilder<List<LocalAnimalMedicalRecord>>(
                                                  future: sl<PharmacyRepository>().getMedicalRecords(animalId: id),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) return const SizedBox();
                                                    final records = snapshot.data!;
                                                    final hasActiveWithdrawal = records.any((r) => r.withdrawalEndDate != null && r.withdrawalEndDate!.isAfter(DateTime.now()));
                                                    if (!hasActiveWithdrawal) return const SizedBox();
                                                    return Container(
                                                      margin: const EdgeInsets.only(left: 8),
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.warning, color: Colors.orange, size: 10),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'WITHDRAWAL',
                                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (isDead) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text(
                                                      'DECEASED',
                                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isDead ? 'Status: Deceased' : '$breed • ${status.toString().toUpperCase()}',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isDead ? Colors.grey : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isDead) ...[
                                        Builder(
                                          builder: (context) {
                                            final lowerSpecies = species.toString().toLowerCase();
                                            final lowerSex = sex.toString().toLowerCase();
                                            final lowerRepro = status.toString().toLowerCase();
                                            final lowerPurpose = animal.purpose?.toString().toLowerCase() ?? '';

                                            String line1 = '';
                                            String line2 = '';
                                            Color color2 = AppColors.primary;

                                            if (lowerSpecies == 'bovine' || lowerSpecies == 'cow') {
                                              if (lowerSex == 'female') {
                                                if (lowerRepro == 'lactating') {
                                                  line1 = 'Dairy Barn';
                                                  line2 = 'Lactating';
                                                } else if (lowerRepro == 'pregnant') {
                                                  line1 = 'Breeding Barn';
                                                  line2 = 'Pregnant';
                                                  color2 = Colors.pink;
                                                } else {
                                                  line1 = 'Dairy Barn';
                                                  line2 = 'Dry / Open';
                                                  color2 = Colors.orange;
                                                }
                                              } else {
                                                line1 = 'Bull Barn';
                                                line2 = 'Stud / Sire';
                                                color2 = Colors.blue;
                                              }
                                            } else if (lowerSpecies == 'avian' || lowerSpecies == 'poultry') {
                                              line1 = 'Poultry';
                                              if (lowerPurpose == 'eggs') {
                                                line1 = 'Layers';
                                                line2 = 'Egg Prod';
                                              } else if (lowerPurpose == 'meat') {
                                                line1 = 'Broilers';
                                                line2 = 'Meat Prod';
                                              } else {
                                                line2 = 'Active';
                                              }
                                            } else {
                                              // Fallback for other species
                                              if (lowerPurpose == 'meat') {
                                                line1 = 'Meat Barn';
                                                line2 = 'Growth: OK';
                                              } else if (lowerPurpose == 'breeding') {
                                                line1 = 'Breeding';
                                                line2 = lowerRepro == 'pregnant' ? 'Pregnant' : 'Active';
                                                if (lowerRepro == 'pregnant') color2 = Colors.pink;
                                              } else {
                                                line1 = lowerPurpose.isNotEmpty ? (lowerPurpose[0].toUpperCase() + lowerPurpose.substring(1)) : 'General';
                                                line2 = lowerRepro.isNotEmpty ? (lowerRepro[0].toUpperCase() + lowerRepro.substring(1)) : 'Active';
                                              }
                                            }

                                            if (line1.isEmpty) return const SizedBox();

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(line1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                                Text(line2, style: TextStyle(fontSize: 11, color: color2, fontWeight: FontWeight.bold)),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20),
                                        onSelected: (action) {
                                          if (action == 'edit') {
                                            _showEditAnimalSheet(context, animal);
                                          } else if (action == 'dead') {
                                            _confirmMarkDead(context, id, tagId);
                                          } else if (action == 'delete') {
                                            _confirmDelete(context, id, tagId);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          if (!isDead)
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Edit Info'),
                                                ],
                                              ),
                                            ),
                                          if (!isDead)
                                            const PopupMenuItem(
                                              value: 'dead',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.heart_broken, size: 18, color: Colors.orange),
                                                  SizedBox(width: 8),
                                                  Text('Mark Deceased'),
                                                ],
                                              ),
                                            ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, size: 18, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Delete Record', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                          },
                        ),
                ),
              ],
            );
          } else if (state is AnimalsError) {
            // Error is handled by listener, but we return a temporary loading indicator
            // because AnimalsBloc immediately fires LoadAnimals() after emitting an error.
            return const Center(child: CircularProgressIndicator());
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

  Widget _buildFilterChips(List<dynamic> animalsList) {
    final List<LocalAnimal> animals = animalsList.cast<LocalAnimal>();
    final activeAnimals = animals.where((a) {
      final status = a.status.toLowerCase();
      return status != 'dead';
    }).toList();

    final Map<String, int> speciesCounts = {};
    for (var a in activeAnimals) {
      final sp = a.species.toString().toLowerCase();
      String norm = sp;
      if (sp == 'cow') norm = 'bovine';
      if (sp == 'goat') norm = 'caprine';
      if (sp == 'sheep') norm = 'ovine';
      speciesCounts[norm] = (speciesCounts[norm] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _filterChip(
            label: 'All (${activeAnimals.length})',
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          ...speciesCounts.entries.map((entry) {
            final speciesKey = entry.key;
            final count = entry.value;
            return _filterChip(
              label: '${_getSpeciesDisplayName(speciesKey)} ($count)',
              isSelected: _selectedFilter == speciesKey,
              onTap: () => setState(() => _selectedFilter = speciesKey),
            );
          }),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) => onTap(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(textCapitalization: TextCapitalization.sentences, controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Tag or Breed...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : const Icon(Icons.qr_code_scanner),
        ),
        onChanged: (val) {
          setState(() => _searchQuery = val.trim().toLowerCase());
        },
      ),
    );
  }

  Widget _buildSortOptionsBar() {
    final Map<String, String> sortFields = {
      'tag_id': 'Tag Number',
      'sex': 'Sex',
      'weight': 'Weight',
      'species': 'Species',
      'breed': 'Breed',
      'color': 'Color',
      'unique_marks': 'Unique Marks',
      'date_of_birth': 'Age / DOB',
      'status': 'Status',
      'current_reproductive_status': 'Repro Status',
      'purpose': 'Purpose',
      'pedigree_type': 'Pedigree',
      'vaccination_status': 'Vaccination Notes',
      'deworming_status': 'Deworming Notes',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.sort, size: 18, color: AppColors.outline),
              const SizedBox(width: 8),
              const Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              PopupMenuButton<String>(
                initialValue: _sortBy,
                onSelected: (val) => setState(() => _sortBy = val),
                child: Text(
                  sortFields[_sortBy] ?? 'Tag Number',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                itemBuilder: (context) => sortFields.entries.map((e) => PopupMenuItem(
                  value: e.key,
                  child: Text(e.value, style: const TextStyle(fontSize: 13)),
                )).toList(),
              ),
            ],
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18,
              color: AppColors.primary,
            ),
            onPressed: () => setState(() => _sortAscending = !_sortAscending),
          ),
        ],
      ),
    );
  }

  void _showAddAnimalDialog(BuildContext context) {
    final tagController = TextEditingController();
    final breedController = TextEditingController();
    final weightController = TextEditingController();
    final colorController = TextEditingController();
    final marksController = TextEditingController();
    final acquisitionCostController = TextEditingController();
    final salvageValueController = TextEditingController();

    DateTime? selectedDob;
    bool dobUnknown = false;
    final estimatedAgeController = TextEditingController(text: '1');
    String estimatedAgeUnit = 'Years';
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
              children: [
                w1,
                const SizedBox(height: 12),
                w2,
              ],
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                                      ? DecorationImage(
                                          image: selectedImagePath!.startsWith('http')
                                              ? NetworkImage(selectedImagePath!) as ImageProvider
                                              : selectedImagePath!.startsWith('/uploads')
                                                  ? NetworkImage('${ApiClient.baseUrl.replaceAll('/api/v1', '')}$selectedImagePath')
                                                  : FileImage(File(selectedImagePath!)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
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
                                    child: TextField(textCapitalization: TextCapitalization.sentences, controller: tagController,
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
                                        initialValue: selectedSpecies,
                                        items: const [
                                          DropdownMenuItem(value: 'bovine', child: Text('Bovine (Cattle)')),
                                          DropdownMenuItem(value: 'avian', child: Text('Avian (Poultry)')),
                                          DropdownMenuItem(value: 'caprine', child: Text('Caprine (Goat)')),
                                          DropdownMenuItem(value: 'ovine', child: Text('Ovine (Sheep)')),
                                          DropdownMenuItem(value: 'feline', child: Text('Feline (Cat)')),
                                          DropdownMenuItem(value: 'canine', child: Text('Canine (Dog)')),
                                          DropdownMenuItem(value: 'leprine', child: Text('Leprine (Rabbit)')),
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
                                    child: TextField(textCapitalization: TextCapitalization.sentences, controller: breedController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Holstein Friesian / Cobb 500',
                                        prefixIcon: Icon(Icons.category, size: 20),
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
                                        FocusScope.of(context).unfocus();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now().subtract(const Duration(days: 365)),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            selectedDob = picked;
                                            dobUnknown = false;
                                          });
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
                                              dobUnknown
                                                  ? 'Not Known'
                                                  : (selectedDob == null
                                                      ? 'Choose Date'
                                                      : selectedDob!.toLocal().toString().split(' ')[0]),
                                              style: TextStyle(
                                                color: (selectedDob == null && !dobUnknown) ? AppColors.outline : AppColors.onSurface,
                                              ),
                                            ),
                                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: dobUnknown,
                                          onChanged: (val) {
                                            setState(() {
                                              dobUnknown = val ?? false;
                                              if (dobUnknown) {
                                                selectedDob = null;
                                              } else {
                                                selectedDob = DateTime.now().subtract(const Duration(days: 365));
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Date of birth unknown / unrecorded', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                  if (dobUnknown) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: buildInputField(
                                            label: 'Estimated Age *',
                                            child: TextField(
                                              controller: estimatedAgeController,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                hintText: 'e.g. 2',
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: buildInputField(
                                            label: 'Age Unit *',
                                            child: DropdownButtonFormField<String>(
                                              value: estimatedAgeUnit,
                                              items: const [
                                                DropdownMenuItem(value: 'Years', child: Text('Years')),
                                                DropdownMenuItem(value: 'Months', child: Text('Months')),
                                                DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                                                DropdownMenuItem(value: 'Days', child: Text('Days')),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(() {
                                                    estimatedAgeUnit = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  
                                  buildRowIfResponsive(
                                    buildInputField(
                                      label: 'Weight (kg)',
                                      child: TextField(textCapitalization: TextCapitalization.sentences, controller: weightController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 350.2',
                                          prefixIcon: Icon(Icons.scale, size: 20),
                                        ),
                                      ),
                                    ),
                                    buildInputField(
                                      label: 'Color / Pattern',
                                      child: TextField(textCapitalization: TextCapitalization.sentences, controller: colorController,
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Brown with white spot',
                                          prefixIcon: Icon(Icons.palette, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  buildInputField(
                                    label: 'Unique Distinguishing Marks',
                                    child: TextField(textCapitalization: TextCapitalization.sentences, controller: marksController,
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
                                        initialValue: selectedPurpose,
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
                                  // Removed Vaccination and Deworming UI as it is now in the Schedules tab
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Financial Card
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
                                  const Text('4. FINANCIAL DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const SizedBox(height: 12),
                                  buildRowIfResponsive(
                                    buildInputField(
                                      label: 'Acquisition Price (NGN)',
                                      child: TextField(
                                        controller: acquisitionCostController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 150000',
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('₦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    buildInputField(
                                      label: 'Salvage Value (NGN)',
                                      child: TextField(
                                        controller: salvageValueController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 50000',
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('₦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                                          ),
                                        ),
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
                            if (tagController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tag ID is required!')),
                              );
                              return;
                            }
                            DateTime finalDob;
                            if (dobUnknown) {
                              final val = double.tryParse(estimatedAgeController.text) ?? 1.0;
                              if (estimatedAgeUnit == 'Years') {
                                finalDob = DateTime.now().subtract(Duration(days: (val * 365.25).round()));
                              } else if (estimatedAgeUnit == 'Months') {
                                finalDob = DateTime.now().subtract(Duration(days: (val * 30.4).round()));
                              } else if (estimatedAgeUnit == 'Weeks') {
                                finalDob = DateTime.now().subtract(Duration(days: (val * 7).round()));
                              } else {
                                finalDob = DateTime.now().subtract(Duration(days: val.round()));
                              }
                            } else {
                              if (selectedDob == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Date of birth is required!')),
                                );
                                return;
                              }
                              finalDob = selectedDob!;
                            }
                            final dobStr = finalDob.toIso8601String().split('T')[0];
                            final newId = const Uuid().v4();
                            
                            BlocProvider.of<AnimalsBloc>(context).add(AddAnimal({
                              'id': newId,
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
                              'vaccination_status': '{}',
                              'deworming_status': '{}',
                              'image_path': selectedImagePath,
                              'acquisition_cost': acquisitionCostController.text.trim().isNotEmpty ? double.tryParse(acquisitionCostController.text.trim()) : 0.0,
                              'salvage_value': salvageValueController.text.trim().isNotEmpty ? double.tryParse(salvageValueController.text.trim()) : 0.0,
                            }));
                            Navigator.pop(bottomSheetContext);
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

  void _showEditAnimalSheet(BuildContext context, dynamic animalData) {
    final animal = animalData as LocalAnimal;
    final id = animal.id;
    
    final tagController = TextEditingController(text: animal.tagId);
    final breedController = TextEditingController(text: animal.breed ?? '');
    final weightController = TextEditingController(text: animal.weight?.toString() ?? '');
    final colorController = TextEditingController(text: animal.color ?? '');
    final marksController = TextEditingController(text: animal.uniqueMarks ?? '');
    final acquisitionCostController = TextEditingController(text: animal.acquisitionCost.toString());
    final salvageValueController = TextEditingController(text: animal.salvageValue.toString());

    DateTime? selectedDob = animal.dateOfBirth;
    bool dobUnknown = false;
    final estimatedAgeController = TextEditingController(text: '1');
    String estimatedAgeUnit = 'Years';

    String selectedSpecies = animal.species;
    String selectedSex = animal.sex;
    String selectedPedigree = animal.pedigreeType ?? 'pure';
    String selectedPurpose = animal.purpose ?? 'milk';
    String selectedReproductive = animal.currentReproductiveStatus;
    String? selectedImagePath = animal.imagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setState) {
          final media = MediaQuery.of(context);
          final isTablet = media.size.width > 600;
          final isFemale = selectedSex == 'female';

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
              children: [
                w1,
                const SizedBox(height: 12),
                w2,
              ],
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Update Animal Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      ? DecorationImage(
                                          image: selectedImagePath!.startsWith('http')
                                              ? NetworkImage(selectedImagePath!) as ImageProvider
                                              : selectedImagePath!.startsWith('/uploads')
                                                  ? NetworkImage('${ApiClient.baseUrl.replaceAll('/api/v1', '')}$selectedImagePath')
                                                  : FileImage(File(selectedImagePath!)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
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
                                    child: TextField(textCapitalization: TextCapitalization.sentences, controller: tagController,
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
                                        initialValue: selectedSpecies,
                                        items: const [
                                          DropdownMenuItem(value: 'bovine', child: Text('Bovine (Cattle)')),
                                          DropdownMenuItem(value: 'avian', child: Text('Avian (Poultry)')),
                                          DropdownMenuItem(value: 'caprine', child: Text('Caprine (Goat)')),
                                          DropdownMenuItem(value: 'ovine', child: Text('Ovine (Sheep)')),
                                          DropdownMenuItem(value: 'feline', child: Text('Feline (Cat)')),
                                          DropdownMenuItem(value: 'canine', child: Text('Canine (Dog)')),
                                          DropdownMenuItem(value: 'leprine', child: Text('Leprine (Rabbit)')),
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
                                    child: TextField(textCapitalization: TextCapitalization.sentences, controller: breedController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Holstein Friesian',
                                        prefixIcon: Icon(Icons.category, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                          initialDate: selectedDob ?? DateTime.now().subtract(const Duration(days: 365)),
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
                                              dobUnknown
                                                  ? 'Not Known'
                                                  : (selectedDob == null
                                                      ? 'Choose Date'
                                                      : selectedDob!.toLocal().toString().split(' ')[0]),
                                              style: TextStyle(
                                                color: (selectedDob == null && !dobUnknown) ? AppColors.outline : AppColors.onSurface,
                                              ),
                                            ),
                                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: dobUnknown,
                                          onChanged: (val) {
                                            setState(() {
                                              dobUnknown = val ?? false;
                                              if (dobUnknown) {
                                                selectedDob = null;
                                              } else {
                                                selectedDob = DateTime.now().subtract(const Duration(days: 365));
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Date of birth unknown / unrecorded', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                  if (dobUnknown) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: buildInputField(
                                            label: 'Estimated Age *',
                                            child: TextField(
                                              controller: estimatedAgeController,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                hintText: 'e.g. 2',
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: buildInputField(
                                            label: 'Age Unit *',
                                            child: DropdownButtonFormField<String>(
                                              value: estimatedAgeUnit,
                                              items: const [
                                                DropdownMenuItem(value: 'Years', child: Text('Years')),
                                                DropdownMenuItem(value: 'Months', child: Text('Months')),
                                                DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                                                DropdownMenuItem(value: 'Days', child: Text('Days')),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(() {
                                                    estimatedAgeUnit = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  buildRowIfResponsive(
                                    buildInputField(
                                      label: 'Weight (kg)',
                                      child: TextField(textCapitalization: TextCapitalization.sentences, controller: weightController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 350.2',
                                          prefixIcon: Icon(Icons.scale, size: 20),
                                        ),
                                      ),
                                    ),
                                    buildInputField(
                                      label: 'Color / Pattern',
                                      child: TextField(textCapitalization: TextCapitalization.sentences, controller: colorController,
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Brown with spots',
                                          prefixIcon: Icon(Icons.palette, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  buildInputField(
                                    label: 'Unique Distinguishing Marks',
                                    child: TextField(textCapitalization: TextCapitalization.sentences, controller: marksController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Notch on left ear',
                                        prefixIcon: Icon(Icons.visibility, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                        initialValue: selectedPurpose,
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
                                            label: const Text('Open'),
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
                                  // Removed Vaccination and Deworming UI as it is now in the Schedules tab
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Financial Card
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
                                  const Text('4. FINANCIAL DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const SizedBox(height: 12),
                                  buildRowIfResponsive(
                                    buildInputField(
                                      label: 'Acquisition Price (NGN)',
                                      child: TextField(
                                        controller: acquisitionCostController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 150000',
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('₦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    buildInputField(
                                      label: 'Salvage Value (NGN)',
                                      child: TextField(
                                        controller: salvageValueController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 50000',
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('₦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<List<dynamic>>(
                            future: Future.wait([
                              sl<PharmacyRepository>().getMedicalRecords(animalId: id),
                              sl<PharmacyRepository>().getMedications(),
                            ]),
                            builder: (ctx, snap) {
                              if (!snap.hasData) {
                                return const SizedBox();
                              }
                              final records = snap.data![0] as List<LocalAnimalMedicalRecord>;
                              final meds = snap.data![1] as List<LocalMedication>;

                              if (records.isEmpty) {
                                return const SizedBox();
                              }

                              final totalMedCost = records.fold<double>(0.0, (s, r) => s + r.cost);

                              return Card(
                                elevation: 0,
                                color: AppColors.surfaceContainerLow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Medical & Treatment History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(
                                            'Total Cost: ₦ ${totalMedCost.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: records.length,
                                        separatorBuilder: (_, __) => const Divider(height: 12, thickness: 0.5),
                                        itemBuilder: (context, idx) {
                                          final rec = records[idx];
                                          final med = meds.firstWhere((m) => m.id == rec.medicationId,
                                              orElse: () => LocalMedication(
                                                    id: rec.medicationId,
                                                    name: 'Medication',
                                                    category: 'other',
                                                    unit: 'units',
                                                    currentStock: 0,
                                                    reorderThreshold: 0,
                                                    costPerUnit: 0,
                                                    isActive: true,
                                                    milkWithdrawalDays: 0,
                                                    meatWithdrawalDays: 0,
                                                  ));
                                          final hasWithdrawal = rec.withdrawalEndDate != null && rec.withdrawalEndDate!.isAfter(DateTime.now());

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(rec.diagnosedCondition, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  Text('₦ ${rec.cost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${rec.administeredDose} ${med.unit} of ${med.name} on ${DateFormat('yyyy-MM-dd').format(rec.treatmentDate)}',
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                              if (hasWithdrawal) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.warning, color: Colors.orange, size: 12),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Active Withdrawal: ends ${DateFormat('yyyy-MM-dd').format(rec.withdrawalEndDate!)}',
                                                      style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
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
                            if (tagController.text.isNotEmpty) {
                              DateTime finalDob;
                              if (dobUnknown) {
                                final val = double.tryParse(estimatedAgeController.text) ?? 1.0;
                                if (estimatedAgeUnit == 'Years') {
                                  finalDob = DateTime.now().subtract(Duration(days: (val * 365.25).round()));
                                } else if (estimatedAgeUnit == 'Months') {
                                  finalDob = DateTime.now().subtract(Duration(days: (val * 30.4).round()));
                                } else if (estimatedAgeUnit == 'Weeks') {
                                  finalDob = DateTime.now().subtract(Duration(days: (val * 7).round()));
                                } else {
                                  finalDob = DateTime.now().subtract(Duration(days: val.round()));
                                }
                              } else {
                                if (selectedDob == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Date of birth is required!')),
                                  );
                                  return;
                                }
                                finalDob = selectedDob!;
                              }
                              final dobStr = finalDob.toIso8601String().split('T')[0];
                              
                              BlocProvider.of<AnimalsBloc>(context).add(UpdateAnimal(id, {
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
                                'image_path': selectedImagePath,
                                'acquisition_cost': acquisitionCostController.text.isNotEmpty ? double.tryParse(acquisitionCostController.text) : 0.0,
                                'salvage_value': salvageValueController.text.isNotEmpty ? double.tryParse(salvageValueController.text) : 0.0,
                              }));
                              Navigator.pop(bottomSheetContext);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Update'),
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


  void _confirmMarkDead(BuildContext context, String id, String tagId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Deceased Status'),
        content: Text('Are you sure you want to mark animal #$tagId as deceased? This will declare it dead in reports and stop recording production cycles.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<AnimalsBloc>(context).add(UpdateAnimal(id, {'status': 'dead'}));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String tagId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Animal Record'),
        content: Text('Are you sure you want to permanently delete animal #$tagId? This will remove all history and should only be used to correct errors.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<AnimalsBloc>(context).add(DeleteAnimal(id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
