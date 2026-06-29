import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'poultry_bloc.dart';

class PoultryScreen extends StatelessWidget {
  const PoultryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POULTRY PERFORMANCE'),
      ),
      body: BlocBuilder<PoultryBloc, PoultryState>(
        builder: (context, state) {
          if (state is PoultryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PoultryLoaded) {
            if (state.batches.isEmpty) return const Center(child: Text('No active batches.'));
            
            final activeBatch = state.batches.first; // Demo assumes one active batch

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBatchHeader(activeBatch),
                  const SizedBox(height: 16),
                  _buildMetricsRow(),
                  const SizedBox(height: 24),
                  const Text('QUICK LOGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildQuickLogPanel(context, activeBatch.id),
                ],
              ),
            );
          }
          return const Center(child: Text('Error loading poultry data.'));
        },
      ),
    );
  }

  Widget _buildBatchHeader(dynamic batch) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BROILER BATCH #${batch.batchNumber}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Chip(label: Text('Active', style: TextStyle(fontSize: 10))),
              ],
            ),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _headerStat('Current Count', '${batch.currentCount} Birds'),
                _headerStat('Age', 'Day 28'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _metricCard('FCR', '1.62', 'NORMAL', AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard('Mortality', '1.4%', 'SAFE', Colors.green),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, String status, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLogPanel(BuildContext context, String batchId) {
    return Row(
      children: [
        _quickButton(context, batchId, Icons.inventory, '+1 Feed Bag', () {}),
        const SizedBox(width: 8),
        _quickButton(context, batchId, Icons.remove_circle_outline, '+1 Mortality', () {}),
        const SizedBox(width: 8),
        _quickButton(context, batchId, Icons.monitor_weight_outlined, 'Log Weight', () {}),
      ],
    );
  }

  Widget _quickButton(BuildContext context, String batchId, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
