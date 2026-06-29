import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/utils/report_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/local_db.dart';
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

  IconData _getSpeciesIcon(String sp, String sex) {
    final lowerSp = sp.toLowerCase();
    
    if (lowerSp == 'bovine' || lowerSp == 'cow') return Icons.pets;
    if (lowerSp == 'feline') return Icons.pets_sharp;
    if (lowerSp == 'canine') return Icons.pets;
    if (lowerSp == 'leprine') return Icons.cruelty_free;
    return Icons.agriculture;
  }

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
                    state.animals,
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
            // Apply search query
            final filtered = state.animals.where((animal) {
              if (_searchQuery.isEmpty) return true;
              final isMap = animal is Map;
              
              final tagId = (isMap ? animal['tag_id'] : animal.tagId).toString().toLowerCase();
              final breed = ((isMap ? animal['breed'] : animal.breed) ?? '').toString().toLowerCase();
              final species = (isMap ? animal['species'] : animal.species).toString().toLowerCase();
              final sex = (isMap ? animal['sex'] : animal.sex).toString().toLowerCase();
              final color = ((isMap ? animal['color'] : animal.color) ?? '').toString().toLowerCase();
              final marks = ((isMap ? animal['unique_marks'] : animal.uniqueMarks) ?? '').toString().toLowerCase();
              final purpose = ((isMap ? animal['purpose'] : animal.purpose) ?? '').toString().toLowerCase();
              final pedigree = ((isMap ? animal['pedigree_type'] : animal.pedigreeType) ?? '').toString().toLowerCase();
              final status = ((isMap ? animal['status'] : animal.status) ?? '').toString().toLowerCase();
              final repro = ((isMap ? animal['current_reproductive_status'] : animal.currentReproductiveStatus) ?? '').toString().toLowerCase();
              final vac = ((isMap ? animal['vaccination_status'] : animal.vaccinationStatus) ?? '').toString().toLowerCase();
              final dew = ((isMap ? animal['deworming_status'] : animal.dewormingStatus) ?? '').toString().toLowerCase();
              final weight = (isMap ? animal['weight'] : animal.weight)?.toString().toLowerCase() ?? '';
              
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
              final sp = (animal is Map ? animal['species'] : animal.species).toString().toLowerCase();
              String norm = sp;
              if (sp == 'cow') norm = 'bovine';
              if (sp == 'goat') norm = 'caprine';
              if (sp == 'sheep') norm = 'ovine';
              return norm == _selectedFilter;
            }).toList();

            // Apply sorting
            speciesFiltered.sort((a, b) {
              final isMapA = a is Map;
              final isMapB = b is Map;
              
              dynamic valA;
              dynamic valB;
              
              switch (_sortBy) {
                case 'tag_id':
                  valA = (isMapA ? a['tag_id'] : a.tagId)?.toString() ?? '';
                  valB = (isMapB ? b['tag_id'] : b.tagId)?.toString() ?? '';
                  break;
                case 'sex':
                  valA = (isMapA ? a['sex'] : a.sex)?.toString() ?? '';
                  valB = (isMapB ? b['sex'] : b.sex)?.toString() ?? '';
                  break;
                case 'weight':
                  valA = (isMapA ? a['weight'] : a.weight) ?? 0.0;
                  valB = (isMapB ? b['weight'] : b.weight) ?? 0.0;
                  break;
                case 'species':
                  valA = (isMapA ? a['species'] : a.species)?.toString() ?? '';
                  valB = (isMapB ? b['species'] : b.species)?.toString() ?? '';
                  break;
                case 'breed':
                  valA = (isMapA ? a['breed'] : a.breed)?.toString() ?? '';
                  valB = (isMapB ? b['breed'] : b.breed)?.toString() ?? '';
                  break;
                case 'color':
                  valA = (isMapA ? a['color'] : a.color)?.toString() ?? '';
                  valB = (isMapB ? b['color'] : b.color)?.toString() ?? '';
                  break;
                case 'unique_marks':
                  valA = (isMapA ? a['unique_marks'] : a.uniqueMarks)?.toString() ?? '';
                  valB = (isMapB ? b['unique_marks'] : b.uniqueMarks)?.toString() ?? '';
                  break;
                case 'date_of_birth':
                  final rawA = isMapA ? a['date_of_birth'] : a.dateOfBirth;
                  final rawB = isMapB ? b['date_of_birth'] : b.dateOfBirth;
                  valA = rawA is DateTime ? rawA : (rawA != null ? DateTime.tryParse(rawA.toString()) : null);
                  valB = rawB is DateTime ? rawB : (rawB != null ? DateTime.tryParse(rawB.toString()) : null);
                  break;
                case 'status':
                  valA = (isMapA ? a['status'] : a.status)?.toString() ?? '';
                  valB = (isMapB ? b['status'] : b.status)?.toString() ?? '';
                  break;
                case 'current_reproductive_status':
                  valA = (isMapA ? a['current_reproductive_status'] : a.currentReproductiveStatus)?.toString() ?? '';
                  valB = (isMapB ? b['current_reproductive_status'] : b.currentReproductiveStatus)?.toString() ?? '';
                  break;
                case 'purpose':
                  valA = (isMapA ? a['purpose'] : a.purpose)?.toString() ?? '';
                  valB = (isMapB ? b['purpose'] : b.purpose)?.toString() ?? '';
                  break;
                case 'pedigree_type':
                  valA = (isMapA ? a['pedigree_type'] : a.pedigreeType)?.toString() ?? '';
                  valB = (isMapB ? b['pedigree_type'] : b.pedigreeType)?.toString() ?? '';
                  break;
                case 'vaccination_status':
                  valA = (isMapA ? a['vaccination_status'] : a.vaccinationStatus)?.toString() ?? '';
                  valB = (isMapB ? b['vaccination_status'] : b.vaccinationStatus)?.toString() ?? '';
                  break;
                case 'deworming_status':
                  valA = (isMapA ? a['deworming_status'] : a.dewormingStatus)?.toString() ?? '';
                  valB = (isMapB ? b['deworming_status'] : b.dewormingStatus)?.toString() ?? '';
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
                              final count = grouped[item]?.length ?? 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 0.5),
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
                            final animal = item;
                            final isMap = animal is Map;
                            final id = isMap ? animal['id'] : animal.id;
                            final tagId = isMap ? animal['tag_id'] : animal.tagId;
                            final species = isMap ? animal['species'] : animal.species;
                            final sex = isMap ? animal['sex'] : animal.sex;
                            final breed = (isMap ? animal['breed'] : animal.breed) ?? 'Unknown';
                            final status = (isMap ? animal['current_reproductive_status'] : animal.currentReproductiveStatus) ?? 'Open';
                            final liveStatus = (isMap ? animal['status'] : animal.status) ?? 'active';
                            final isDead = liveStatus.toString().toLowerCase() == 'dead';

                            return Opacity(
                              opacity: isDead ? 0.65 : 1.0,
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
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isDead 
                                              ? Colors.grey.shade100
                                              : (sex.toString().toLowerCase() == 'female' 
                                                  ? Colors.pink.shade50 
                                                  : Colors.blue.shade50),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          isDead 
                                              ? Icons.sentiment_very_dissatisfied
                                              : _getSpeciesIcon(species.toString(), sex.toString()),
                                          color: isDead 
                                              ? Colors.grey
                                              : (sex.toString().toLowerCase() == 'female' 
                                                  ? Colors.pink 
                                                  : Colors.blue),
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
                                      if (!isDead && (species.toString().toLowerCase() == 'bovine' || species.toString().toLowerCase() == 'cow'))
                                        const Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Dairy Barn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                            Text('Yield: 24L', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
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

  Widget _buildFilterChips(List<dynamic> animals) {
    final Map<String, int> speciesCounts = {};
    for (var a in animals) {
      final sp = (a is Map ? a['species'] : a.species).toString().toLowerCase();
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
            label: 'All (${animals.length})',
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
      child: TextField(
        controller: _searchController,
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
    final vaccinationController = TextEditingController();
    final dewormingController = TextEditingController();
    
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
                                        hintText: 'e.g. FMD Vaccine given',
                                        prefixIcon: Icon(Icons.vaccines, size: 20),
                                      ),
                                    ),
                                  ),
                                  buildInputField(
                                    label: 'Deworming Notes',
                                    child: TextField(
                                      controller: dewormingController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Albendazole given',
                                        prefixIcon: Icon(Icons.bug_report, size: 20),
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
                                'deworming_status': dewormingController.text.trim().isNotEmpty ? dewormingController.text.trim() : null,
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

  void _showEditAnimalSheet(BuildContext context, dynamic animal) {
    final isMap = animal is Map;
    final id = isMap ? animal['id'] : animal.id;
    
    final tagController = TextEditingController(text: (isMap ? animal['tag_id'] : animal.tagId) ?? '');
    final breedController = TextEditingController(text: (isMap ? animal['breed'] : animal.breed) ?? '');
    final weightController = TextEditingController(text: (isMap ? animal['weight'] : animal.weight)?.toString() ?? '');
    final colorController = TextEditingController(text: (isMap ? animal['color'] : animal.color) ?? '');
    final marksController = TextEditingController(text: (isMap ? animal['unique_marks'] : animal.uniqueMarks) ?? '');
    final vaccinationController = TextEditingController(text: (isMap ? animal['vaccination_status'] : animal.vaccinationStatus) ?? '');
    final dewormingController = TextEditingController(text: (isMap ? animal['deworming_status'] : animal.dewormingStatus) ?? '');
    
    DateTime? selectedDob;
    final dobRaw = isMap ? animal['date_of_birth'] : animal.dateOfBirth;
    if (dobRaw != null) {
      selectedDob = dobRaw is DateTime ? dobRaw : DateTime.tryParse(dobRaw.toString());
    }

    String selectedSpecies = (isMap ? animal['species'] : animal.species) ?? 'bovine';
    String selectedSex = (isMap ? animal['sex'] : animal.sex) ?? 'female';
    String selectedPedigree = (isMap ? animal['pedigree_type'] : animal.pedigreeType) ?? 'pure';
    String selectedPurpose = (isMap ? animal['purpose'] : animal.purpose) ?? 'milk';
    String selectedReproductive = (isMap ? animal['current_reproductive_status'] : animal.currentReproductiveStatus) ?? 'open';
    String? selectedImagePath = isMap ? animal['image_path'] : animal.imagePath;

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
                                              : FileImage(File(selectedImagePath!)),
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
                                    child: TextField(
                                      controller: breedController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Holstein Friesian',
                                        prefixIcon: Icon(Icons.pets, size: 20),
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
                                          hintText: 'e.g. Brown with spots',
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
                                              if (selected) setState(() => selectedReproductive == 'dry');
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
                                        hintText: 'e.g. FMD Vaccine given',
                                        prefixIcon: Icon(Icons.vaccines, size: 20),
                                      ),
                                    ),
                                  ),
                                  buildInputField(
                                    label: 'Deworming Notes',
                                    child: TextField(
                                      controller: dewormingController,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. Albendazole given',
                                        prefixIcon: Icon(Icons.bug_report, size: 20),
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
                                'vaccination_status': vaccinationController.text.trim().isNotEmpty ? vaccinationController.text.trim() : null,
                                'deworming_status': dewormingController.text.trim().isNotEmpty ? dewormingController.text.trim() : null,
                                'image_path': selectedImagePath,
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
