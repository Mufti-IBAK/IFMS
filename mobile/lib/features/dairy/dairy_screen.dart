import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_charts.dart';
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
        title: const Text('MILK PRODUCTION REGISTRY'),
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
      body: BlocConsumer<DairyBloc, DairyState>(
        listener: (context, state) {
          if (state is DairyError) {
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
          if (state is DairyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DairyError) {
            // Error is handled by listener, but we return a temporary loading indicator
            // because DairyBloc immediately fires LoadDairyData() after emitting an error.
            return const Center(child: CircularProgressIndicator());
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
    String dateLabel = '';
    if (state.dashboardFilter == AnalyticsFilter.daily) {
      dateLabel = DateFormat('MMM dd, yyyy').format(state.selectedDashboardDate);
    } else if (state.dashboardFilter == AnalyticsFilter.weekly) {
      int weekday = state.selectedDashboardDate.weekday;
      final start = state.selectedDashboardDate.subtract(Duration(days: weekday - 1));
      final end = start.add(const Duration(days: 6));
      dateLabel = '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd').format(end)}';
    } else {
      dateLabel = DateFormat('MMMM yyyy').format(state.selectedDashboardDate);
    }

    void shiftDate(int direction) {
      DateTime newDate = state.selectedDashboardDate;
      if (state.dashboardFilter == AnalyticsFilter.daily) {
        newDate = state.selectedDashboardDate.add(Duration(days: direction));
      } else if (state.dashboardFilter == AnalyticsFilter.weekly) {
        newDate = state.selectedDashboardDate.add(Duration(days: 7 * direction));
      } else {
        newDate = DateTime(state.selectedDashboardDate.year, state.selectedDashboardDate.month + direction, state.selectedDashboardDate.day);
      }
      context.read<DairyBloc>().add(ChangeDashboardDate(newDate));
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<DairyBloc>().add(LoadDairyData()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: SegmentedButton<AnalyticsFilter>(
              segments: const [
                ButtonSegment(value: AnalyticsFilter.daily, label: Text('Daily')),
                ButtonSegment(value: AnalyticsFilter.weekly, label: Text('Weekly')),
                ButtonSegment(value: AnalyticsFilter.monthly, label: Text('Monthly')),
              ],
              selected: {state.dashboardFilter},
              onSelectionChanged: (Set<AnalyticsFilter> newSelection) {
                context.read<DairyBloc>().add(ChangeDashboardFilter(newSelection.first));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  return states.contains(MaterialState.selected) ? AppColors.primary.withOpacity(0.2) : Colors.transparent;
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => shiftDate(-1)),
              Text(dateLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => shiftDate(1)),
            ],
          ),
          const SizedBox(height: 16),
          _buildKpiCard('Total Milk', '${state.totalMilkDashboard.toStringAsFixed(1)} Liters', Icons.water_drop, Colors.blue),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKpiCard('Avg / Cow', '${state.averagePerCowDashboard.toStringAsFixed(1)} L', Icons.scale, Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiCard('Cows Milked', '${state.topProducersDashboard.length + state.lowPerformersDashboard.length}', Icons.pets, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          Text(state.dashboardFilter == AnalyticsFilter.daily ? 'Entries for $dateLabel' : 'Entries for this period', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (state.dashboardRecords.isEmpty)
            const Center(child: Text('No milk records found.'))
          else
            ...state.dashboardRecords.map((record) {
              final tagId = state.animalTagMap[record.animalId] ?? record.animalId.substring(0, 8);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: record.isWithdrawn ? Colors.red.shade100 : Colors.blue.shade50,
                    child: Icon(
                      record.isWithdrawn ? Icons.warning : Icons.water_drop,
                      color: record.isWithdrawn ? Colors.red : Colors.blue,
                    ),
                  ),
                  title: Text('Cow ID: $tagId', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Session: ${record.milkingSession} • ${DateFormat('MMM dd, HH:mm').format(record.recordDate)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${record.quantityLiters.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (record.isWithdrawn)
                            const Text('WITHDRAWN', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => BlocProvider.value(
                                value: context.read<DairyBloc>(),
                                child: AddMilkEntrySheet(record: record),
                              ),
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Record'),
                                content: const Text('Are you sure you want to delete this milk record?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<DairyBloc>().add(DeleteMilkEntry(record.id));
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(DairyLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Time Filter Selector
        Center(
          child: SegmentedButton<AnalyticsFilter>(
            segments: const [
              ButtonSegment(value: AnalyticsFilter.daily, label: Text('Daily')),
              ButtonSegment(value: AnalyticsFilter.weekly, label: Text('Weekly')),
              ButtonSegment(value: AnalyticsFilter.monthly, label: Text('Monthly')),
            ],
            selected: {state.currentFilter},
            onSelectionChanged: (Set<AnalyticsFilter> newSelection) {
              context.read<DairyBloc>().add(ChangeAnalyticsFilter(newSelection.first));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.primary.withOpacity(0.2);
                  }
                  return Colors.transparent;
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Herd Chart
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'HERD YIELD (${state.currentFilter.name.toUpperCase()}) - ${state.totalYieldForPeriod.toStringAsFixed(1)}L',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.herdChartData.every((e) => e == 0))
                  const SizedBox(
                    height: 200,
                    child: Center(child: Text('No milk records for this period.')),
                  )
                else
                  CustomLineChart(
                    data: state.herdChartData,
                    labels: state.herdChartLabels,
                    lineColor: Colors.blue.shade700,
                    gradientColors: [Colors.blue.shade200.withOpacity(0.4), Colors.blue.shade200.withOpacity(0.0)],
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        const Text('Cow Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        if (state.cowYieldBreakdown.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No cow data available.'),
            ),
          )
        else
          ...state.cowYieldBreakdown.entries.map((e) {
            final double percentage = state.totalYieldForPeriod > 0 
                ? (e.value / state.totalYieldForPeriod) * 100 
                : 0.0;
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.pets, color: AppColors.primary),
                      ),
                      title: Text('Cow ID: ${e.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 4),
                          Text('${percentage.toStringAsFixed(1)}% of herd total', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      trailing: Text('${e.value.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    if (state.cowChartData[e.key] != null && !state.cowChartData[e.key]!.every((v) => v == 0))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: SizedBox(
                          height: 100,
                          child: CustomLineChart(
                            data: state.cowChartData[e.key]!,
                            labels: state.herdChartLabels,
                            lineColor: AppColors.primary,
                            gradientColors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.0)],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
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
