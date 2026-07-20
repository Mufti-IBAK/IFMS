import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import '../../core/theme/app_colors.dart';
import '../animals/animal_profile_screen.dart';
import '../animals/animals_bloc.dart';
import 'widgets/log_breeding_sheet.dart';

class BreedingScreen extends StatefulWidget {
  const BreedingScreen({super.key});

  @override
  State<BreedingScreen> createState() => _BreedingScreenState();
}

class _BreedingScreenState extends State<BreedingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding & Genetics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'REGISTRY'),
            Tab(text: 'BREEDING HISTORY'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const LogBreedingSheet(),
          ).then((_) {
            setState(() {});
          });
        },
        icon: const Icon(Icons.favorite),
        label: const Text('Log Event'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegistryTab(context),
          _buildHistoryTab(context),
        ],
      ),
    );
  }

  Widget _buildRegistryTab(BuildContext context) {
    return BlocBuilder<AnimalsBloc, AnimalsState>(
      builder: (context, state) {
        if (state is AnimalsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AnimalsLoaded) {
          final activeAnimals = state.animals.where((a) {
            final status = ((a is Map ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
            return status != 'dead';
          }).toList();

          final int pregnant = activeAnimals.where((a) => _getReproStatus(a) == 'pregnant').length;
          final int lactating = activeAnimals.where((a) => _getReproStatus(a) == 'lactating').length;
          final int dry = activeAnimals.where((a) => _getReproStatus(a) == 'dry').length;
          final int heat = activeAnimals.where((a) => _getReproStatus(a) == 'on_heat' || _getReproStatus(a) == 'heat').length;
          final int synchronized = activeAnimals.where((a) => _getReproStatus(a) == 'synchronized').length;
          final int open = activeAnimals.where((a) => _getReproStatus(a) == 'active' || _getReproStatus(a) == 'open').length;

          // Filter animal list
          final filteredAnimals = activeAnimals.where((a) {
            if (_selectedStatusFilter == 'all') return true;
            final s = _getReproStatus(a);
            if (_selectedStatusFilter == 'open') return s == 'active' || s == 'open';
            if (_selectedStatusFilter == 'on_heat') return s == 'on_heat' || s == 'heat';
            return s == _selectedStatusFilter;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stat Cards Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  _statCard(context, 'Pregnant', pregnant, Colors.pink, 'pregnant'),
                  _statCard(context, 'Lactating', lactating, Colors.teal, 'lactating'),
                  _statCard(context, 'Dry', dry, Colors.orange, 'dry'),
                  _statCard(context, 'On Heat', heat, Colors.red, 'on_heat'),
                  _statCard(context, 'Synchronized', synchronized, Colors.purple, 'synchronized'),
                  _statCard(context, 'Open', open, Colors.blue, 'open'),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('all', 'All Animals (${activeAnimals.length})'),
                    _filterChip('pregnant', 'Pregnant ($pregnant)'),
                    _filterChip('lactating', 'Lactating ($lactating)'),
                    _filterChip('dry', 'Dry ($dry)'),
                    _filterChip('on_heat', 'On Heat ($heat)'),
                    _filterChip('synchronized', 'Synchronized ($synchronized)'),
                    _filterChip('open', 'Open ($open)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Animal Registry (${_selectedStatusFilter.replaceAll('_', ' ').toUpperCase()})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
              ),
              const SizedBox(height: 10),

              if (filteredAnimals.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No animals matching this reproductive status.'),
                  ),
                )
              else
                ...filteredAnimals.map((a) => _buildAnimalTile(context, a)),
            ],
          );
        }
        return const Center(child: Text('Failed to load registry'));
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final db = sl<LocalDatabase>();

    return FutureBuilder<List<LocalBreedingEvent>>(
      future: (db.select(db.localBreedingEvents)..orderBy([(t) => drift.OrderingTerm(expression: t.eventDate, mode: drift.OrderingMode.desc)])).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No breeding events logged yet. Tap "+ Log Event" below to register one.', textAlign: TextAlign.center),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (ctx, idx) {
            final ev = events[idx];
            
            // Decode payload details if any
            Map<String, dynamic>? meta;
            if (ev.payload != null && ev.payload!.startsWith('{')) {
              try {
                meta = jsonDecode(ev.payload!);
              } catch (_) {}
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ev.eventType.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FutureBuilder<dynamic>(
                            future: (db.select(db.localAnimals)..where((t) => t.id.equals(ev.animalId))).getSingleOrNull(),
                            builder: (context, animSnap) {
                              final tag = animSnap.data?.tagId ?? 'Loading...';
                              return Text(
                                'Animal: $tag',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (ev.sireId != null && ev.sireId!.isNotEmpty) ...[
                      FutureBuilder<dynamic>(
                        future: (db.select(db.localAnimals)..where((t) => t.id.equals(ev.sireId!))).getSingleOrNull(),
                        builder: (context, sireSnap) {
                          final tag = sireSnap.data?.tagId ?? 'Sire';
                          return Text('Sire / Semen ID: $tag', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500));
                        },
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (ev.result != null && ev.result!.isNotEmpty) ...[
                      Text('Result: ${ev.result!.toUpperCase()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 4),
                    ],

                    // Protocol synchronization details
                    if (ev.eventType == 'estrus_synchronization' && meta != null) ...[
                      Text('Protocol: ${meta['protocol']?.toString().toUpperCase()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('Injection Date: ${meta['injectionDate']?.toString().substring(0, 10)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text('Expected Estrus: ${meta['expectedEstrusDate']?.toString().substring(0, 10)} (${meta['estrusPeriod']?.toString().toUpperCase()})', style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                    ],

                    if (ev.notes != null && ev.notes!.isNotEmpty) ...[
                      Text('Notes: ${ev.notes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                    ],
                    const Divider(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(ev.eventDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statCard(BuildContext context, String title, int count, Color color, String filterKey) {
    final bool isSelected = _selectedStatusFilter == filterKey;

    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 2) : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final bool isSelected = _selectedStatusFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _selectedStatusFilter = filterKey);
        },
      ),
    );
  }

  Widget _buildAnimalTile(BuildContext context, dynamic animal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          child: const Icon(Icons.pets, color: AppColors.primary),
        ),
        title: Text(_getTag(animal)),
        subtitle: Text('Reproductive: ${_getReproStatus(animal).toUpperCase()}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimalProfileScreen(animal: animal),
            ),
          );
        },
      ),
    );
  }

  String _getReproStatus(dynamic animal) {
    if (animal is Map) return animal['currentReproductiveStatus'] ?? 'active';
    return animal.currentReproductiveStatus ?? 'active';
  }

  String _getTag(dynamic animal) {
    if (animal is Map) return animal['tagId'] ?? '';
    return animal.tagId ?? '';
  }
}
