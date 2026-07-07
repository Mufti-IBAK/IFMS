import 'package:flutter/material.dart';
import '../animals/animal_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../animals/animals_bloc.dart';
import 'widgets/log_breeding_sheet.dart';

class BreedingScreen extends StatelessWidget {
  const BreedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding & Genetics'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const LogBreedingSheet(),
          );
        },
        icon: const Icon(Icons.favorite),
        label: const Text('Log Event'),
      ),
      body: BlocBuilder<AnimalsBloc, AnimalsState>(
        builder: (context, state) {
          if (state is AnimalsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnimalsLoaded) {
            final activeAnimals = state.animals.where((a) {
               final status = ((a is Map ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
               return status != 'dead';
            }).toList();

            final pregnantCount = activeAnimals.where((a) => _getReproStatus(a) == 'pregnant').length;
            final openCount = activeAnimals.where((a) => _getReproStatus(a) == 'active').length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context, pregnantCount, openCount),
                  const SizedBox(height: 24),
                  Text('Pregnant Animals', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...activeAnimals.where((a) => _getReproStatus(a) == 'pregnant').map((a) => _buildAnimalTile(context, a)),
                  const SizedBox(height: 24),
                  Text('Open / Active Animals', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...activeAnimals.where((a) => _getReproStatus(a) == 'active').map((a) => _buildAnimalTile(context, a)),
                ],
              ),
            );
          }
          return const Center(child: Text('Failed to load registry'));
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

  Widget _buildStatsRow(BuildContext context, int pregnant, int open) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Icon(Icons.child_friendly, color: Colors.pink),
                const SizedBox(height: 8),
                Text('$pregnant', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.pink)),
                const Text('Pregnant'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Icon(Icons.pets, color: Colors.blue),
                const SizedBox(height: 8),
                Text('$open', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blue)),
                const Text('Open'),
              ],
            ),
          ),
        ),
      ],
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
        subtitle: Text('Status: ${_getReproStatus(animal).toUpperCase()}'),
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
}
