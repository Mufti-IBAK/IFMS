import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_charts.dart';
import '../../core/widgets/responsive_calendar_dialog.dart';
import '../../core/database/local_db.dart';
import 'dairy_bloc.dart';
import 'widgets/add_milk_entry_sheet.dart';
import '../../core/utils/dairy_pdf_export_service.dart';

class DairyScreen extends StatefulWidget {
  const DairyScreen({super.key});

  @override
  State<DairyScreen> createState() => _DairyScreenState();
}

class _DairyScreenState extends State<DairyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
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
        actions: [
          BlocBuilder<DairyBloc, DairyState>(
            builder: (context, state) {
              if (state is DairyLoaded) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Export PDF Analysis Report',
                  onPressed: () {
                    DairyPdfExportService.exportDairyReportPdf(dairyData: state);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.storefront), text: 'Milk Store & Sales'),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DairyLoaded) {
            return NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse) {
                  if (_isFabExtended) setState(() => _isFabExtended = false);
                } else if (notification.direction == ScrollDirection.forward) {
                  if (!_isFabExtended) setState(() => _isFabExtended = true);
                }
                return true;
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(state),
                  _buildStoreAndSalesTab(state),
                  _buildAnalyticsTab(state),
                ],
              ),
            );
          }
          return const Center(child: Text('Initialize Dairy Data'));
        },
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              isExtended: _isFabExtended,
              onPressed: () {
                final dairyState = context.read<DairyBloc>().state;
                final activeDate = dairyState is DairyLoaded ? dairyState.selectedDashboardDate : null;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => BlocProvider.value(
                    value: context.read<DairyBloc>(),
                    child: AddMilkEntrySheet(initialDate: activeDate),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Record Milk'),
            )
          : null,
    );
  }

  Widget _buildDashboardTab(DairyLoaded state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(state.selectedDashboardDate.year, state.selectedDashboardDate.month, state.selectedDashboardDate.day);
    final isToday = selectedDay.isAtSameMomentAs(today);

    String dateLabel = '';
    String subtitleLabel = '';

    if (state.dashboardFilter == AnalyticsFilter.daily) {
      if (isToday) {
        dateLabel = 'Today';
        subtitleLabel = DateFormat('MMM dd, yyyy').format(state.selectedDashboardDate);
      } else if (selectedDay.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
        dateLabel = 'Yesterday';
        subtitleLabel = DateFormat('MMM dd, yyyy').format(state.selectedDashboardDate);
      } else {
        dateLabel = DateFormat('EEE, MMM dd').format(state.selectedDashboardDate);
        subtitleLabel = DateFormat('yyyy').format(state.selectedDashboardDate);
      }
    } else if (state.dashboardFilter == AnalyticsFilter.weekly) {
      int weekday = state.selectedDashboardDate.weekday;
      final start = state.selectedDashboardDate.subtract(Duration(days: weekday - 1));
      final end = start.add(const Duration(days: 6));
      dateLabel = '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd').format(end)}';
      subtitleLabel = 'Weekly Summary (${DateFormat('yyyy').format(start)})';
    } else {
      dateLabel = DateFormat('MMMM yyyy').format(state.selectedDashboardDate);
      subtitleLabel = 'Monthly Summary';
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<DairyBloc>().add(LoadDairyData()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card: Date & Period Selector
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.teal.shade50.withOpacity(0.8), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Row 1: Filter Segment Pills & TODAY Quick Button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: AnalyticsFilter.values.map((f) {
                            final isSelected = state.dashboardFilter == f;
                            final title = f == AnalyticsFilter.daily
                                ? 'Daily'
                                : f == AnalyticsFilter.weekly
                                    ? 'Weekly'
                                    : 'Monthly';
                            return GestureDetector(
                              onTap: () => context.read<DairyBloc>().add(ChangeDashboardFilter(f)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Spacer(),
                      if (!isToday || state.dashboardFilter != AnalyticsFilter.daily)
                        InkWell(
                          onTap: () {
                            context.read<DairyBloc>().add(ChangeDashboardFilter(AnalyticsFilter.daily));
                            context.read<DairyBloc>().add(ChangeDashboardDate(today));
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal.shade300),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.replay, size: 12, color: Colors.teal),
                                SizedBox(width: 4),
                                Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: Interactive Date Selector Bar
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            DateTime newDate;
                            if (state.dashboardFilter == AnalyticsFilter.daily) {
                              newDate = state.selectedDashboardDate.subtract(const Duration(days: 1));
                            } else if (state.dashboardFilter == AnalyticsFilter.weekly) {
                              newDate = state.selectedDashboardDate.subtract(const Duration(days: 7));
                            } else {
                              newDate = DateTime(state.selectedDashboardDate.year, state.selectedDashboardDate.month - 1, 1);
                            }
                            context.read<DairyBloc>().add(ChangeDashboardDate(newDate));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.chevron_left, size: 20, color: Colors.teal),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showResponsiveCalendarPicker(
                              context: context,
                              initialDate: state.selectedDashboardDate,
                            );
                            if (picked != null && mounted) {
                              context.read<DairyBloc>().add(ChangeDashboardDate(picked));
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal.shade200),
                              boxShadow: [
                                BoxShadow(color: Colors.teal.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.teal),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        dateLabel,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (subtitleLabel.isNotEmpty)
                                        Text(
                                          subtitleLabel,
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            DateTime newDate;
                            if (state.dashboardFilter == AnalyticsFilter.daily) {
                              newDate = state.selectedDashboardDate.add(const Duration(days: 1));
                            } else if (state.dashboardFilter == AnalyticsFilter.weekly) {
                              newDate = state.selectedDashboardDate.add(const Duration(days: 7));
                            } else {
                              newDate = DateTime(state.selectedDashboardDate.year, state.selectedDashboardDate.month + 1, 1);
                            }
                            context.read<DairyBloc>().add(ChangeDashboardDate(newDate));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.chevron_right, size: 20, color: Colors.teal),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Main KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildKpiCard('Selected Period Milk', '${state.totalMilkDashboard.toStringAsFixed(1)} L', Icons.opacity, Colors.blue),
              _buildKpiCard('Average Per Cow', '${state.averagePerCowDashboard.toStringAsFixed(1)} L', Icons.bar_chart, Colors.teal),
              _buildKpiCard('Cows Milked', '${state.cowsMilkedCount} Cows', Icons.pets, Colors.purple),
              _buildKpiCard('Monthly Total', '${state.monthlyMilkTotal.toStringAsFixed(1)} L', Icons.calendar_today, Colors.orange),
            ],
          ),
          const SizedBox(height: 20),

          // Top Producers & Low Performers Cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCowRankCard('TOP PRODUCERS', state.topProducersDashboard, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCowRankCard('LOW PERFORMERS', state.lowPerformersDashboard, Colors.amber.shade900),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Logs Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MILK HARVEST LOGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${state.dashboardRecords.length} records', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          state.dashboardRecords.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('No milk records for $dateLabel', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.dashboardRecords.length,
                  itemBuilder: (context, index) {
                    final rec = state.dashboardRecords[index];
                    final tag = state.animalTagMap[rec.animalId] ?? rec.animalId.substring(0, 8);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rec.isWithdrawn ? Colors.red.shade100 : Colors.teal.shade50,
                          child: Icon(
                            rec.isWithdrawn ? Icons.warning_amber_rounded : Icons.water_drop,
                            color: rec.isWithdrawn ? Colors.red : Colors.teal,
                          ),
                        ),
                        title: Text('Cow Tag: #$tag', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${rec.milkingSession.toUpperCase()} • ${DateFormat('hh:mm a').format(rec.recordDate)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${rec.quantityLiters.toStringAsFixed(1)} L',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: rec.isWithdrawn ? Colors.red : Colors.teal.shade800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                context.read<DairyBloc>().add(DeleteMilkEntry(rec.id));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(DairyLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Analytics Filter Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PRODUCTION TRENDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AnalyticsFilter>(
                segments: const [
                  ButtonSegment(value: AnalyticsFilter.daily, label: Text('Daily', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: AnalyticsFilter.weekly, label: Text('Weekly', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: AnalyticsFilter.monthly, label: Text('Monthly', style: TextStyle(fontSize: 12))),
                ],
                selected: {state.currentFilter},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) {
                    context.read<DairyBloc>().add(ChangeAnalyticsFilter(set.first));
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Herd Production Chart
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Herd Output', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '${state.totalYieldForPeriod.toStringAsFixed(1)} L Total',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: CustomLineChart(
                    data: state.herdChartData,
                    labels: state.herdChartLabels,
                    lineColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Cow Yield Breakdown List
        const Text('COW YIELD BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),

        state.cowYieldBreakdown.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: const Text('No yield data available for selected filter.', style: TextStyle(color: Colors.grey)),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.cowYieldBreakdown.length,
                itemBuilder: (context, index) {
                  final entry = state.cowYieldBreakdown.entries.elementAt(index);
                  final pct = state.totalYieldForPeriod > 0 ? (entry.value / state.totalYieldForPeriod) * 100 : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cow #${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${entry.value.toStringAsFixed(1)} L (${pct.toStringAsFixed(1)}%)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: state.totalYieldForPeriod > 0 ? (entry.value / state.totalYieldForPeriod) : 0.0,
                            backgroundColor: Colors.teal.shade50,
                            color: Colors.teal,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildStoreAndSalesTab(DairyLoaded state) {
    return RefreshIndicator(
      onRefresh: () async => context.read<DairyBloc>().add(LoadDairyData()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dynamic Milk Price Configurator Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.teal.shade900,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sell, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACTIVE MILK PRICE PER LITER',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₦${NumberFormat('#,##0.00').format(state.currentMilkPrice)} / Liter',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Affects pre-filled sales price and cold store valuation',
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showUpdatePriceDialog(context, state.currentMilkPrice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('CHANGE PRICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Button: Record Bulk Milk Sale
          ElevatedButton.icon(
            onPressed: () => _showRecordBulkSaleDialog(context, state.inStoreLiters, state.currentMilkPrice),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('RECORD BULK MILK SALE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 16),

          // Inventory & Sales Overview KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildKpiCard('In Cold Store', '${state.inStoreLiters.toStringAsFixed(1)} L', Icons.kitchen, Colors.teal),
              _buildKpiCard('Cold Store Value', '₦${NumberFormat('#,##0').format(state.inStoreValue)}', Icons.account_balance_wallet, Colors.green),
              _buildKpiCard('Total Bulk Sold', '${state.totalSoldLiters.toStringAsFixed(1)} L', Icons.shopping_bag, Colors.blue),
              _buildKpiCard('Total Milk Revenue', '₦${NumberFormat('#,##0').format(state.totalRevenue)}', Icons.payments, Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 24),

          // Bulk Milk Sales History Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BULK MILK SALES HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${state.salesHistory.length} sales entries', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          state.salesHistory.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.point_of_sale_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('No bulk milk sales recorded yet.', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.salesHistory.length,
                  itemBuilder: (context, index) {
                    final tx = state.salesHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: const Icon(Icons.attach_money, color: Colors.green),
                        ),
                        title: Text(tx.description ?? 'Milk Sale', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(tx.transactionDate), style: const TextStyle(fontSize: 11)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₦${NumberFormat('#,##0.00').format(tx.amount)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showEditBulkSaleDialog(context, tx, state.currentMilkPrice);
                                } else if (val == 'delete') {
                                  _confirmDeleteMilkSale(context, tx.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 16), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCowRankCard(String title, Map<String, double> data, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),
            if (data.isEmpty)
              const Text('No records', style: TextStyle(color: Colors.grey, fontSize: 11))
            else
              ...data.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${e.key}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                        Text('${e.value.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showUpdatePriceDialog(BuildContext context, double currentPrice) {
    final priceCtrl = TextEditingController(text: currentPrice.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sell, color: Colors.teal),
            SizedBox(width: 8),
            Text('Update Milk Price (₦/L)'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the new dynamic price per liter of raw milk. This price will automatically populate new sales and update live cold store valuation.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price Per Liter (₦) *',
                  prefixText: '₦ ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter price per liter';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Enter valid price > 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newP = double.parse(priceCtrl.text.trim());
                context.read<DairyBloc>().add(UpdateMilkPriceEvent(newP));
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated active milk price to ₦${newP.toStringAsFixed(0)} / Liter.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('SAVE PRICE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecordBulkSaleDialog(BuildContext context, double inStoreLiters, double currentPrice) {
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController(text: inStoreLiters > 0 ? inStoreLiters.toStringAsFixed(1) : '100');
    final priceCtrl = TextEditingController(text: currentPrice.toStringAsFixed(0));
    final buyerCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    double calculateTotal() {
      final q = double.tryParse(qtyCtrl.text) ?? 0.0;
      final p = double.tryParse(priceCtrl.text) ?? 0.0;
      return q * p;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final totalRevenue = calculateTotal();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.point_of_sale, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('RECORD BULK MILK SALE'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.teal, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Available in Store: ${inStoreLiters.toStringAsFixed(1)} Liters',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Quantity Sold (Liters) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.opacity),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter quantity in liters';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'Enter valid quantity > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Price Per Liter (₦) *',
                          prefixText: '₦ ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payments),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter price per liter';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'Enter valid price > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: buyerCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Buyer / Company Name *',
                          hintText: 'e.g. FrieslandCampina, Local Dairy',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Enter buyer name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notes / Delivery Ref',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Calculated Revenue:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '₦${NumberFormat('#,##0.00').format(totalRevenue)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final q = double.parse(qtyCtrl.text.trim());
                      final p = double.parse(priceCtrl.text.trim());

                      context.read<DairyBloc>().add(RecordMilkSaleEvent(
                        quantityLiters: q,
                        pricePerLiter: p,
                        buyerName: buyerCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      ));

                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Recorded sale of ${q.toStringAsFixed(1)} L to ${buyerCtrl.text.trim()} (₦${NumberFormat('#,##0.00').format(q * p)}).'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('CONFIRM SALE', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBulkSaleDialog(BuildContext context, LocalTransaction tx, double currentPrice) {
    final formKey = GlobalKey<FormState>();

    final regexLiters = RegExp(r'(\d+(?:\.\d+)?)\s*L');
    final regexPrice = RegExp(r'@\s*₦?(\d+(?:\.\d+)?)');
    
    double initialQty = 100.0;
    double initialPrice = currentPrice;
    String initialBuyer = '';

    final desc = tx.description ?? '';
    final matchLiters = regexLiters.firstMatch(desc);
    if (matchLiters != null) {
      initialQty = double.tryParse(matchLiters.group(1)!) ?? 100.0;
    }
    final matchPrice = regexPrice.firstMatch(desc);
    if (matchPrice != null) {
      initialPrice = double.tryParse(matchPrice.group(1)!) ?? currentPrice;
    }
    if (desc.contains(' - ')) {
      initialBuyer = desc.split(' - ').last.trim();
    }

    final qtyCtrl = TextEditingController(text: initialQty.toStringAsFixed(1));
    final priceCtrl = TextEditingController(text: initialPrice.toStringAsFixed(0));
    final buyerCtrl = TextEditingController(text: initialBuyer);
    final notesCtrl = TextEditingController();

    double calculateTotal() {
      final q = double.tryParse(qtyCtrl.text) ?? 0.0;
      final p = double.tryParse(priceCtrl.text) ?? 0.0;
      return q * p;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final totalRevenue = calculateTotal();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit Milk Sale Entry'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Quantity Sold (Liters) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.opacity),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter quantity in liters';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'Enter valid quantity > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Price Per Liter (₦) *',
                          prefixText: '₦ ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payments),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter price per liter';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'Enter valid price > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: buyerCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Buyer / Company Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'Enter buyer name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notes / Delivery Ref',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Updated Revenue:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '₦${NumberFormat('#,##0.00').format(totalRevenue)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final q = double.parse(qtyCtrl.text.trim());
                      final p = double.parse(priceCtrl.text.trim());

                      context.read<DairyBloc>().add(EditMilkSaleEvent(
                        id: tx.id,
                        quantityLiters: q,
                        pricePerLiter: p,
                        buyerName: buyerCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      ));

                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Milk sale record updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMilkSale(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Milk Sale Record'),
        content: const Text('Are you sure you want to delete this milk sale transaction? The sold milk quantity will be restored to live store inventory.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              context.read<DairyBloc>().add(DeleteMilkSaleEvent(id));
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Milk sale transaction deleted.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
