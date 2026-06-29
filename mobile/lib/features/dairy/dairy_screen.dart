import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'dairy_bloc.dart';

class DairyScreen extends StatelessWidget {
  const DairyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAIRY INTELLIGENCE'),
      ),
      body: BlocBuilder<DairyBloc, DairyState>(
        builder: (context, state) {
          if (state is DairyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DairyLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSafetyWarning(),
                  const SizedBox(height: 16),
                  _buildKPIGrid(state),
                  const SizedBox(height: 24),
                  Text('PRODUCTION LOG', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildProductionTable(state.records),
                ],
              ),
            );
          } else if (state is DairyError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No production data found.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogMilkDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSafetyWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '⚠️ MILKING BLOCK: COW-092 in withdrawal until July 3rd. Do not mix!',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(DairyLoaded state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _kpiCard('Total Daily Yield', '${state.totalYield.toStringAsFixed(1)} L', AppColors.primary),
        _kpiCard('Avg Yield/Cow', '${(state.activeCows > 0 ? state.totalYield / state.activeCows : 0).toStringAsFixed(1)} L', Colors.blue),
        _kpiCard('Active Milking', '${state.activeCows}', Colors.orange),
        _kpiCard('Est. Revenue', '₦ 45,200', Colors.green),
      ],
    );
  }

  Widget _kpiCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionTable(List<dynamic> records) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: records.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final record = records[index];
          return ListTile(
            dense: true,
            title: Text('#${record.animalId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(record.milkingSession.toString().toUpperCase()),
            trailing: Text('${record.quantityLiters} L', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          );
        },
      ),
    );
  }

  void _showLogMilkDialog(BuildContext context) {
    // Placeholder for input modal
  }
}
