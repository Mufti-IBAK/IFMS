import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_charts.dart';
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import 'dairy_bloc.dart';
import 'dairy_repository.dart';
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
              Expanded(child: _buildKpiCard('Cows Milked', '${state.cowsMilkedCount}', Icons.pets, Colors.orange)),
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
        // Export PDF Action Banner
        ElevatedButton.icon(
          onPressed: () {
            DairyPdfExportService.exportDairyReportPdf(dairyData: state);
          },
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text('EXPORT PDF ANALYSIS REPORT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

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
  }  Widget _buildStoreAndSalesTab(DairyLoaded state) {
    final currencyFormatter = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final inStore = state.inStoreLiters;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Availability Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MILK IN STORE (AVAILABLE FOR BUYERS)',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                          SizedBox(width: 4),
                          Text('LIVE INVENTORY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      inStore.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    const Text('LITERS AVAILABLE', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  inStore > 0
                      ? 'Ready for commercial buyer dispatch & bulk milk pickup.'
                      : 'Store balance is zero. Log milk harvests to replenish inventory.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRecordBulkSaleDialog(context, inStore),
                        icon: const Icon(Icons.point_of_sale, color: Colors.teal),
                        label: const Text('RECORD BULK MILK SALE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showSetDefaultPriceDialog(context),
                      icon: const Icon(Icons.price_change, color: Colors.white, size: 18),
                      label: Text('₦${DairyRepository.defaultMilkPrice.toStringAsFixed(0)}/L', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Inventory KPI Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildKpiCard('Total Collected', '${state.totalCollectedLiters.toStringAsFixed(1)} L', Icons.opacity, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard('Total Sold', '${state.totalSoldLiters.toStringAsFixed(1)} L', Icons.shopping_bag, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard('Medical Withdrawn', '${state.totalWithdrawnLiters.toStringAsFixed(1)} L', Icons.medical_services, Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard('Total Revenue', currencyFormatter.format(state.totalRevenue), Icons.account_balance_wallet, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sales History List Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MILK SALES TRANSACTION HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${state.salesHistory.length} Records', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),

          if (state.salesHistory.isEmpty)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.storefront_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No milk sales recorded yet.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('Use "RECORD BULK MILK SALE" above to log sales to buyers.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.salesHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = state.salesHistory[index];
                return Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: const Icon(Icons.local_shipping, color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.description?.isNotEmpty == true ? tx.description! : 'Bulk Milk Sale',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${currencyFormatter.format(tx.amount)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _showEditBulkSaleDialog(context, tx),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(Icons.edit_note, size: 18, color: Colors.blue.shade700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _confirmDeleteMilkSale(context, tx.id),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
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

  void _showSetDefaultPriceDialog(BuildContext context) {
    final priceCtrl = TextEditingController(text: DairyRepository.defaultMilkPrice.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.price_change, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Set Default Milk Price'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set fixed milk price per liter (₦). This will pre-fill all commercial bulk sales.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price Per Liter (₦) *',
                prefixText: '₦ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceCtrl.text) ?? 500.0;
              await sl<DairyRepository>().setDefaultMilkPrice(price);
              if (context.mounted) {
                context.read<DairyBloc>().add(LoadDairyData());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Default milk price set to ₦${price.toStringAsFixed(0)} / Liter'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('SAVE PRICE'),
          ),
        ],
      ),
    );
  }

  void _showRecordBulkSaleDialog(BuildContext context, double inStoreLiters) {
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController(text: inStoreLiters > 0 ? inStoreLiters.toStringAsFixed(1) : '100');
    final priceCtrl = TextEditingController(text: DairyRepository.defaultMilkPrice.toStringAsFixed(0));
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
              title: Row(
                children: const [
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

                      BlocProvider.of<DairyBloc>(context).add(RecordMilkSaleEvent(
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

  void _showEditBulkSaleDialog(BuildContext context, LocalTransaction tx) {
    final formKey = GlobalKey<FormState>();

    final regexLiters = RegExp(r'(\d+(?:\.\d+)?)\s*L');
    final regexPrice = RegExp(r'@\s*₦?(\d+(?:\.\d+)?)');
    
    double initialQty = 100.0;
    double initialPrice = DairyRepository.defaultMilkPrice;
    String initialBuyer = '';

    final desc = tx.description ?? '';
    final matchLiters = regexLiters.firstMatch(desc);
    if (matchLiters != null) {
      initialQty = double.tryParse(matchLiters.group(1)!) ?? 100.0;
    }
    final matchPrice = regexPrice.firstMatch(desc);
    if (matchPrice != null) {
      initialPrice = double.tryParse(matchPrice.group(1)!) ?? DairyRepository.defaultMilkPrice;
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
              title: Row(
                children: const [
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

                      BlocProvider.of<DairyBloc>(context).add(EditMilkSaleEvent(
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
              BlocProvider.of<DairyBloc>(context).add(DeleteMilkSaleEvent(id));
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
