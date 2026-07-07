import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_charts.dart';
import '../../core/di/service_locator.dart';
import 'dairy_repository.dart';
import 'dairy_bloc.dart';
import 'widgets/add_milk_entry_sheet.dart';

class DairyScreen extends StatefulWidget {
  const DairyScreen({super.key});

  @override
  State<DairyScreen> createState() => _DairyScreenState();
}

class _DairyScreenState extends State<DairyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<DairyBloc>().add(LoadDairyData());
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
        title: const Text('Dairy Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: BlocBuilder<DairyBloc, DairyState>(
        builder: (context, state) {
          if (state is DairyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DairyError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
          }
          if (state is DairyLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(state),
                _buildAnalyticsTab(state),
              ],
            );
          }
          return const Center(child: Text('Initialize Dairy Data'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => BlocProvider.value(
              value: context.read<DairyBloc>(),
              child: const AddMilkEntrySheet(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Record Milk'),
      ),
    );
  }

  Widget _buildDashboardTab(DairyLoaded state) {
    return RefreshIndicator(
      onRefresh: () async => context.read<DairyBloc>().add(LoadDairyData()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildKpiCard('Total Milk Today', '${state.totalMilkToday.toStringAsFixed(1)} Liters', Icons.water_drop, Colors.blue),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKpiCard('Avg / Cow', '${state.averagePerCow.toStringAsFixed(1)} L', Icons.scale, Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiCard('Cows Milked', '${state.topProducers.length + state.lowPerformers.length}', Icons.pets, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (state.todayRecords.isEmpty)
            const Center(child: Text('No milk records for today.'))
          else
            ...state.todayRecords.map((record) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: record.isWithdrawn ? Colors.red.shade100 : Colors.blue.shade50,
                  child: Icon(
                    record.isWithdrawn ? Icons.warning : Icons.water_drop,
                    color: record.isWithdrawn ? Colors.red : Colors.blue,
                  ),
                ),
                title: Text('Animal ID: ${record.animalId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Session: ${record.milkingSession} • ${DateFormat('HH:mm').format(record.recordDate)}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${record.quantityLiters.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (record.isWithdrawn)
                      const Text('WITHDRAWN', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  Future<List<double>> _get7DayHistory() async {
    final List<double> history = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final records = await sl<DairyRepository>().getHerdDailyTotal(date);
      double total = 0.0;
      for (var r in records) {
        if (!r.isWithdrawn) {
          total += r.quantityLiters;
        }
      }
      history.add(total);
    }
    return history;
  }

  List<String> _get7DayLabels() {
    final List<String> labels = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add(DateFormat('dd/MM').format(date));
    }
    return labels;
  }

  Widget _buildAnalyticsTab(DairyLoaded state) {
    return FutureBuilder<List<double>>(
      future: _get7DayHistory(),
      builder: (context, snapshot) {
        final chartData = snapshot.data ?? List.filled(7, 0.0);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.show_chart, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('7-DAY MILK YIELD CURVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomLineChart(
                      data: chartData,
                      labels: _get7DayLabels(),
                      lineColor: Colors.blue.shade700,
                      gradientColors: [Colors.blue.shade200.withOpacity(0.4), Colors.blue.shade200.withOpacity(0.0)],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Top Producers (Today)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            if (state.topProducers.isEmpty)
              const Center(child: Text('No milking logs for today.'))
            else
              ...state.topProducers.entries.map((e) => ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: Text('Animal ID: ${e.key}'),
                trailing: Text('${e.value.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Low Performers (Today)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            if (state.lowPerformers.isEmpty)
              const Center(child: Text('No milking logs for today.'))
            else
              ...state.lowPerformers.entries.map((e) => ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.red),
                title: Text('Animal ID: ${e.key}'),
                trailing: Text('${e.value.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
          ],
        );
      }
    );
  }


  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
