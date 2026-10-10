import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../animals/animals_repository.dart';
import '../poultry/poultry_repository.dart';
import '../../core/database/local_db.dart';
import 'package:ifms_mobile/core/widgets/custom_charts.dart';
import '../../core/utils/finance_pdf_export_service.dart';
import '../../core/widgets/responsive_calendar_dialog.dart';
import '../settings/settings_controller.dart';
import 'finance_bloc.dart';
import 'finance_repository.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _InventoryCachedItem {
  final String id;
  final String display;
  _InventoryCachedItem(this.id, this.display);
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormatter = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
  final _compactFormatter = NumberFormat.compactCurrency(symbol: '₦');

  List<_InventoryCachedItem> _animalsList = [];
  List<_InventoryCachedItem> _flocksList = [];
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  int _selectedWeek = 0; // 0 = All Weeks, 1 = Wk 1 (1-7), 2 = Wk 2 (8-14), 3 = Wk 3 (15-21), 4 = Wk 4 (22+)
  bool _isDayView = true; // Default to Daily Ledger display as requested
  String _ledgerCategoryFilter = 'ALL';

  bool _isManualTransaction(LocalTransaction tx) {
    final type = tx.relatedEntityType?.toLowerCase();
    if (type == null || type.isEmpty || type == 'manual' || type == 'manual_entry') {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadLinkedEntities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLinkedEntities() async {
    try {
      final animals = await sl<AnimalsRepository>().getAnimals();
      final flocks = await sl<PoultryRepository>().getBatches();
      if (mounted) {
        setState(() {
          _animalsList = animals.map((a) {
            final tag = a.tagId;
            final breed = a.breed ?? 'Unknown Breed';
            return _InventoryCachedItem(a.id, '$tag ($breed)');
          }).toList();

          _flocksList = flocks.map((f) {
            final batchName = '${f.batchNumber} (${f.houseName})';
            final breed = f.breed ?? 'Flock';
            return _InventoryCachedItem(f.id, '$batchName ($breed)');
          }).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Sync & Refresh',
            onPressed: () {
              BlocProvider.of<FinanceBloc>(context).add(LoadFinanceData());
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onSelected: (val) {
              if (val == 'clear_all') {
                _confirmClearLedger(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Clear All Ledger Entries', style: TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.insights, size: 20), text: 'INSIGHTS'),
            Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'LEDGER'),
            Tab(icon: Icon(Icons.psychology, size: 20), text: 'ADVISOR'),
          ],
        ),
      ),
      body: BlocConsumer<FinanceBloc, FinanceState>(
        listener: (context, state) {
          if (state is FinanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is FinanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FinanceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => BlocProvider.of<FinanceBloc>(context).add(LoadFinanceData()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is FinanceLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(context, state),
                _buildLedgerTab(context, state),
                _buildCullingTab(context, state),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTransactionDialog(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Record Tx', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  // ──────────────────────────────────────────────
  // TAB 1: DASHBOARD & FINANCIAL INSIGHTS
  // ──────────────────────────────────────────────
  Widget _buildDashboardTab(BuildContext context, FinanceLoaded state) {
    // Filter transactions by Month and Week (READ ALL TRANSACTIONS for real-time reporting)
    final filteredTxs = state.transactions.where((t) {
      final d = t.transactionDate;
      if (d.year != _selectedMonth.year || d.month != _selectedMonth.month) {
        return false;
      }
      if (_selectedWeek == 1) return d.day >= 1 && d.day <= 7;
      if (_selectedWeek == 2) return d.day >= 8 && d.day <= 14;
      if (_selectedWeek == 3) return d.day >= 15 && d.day <= 21;
      if (_selectedWeek == 4) return d.day >= 22;
      return true; // 0 = All Weeks
    }).toList();

    double totalRevenue = 0.0;
    double totalExpenses = 0.0;
    double reconciledRevenue = 0.0;
    double reconciledExpenses = 0.0;
    double pendingRevenue = 0.0;
    double pendingExpenses = 0.0;

    // Yoghurt Factory specific metrics
    double yoghurtSales = 0.0;
    double yoghurtDirectExpenses = 0.0;
    double yoghurtRawTransferExpenses = 0.0;

    final Map<String, double> categoryBreakdown = {};

    for (var tx in filteredTxs) {
      final amt = tx.amount;
      if (tx.transactionType == 'income') {
        totalRevenue += amt;
        if (tx.isReconciled) {
          reconciledRevenue += amt;
        } else {
          pendingRevenue += amt;
        }
        if (tx.category == 'yoghurt_sales') {
          yoghurtSales += amt;
        }
      } else {
        totalExpenses += amt;
        if (tx.isReconciled) {
          reconciledExpenses += amt;
        } else {
          pendingExpenses += amt;
        }
        if (tx.category == 'yoghurt_expense') {
          yoghurtDirectExpenses += amt;
        } else if (tx.category == 'yoghurt_raw_material_transfer') {
          yoghurtRawTransferExpenses += amt;
        }
      }
      categoryBreakdown[tx.category] = (categoryBreakdown[tx.category] ?? 0.0) + amt;
    }

    final totalYoghurtExpenses = yoghurtDirectExpenses + yoghurtRawTransferExpenses;
    final yoghurtNetProfit = yoghurtSales - totalYoghurtExpenses;
    final yoghurtMargin = yoghurtSales > 0 ? (yoghurtNetProfit / yoghurtSales) * 100 : 0.0;

    final netProfit = totalRevenue - totalExpenses;
    final margin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

    // Compute Bar Graph Data
    final List<String> chartLabels = [];
    final List<double> chartRevenue = [];
    final List<double> chartExpenses = [];

    if (_selectedWeek == 0) {
      final weeklyRev = List.filled(4, 0.0);
      final weeklyExp = List.filled(4, 0.0);
      for (var tx in filteredTxs) {
        int w = ((tx.transactionDate.day - 1) / 7).floor();
        if (w > 3) w = 3;
        if (tx.transactionType == 'income') {
          weeklyRev[w] += tx.amount;
        } else {
          weeklyExp[w] += tx.amount;
        }
      }
      chartLabels.addAll(['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4']);
      chartRevenue.addAll(weeklyRev);
      chartExpenses.addAll(weeklyExp);
    } else {
      int startDay = 1;
      int endDay = 7;
      if (_selectedWeek == 1) { startDay = 1; endDay = 7; }
      else if (_selectedWeek == 2) { startDay = 8; endDay = 14; }
      else if (_selectedWeek == 3) { startDay = 15; endDay = 21; }
      else if (_selectedWeek == 4) {
        startDay = 22;
        endDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
      }

      final Map<int, double> dailyRev = {};
      final Map<int, double> dailyExp = {};

      for (var tx in filteredTxs) {
        final day = tx.transactionDate.day;
        if (tx.transactionType == 'income') {
          dailyRev[day] = (dailyRev[day] ?? 0.0) + tx.amount;
        } else {
          dailyExp[day] = (dailyExp[day] ?? 0.0) + tx.amount;
        }
      }

      for (int day = startDay; day <= endDay; day++) {
        chartLabels.add('$day');
        chartRevenue.add(dailyRev[day] ?? 0.0);
        chartExpenses.add(dailyExp[day] ?? 0.0);
      }
    }

    // Category Donut Chart Data
    final List<double> donutValues = [];
    final List<String> donutLabels = [];
    categoryBreakdown.forEach((k, v) {
      if (v > 0) {
        donutValues.add(v);
        donutLabels.add(_formatCategoryLabel(k));
      }
    });

    final List<Color> donutColors = [
      Colors.teal,
      Colors.amber.shade700,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
      Colors.orange,
      Colors.deepOrange,
      Colors.cyan,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PERIOD & WEEK SELECTOR BAR
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          final picked = await showResponsiveCalendarPicker(
                            context: context,
                            initialDate: _selectedMonth,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedMonth = DateTime(picked.year, picked.month, 1);
                              _selectedWeek = 0;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'PERIOD: ${DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.today, size: 20),
                            tooltip: 'Current Month',
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime.now();
                                _selectedWeek = 0;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        _buildWeekSegmentTab(0, 'All'),
                        _buildWeekSegmentTab(1, 'Wk 1'),
                        _buildWeekSegmentTab(2, 'Wk 2'),
                        _buildWeekSegmentTab(3, 'Wk 3'),
                        _buildWeekSegmentTab(4, 'Wk 4'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // KPI GRID
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _kpiCard(
                'Total Revenue',
                _compactFormatter.format(totalRevenue),
                Icons.trending_up,
                Colors.green,
                '₦ ${totalRevenue.toStringAsFixed(0)}',
              ),
              _kpiCard(
                'Total Expenses',
                _compactFormatter.format(totalExpenses),
                Icons.trending_down,
                Colors.red,
                '₦ ${totalExpenses.toStringAsFixed(0)}',
              ),
              _kpiCard(
                'Net Cash Flow',
                _compactFormatter.format(netProfit),
                Icons.account_balance_wallet,
                netProfit >= 0 ? AppColors.primary : Colors.orange,
                '₦ ${netProfit.toStringAsFixed(0)}',
              ),
              _kpiCard(
                'Profit Margin',
                '${margin.toStringAsFixed(1)}%',
                Icons.pie_chart_outline,
                AppColors.secondary,
                'Margin % of sales',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // RECONCILIATION AUDIT STATUS STRIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Reconciled: ${_compactFormatter.format(reconciledRevenue - reconciledExpenses)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.pending_actions, color: Colors.orange, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Pending Audit: ${_compactFormatter.format(pendingRevenue - pendingExpenses)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // YOGHURT FACTORY PERFORMANCE CARD (NEW DEDICATED SECTION)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.cyan.shade50, Colors.teal.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.cyan.shade200),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.icecream, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'YOGHURT FACTORY INSIGHTS',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: yoghurtNetProfit >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: yoghurtNetProfit >= 0 ? Colors.green.shade300 : Colors.red.shade300),
                        ),
                        child: Text(
                          '${yoghurtMargin.toStringAsFixed(1)}% MARGIN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: yoghurtNetProfit >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniMetric('Gross Sales', _currencyFormatter.format(yoghurtSales), Colors.green.shade800),
                      _miniMetric('Op. Expenses', _currencyFormatter.format(yoghurtDirectExpenses), Colors.red.shade800),
                      _miniMetric('Milk Transfer', _currencyFormatter.format(yoghurtRawTransferExpenses), Colors.indigo.shade800),
                      _miniMetric('Net Contribution', _currencyFormatter.format(yoghurtNetProfit), yoghurtNetProfit >= 0 ? Colors.teal.shade900 : Colors.red.shade900),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // CASH FLOW COMPARISON BAR CHART
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            _selectedWeek == 0 ? 'MONTHLY CASH FLOW' : 'WEEK $_selectedWeek CASH FLOW',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        '${DateFormat('MMM yyyy').format(_selectedMonth)} ${_selectedWeek > 0 ? "(Wk $_selectedWeek)" : ""}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomBarChart(
                    primaryData: chartRevenue,
                    secondaryData: chartExpenses,
                    labels: chartLabels,
                    primaryColor: Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green.shade700, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Revenue', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 16),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red.shade700, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Expenses', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // NET PROFIT BY SECTOR
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.business, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('SECTOR MARGIN PERFORMANCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.sectorMargins.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No sector records found.'),
                    ))
                  else
                    ...state.sectorMargins.entries.map((e) {
                      final value = e.value;
                      final totalAbs = state.sectorMargins.values.fold(0.0, (sum, val) => sum + val.abs());
                      final double progress = totalAbs > 0 ? (value.abs() / totalAbs).clamp(0.05, 1.0) : 0.1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(
                                  _currencyFormatter.format(value),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: value >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.surfaceContainerHigh,
                                valueColor: AlwaysStoppedAnimation(value >= 0 ? Colors.green : Colors.red),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // BREAKDOWN BY CATEGORY (DONUT CHART)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('CATEGORY BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (donutValues.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No breakdown logs yet.'),
                    ))
                  else ...[
                    CustomDonutChart(
                      values: donutValues,
                      labels: donutLabels,
                      colors: donutColors.take(donutValues.length).toList(),
                      centerValue: _compactFormatter.format(totalRevenue),
                      centerTitle: 'Total Tx',
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(donutValues.length, (idx) {
                      final name = donutLabels[idx];
                      final val = donutValues[idx];
                      final isRevenueCat = name.contains('SALES');
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: donutColors[idx % donutColors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(name, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              Text(
                                '${isRevenueCat ? '+' : '-'}${_currencyFormatter.format(val)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isRevenueCat ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildWeekSegmentTab(int index, String label) {
    final isSelected = _selectedWeek == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedWeek = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color, String sub) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // TAB 2: CONSOLIDATED LEDGER (PER DAY VIEW)
  // ──────────────────────────────────────────────
  Widget _buildDateSelectorHeader(FinanceLoaded state) {
    final dayFormat = DateFormat('EEEE, d MMMM yyyy');
    final monthFormat = DateFormat('MMMM yyyy');
    final isToday = _selectedDate.year == DateTime.now().year &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.purple),
                tooltip: _isDayView ? 'Previous Day' : 'Previous Month',
                onPressed: () {
                  setState(() {
                    if (_isDayView) {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    } else {
                      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                    }
                  });
                },
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final picked = await showResponsiveCalendarPicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.purple, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _isDayView ? dayFormat.format(_selectedDate) : monthFormat.format(_selectedDate).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple),
                      ),
                      if (_isDayView && isToday) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('TODAY', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.purple),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isDayView && !isToday)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime.now();
                        });
                      },
                      child: const Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.purple),
                    tooltip: _isDayView ? 'Next Day' : 'Next Month',
                    onPressed: () {
                      setState(() {
                        if (_isDayView) {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        } else {
                          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // View Mode Switcher and PDF Export actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Toggle Day / Month view
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isDayView = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isDayView ? Colors.purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'DAY VIEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _isDayView ? Colors.white : Colors.purple,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isDayView = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: !_isDayView ? Colors.purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'MONTH VIEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: !_isDayView ? Colors.white : Colors.purple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Export PDF Actions
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: BorderSide(color: Colors.purple.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 14),
                    label: Text(_isDayView ? 'Day PDF' : 'Month PDF', style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      if (_isDayView) {
                        FinancePdfExportService.exportDailyLedgerStatementPdf(
                          transactions: state.transactions,
                          selectedDate: _selectedDate,
                          ownerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.ownerEmail : null,
                          managerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.managerEmail : null,
                        );
                      } else {
                        FinancePdfExportService.exportMonthlyAccountStatementPdf(
                          transactions: state.transactions,
                          selectedMonth: _selectedDate,
                          ownerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.ownerEmail : null,
                          managerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.managerEmail : null,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTab(BuildContext context, FinanceLoaded state) {
    // 1. Time-filtered transactions
    final timeFilteredTransactions = state.transactions.where((tx) {
      if (_isDayView) {
        return tx.transactionDate.year == _selectedDate.year &&
               tx.transactionDate.month == _selectedDate.month &&
               tx.transactionDate.day == _selectedDate.day;
      } else {
        return tx.transactionDate.year == _selectedDate.year &&
               tx.transactionDate.month == _selectedDate.month;
      }
    }).toList();

    // 2. Category Filter
    final filteredTransactions = timeFilteredTransactions.where((tx) {
      if (_ledgerCategoryFilter == 'ALL') return true;
      if (_ledgerCategoryFilter == 'INCOME') return tx.transactionType == 'income';
      if (_ledgerCategoryFilter == 'EXPENSE') return tx.transactionType == 'expense';
      if (_ledgerCategoryFilter == 'YOGHURT') return tx.category.toLowerCase().contains('yoghurt');
      if (_ledgerCategoryFilter == 'DAIRY') return tx.category.toLowerCase().contains('milk');
      if (_ledgerCategoryFilter == 'LIVESTOCK') return tx.category.toLowerCase().contains('animal');
      if (_ledgerCategoryFilter == 'POULTRY') return tx.category.toLowerCase().contains('poultry') || tx.category.toLowerCase().contains('hatchery');
      return true;
    }).toList();

    // Compute period summary
    double periodIncome = 0.0;
    double periodExpense = 0.0;
    for (var tx in timeFilteredTransactions) {
      if (tx.transactionType == 'income') {
        periodIncome += tx.amount;
      } else {
        periodExpense += tx.amount;
      }
    }
    final periodNet = periodIncome - periodExpense;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
          child: _buildDateSelectorHeader(state),
        ),

        // Quick Period Summary Strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isDayView ? 'DAILY INCOME' : 'MONTHLY INCOME', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text('+${_currencyFormatter.format(periodIncome)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_isDayView ? 'DAILY EXPENSES' : 'MONTHLY EXPENSES', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text('-${_currencyFormatter.format(periodExpense)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_isDayView ? 'DAILY NET' : 'MONTHLY NET', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text(
                      _currencyFormatter.format(periodNet),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: periodNet >= 0 ? AppColors.primary : Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _categoryFilterChip('ALL'),
              _categoryFilterChip('INCOME'),
              _categoryFilterChip('EXPENSE'),
              _categoryFilterChip('YOGHURT'),
              _categoryFilterChip('DAIRY'),
              _categoryFilterChip('LIVESTOCK'),
              _categoryFilterChip('POULTRY'),
            ],
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _isDayView
                            ? 'No transactions recorded for ${DateFormat('d MMMM yyyy').format(_selectedDate)}.'
                            : 'No transactions recorded for ${DateFormat('MMMM yyyy').format(_selectedDate)}.',
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'This day is clear. Tap "+ Record Tx" to record a new entry.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tx = filteredTransactions[index];
                    final isIncome = tx.transactionType == 'income';
                    final isReconciled = tx.isReconciled;
                    final isManual = _isManualTransaction(tx);
                    final isYoghurt = tx.category.toLowerCase().contains('yoghurt');

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: () => _showLedgerActionsBottomSheet(context, tx),
                        leading: CircleAvatar(
                          backgroundColor: isYoghurt
                              ? (isIncome ? Colors.cyan.shade100 : Colors.amber.shade100)
                              : (isIncome ? Colors.green.shade50 : Colors.red.shade50),
                          child: Icon(
                            _getCategoryIcon(tx.category, isIncome),
                            color: isYoghurt
                                ? (isIncome ? Colors.cyan.shade800 : Colors.amber.shade900)
                                : (isIncome ? Colors.green : Colors.red),
                            size: 22,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                tx.description?.isNotEmpty == true ? tx.description! : _formatCategoryLabel(tx.category),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            if (isYoghurt)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.cyan.shade300, width: 0.5),
                                ),
                                child: const Text('YOGHURT', style: TextStyle(color: Colors.cyan, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            if (isManual)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.purple.shade200, width: 0.5),
                                ),
                                child: const Text('MANUAL', style: TextStyle(color: Colors.purple, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isReconciled ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: isReconciled ? Colors.green.shade200 : Colors.orange.shade200, width: 0.5),
                              ),
                              child: Text(
                                isReconciled ? 'APPROVED' : 'PENDING',
                                style: TextStyle(color: isReconciled ? Colors.green : Colors.orange.shade900, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${_formatCategoryLabel(tx.category)} • ${DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${_currencyFormatter.format(tx.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome ? Colors.green : Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _categoryFilterChip(String label) {
    final isSelected = _ledgerCategoryFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        onSelected: (val) {
          setState(() {
            _ledgerCategoryFilter = label;
          });
        },
      ),
    );
  }

  IconData _getCategoryIcon(String cat, bool isIncome) {
    switch (cat.toLowerCase()) {
      case 'yoghurt_sales':
        return Icons.icecream;
      case 'yoghurt_expense':
        return Icons.factory_outlined;
      case 'yoghurt_raw_material_transfer':
        return Icons.swap_horiz;
      case 'milk_sales':
        return Icons.water_drop;
      case 'animal_sales':
        return Icons.pets;
      case 'poultry_sales':
      case 'hatchery_sales':
        return Icons.egg;
      case 'feed':
        return Icons.grass;
      case 'medication':
        return Icons.medication;
      case 'labor':
        return Icons.badge;
      case 'equipment':
        return Icons.build;
      case 'utilities':
        return Icons.bolt;
      default:
        return isIncome ? Icons.trending_up : Icons.trending_down;
    }
  }

  void _showLedgerActionsBottomSheet(BuildContext context, LocalTransaction tx) {
    final isManual = _isManualTransaction(tx);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        final isIncome = tx.transactionType == 'income';
        final isReconciled = tx.isReconciled;

        String displayLink = 'None';
        if (tx.relatedEntityType != null && tx.relatedEntityId != null) {
          if (tx.relatedEntityType == 'animal') {
            final match = _animalsList.firstWhere(
              (a) => a.id.toLowerCase() == tx.relatedEntityId!.toLowerCase(),
              orElse: () => _InventoryCachedItem('', ''),
            );
            displayLink = match.display.isNotEmpty ? match.display : 'Animal ID: ${tx.relatedEntityId}';
          } else if (tx.relatedEntityType == 'poultry_batch') {
            final match = _flocksList.firstWhere(
              (f) => f.id.toLowerCase() == tx.relatedEntityId!.toLowerCase(),
              orElse: () => _InventoryCachedItem('', ''),
            );
            displayLink = match.display.isNotEmpty ? match.display : 'Flock ID: ${tx.relatedEntityId}';
          } else {
            displayLink = '${tx.relatedEntityType?.replaceAll('_', ' ').toUpperCase()} (${tx.relatedEntityId})';
          }
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tx.description?.isNotEmpty == true ? tx.description! : _formatCategoryLabel(tx.category),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Text(
                      '${isIncome ? '+' : '-'}${_currencyFormatter.format(tx.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Category: ${_formatCategoryLabel(tx.category)}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate)}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Linked Asset: $displayLink', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),

                // Reconcile and Actions for ALL entries
                Row(
                  children: [
                    if (!isReconciled) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            BlocProvider.of<FinanceBloc>(context).add(ReconcileTransactionEvent(tx.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction audited & reconciled successfully.')),
                            );
                          },
                          icon: const Icon(Icons.verified_outlined, color: Colors.green),
                          label: const Text('Reconcile', style: TextStyle(color: Colors.green)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 6),
                              Text('RECONCILED (AUDITED)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    if (isManual && !isReconciled) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            _showEditTransactionDialog(context, tx);
                          },
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                          label: const Text('Edit', style: TextStyle(color: AppColors.primary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _confirmDeleteTransaction(context, tx);
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        label: const Text('Delete', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteTransaction(BuildContext context, LocalTransaction tx) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${tx.description ?? tx.category}" (₦${tx.amount.toStringAsFixed(2)})? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              BlocProvider.of<FinanceBloc>(context).add(DeleteTransactionEvent(tx.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmClearLedger(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Clear All Ledger Entries'),
        content: const Text('This will permanently delete ALL recorded financial transactions from local storage and cloud database. Proceed with caution!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              BlocProvider.of<FinanceBloc>(context).add(ClearAllTransactionsEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All financial transactions cleared.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditTransactionDialog(BuildContext context, LocalTransaction tx) {
    if (tx.isReconciled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reconciled transactions cannot be edited. You can only delete them.')),
      );
      return;
    }

    String type = tx.transactionType;
    String category = tx.category;
    final amountCtrl = TextEditingController(text: tx.amount.toString());
    final descCtrl = TextEditingController(text: tx.description ?? '');
    DateTime selectedDate = tx.transactionDate;

    bool linkToEntity = tx.relatedEntityType != null && tx.relatedEntityId != null;
    String entityType = tx.relatedEntityType ?? 'animal';
    String? selectedEntityId = tx.relatedEntityId;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final categoryOptions = type == 'income'
                ? ['milk_sales', 'yoghurt_sales', 'animal_sales', 'poultry_sales', 'hatchery_sales', 'misc']
                : ['feed', 'yoghurt_expense', 'yoghurt_raw_material_transfer', 'medication', 'labor', 'equipment', 'utilities', 'misc'];

            if (!categoryOptions.contains(category)) {
              category = categoryOptions.first;
            }

            final entityListOptions = entityType == 'animal' ? _animalsList : _flocksList;
            if (selectedEntityId == null && entityListOptions.isNotEmpty) {
              selectedEntityId = entityListOptions.first.id;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Edit Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('EXPENSE')),
                            selected: type == 'expense',
                            selectedColor: Colors.red.shade100,
                            labelStyle: TextStyle(color: type == 'expense' ? Colors.red.shade900 : Colors.black),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  type = 'expense';
                                  category = 'feed';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('INCOME')),
                            selected: type == 'income',
                            selectedColor: Colors.green.shade100,
                            labelStyle: TextStyle(color: type == 'income' ? Colors.green.shade900 : Colors.black),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  type = 'income';
                                  category = 'milk_sales';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount (₦) *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                      items: categoryOptions.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(_formatCategoryLabel(c)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showResponsiveCalendarPicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Transaction Date *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                      return;
                    }

                    Navigator.pop(dialogCtx);

                    final payload = {
                      'transaction_type': type,
                      'category': category,
                      'amount': amt,
                      'description': descCtrl.text.trim(),
                      'transaction_date': selectedDate.toIso8601String(),
                      'related_entity_type': (linkToEntity && selectedEntityId != null) ? entityType : 'manual',
                      if (linkToEntity && selectedEntityId != null)
                        'related_entity_id': selectedEntityId,
                    };

                    BlocProvider.of<FinanceBloc>(context).add(UpdateTransactionEvent(tx.id, payload));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction updated.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('UPDATE', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        String type = 'expense';
        String category = 'feed';
        final amountCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        DateTime selectedDate = _selectedDate; // Defaults to currently selected ledger date!

        bool linkToEntity = false;
        String entityType = 'animal';
        String? selectedEntityId;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final categoryOptions = type == 'income'
                ? ['milk_sales', 'yoghurt_sales', 'animal_sales', 'poultry_sales', 'hatchery_sales', 'misc']
                : ['feed', 'yoghurt_expense', 'yoghurt_raw_material_transfer', 'medication', 'labor', 'equipment', 'utilities', 'misc'];

            if (!categoryOptions.contains(category)) {
              category = categoryOptions.first;
            }

            final entityListOptions = entityType == 'animal' ? _animalsList : _flocksList;
            if (selectedEntityId == null && entityListOptions.isNotEmpty) {
              selectedEntityId = entityListOptions.first.id;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Record Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('EXPENSE')),
                            selected: type == 'expense',
                            selectedColor: Colors.red.shade100,
                            labelStyle: TextStyle(color: type == 'expense' ? Colors.red.shade900 : Colors.black),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  type = 'expense';
                                  category = 'feed';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('INCOME')),
                            selected: type == 'income',
                            selectedColor: Colors.green.shade100,
                            labelStyle: TextStyle(color: type == 'income' ? Colors.green.shade900 : Colors.black),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  type = 'income';
                                  category = 'milk_sales';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount (₦) *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                      items: categoryOptions.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(_formatCategoryLabel(c)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => category = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () async {
                        final picked = await showResponsiveCalendarPicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Transaction Date *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      title: const Text('Link to Animal/Flock?', style: TextStyle(fontSize: 13)),
                      value: linkToEntity,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() => linkToEntity = val ?? false);
                      },
                    ),

                    if (linkToEntity) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Animal'),
                              selected: entityType == 'animal',
                              onSelected: (val) {
                                if (val) {
                                  setDialogState(() {
                                    entityType = 'animal';
                                    selectedEntityId = _animalsList.isNotEmpty ? _animalsList.first.id : null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Flock'),
                              selected: entityType == 'poultry_batch',
                              onSelected: (val) {
                                if (val) {
                                  setDialogState(() {
                                    entityType = 'poultry_batch';
                                    selectedEntityId = _flocksList.isNotEmpty ? _flocksList.first.id : null;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (entityListOptions.isEmpty)
                        const Text('No records found.', style: TextStyle(color: Colors.red, fontSize: 12))
                      else
                        Autocomplete<_InventoryCachedItem>(
                          displayStringForOption: (option) => option.display,
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) return entityListOptions;
                            return entityListOptions.where((option) {
                              return option.display.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (selection) {
                            setDialogState(() => selectedEntityId = selection.id);
                          },
                          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                            return TextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Search linked item',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                      return;
                    }

                    Navigator.pop(dialogCtx);

                    final payload = {
                      'transaction_type': type,
                      'category': category,
                      'amount': amt,
                      'description': descCtrl.text.trim(),
                      'transaction_date': selectedDate.toIso8601String(),
                      'related_entity_type': (linkToEntity && selectedEntityId != null) ? entityType : 'manual',
                      if (linkToEntity && selectedEntityId != null)
                        'related_entity_id': selectedEntityId,
                    };

                    BlocProvider.of<FinanceBloc>(context).add(AddTransaction(payload));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction recorded successfully.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // TAB 3: ADVISOR & CULLING
  // ──────────────────────────────────────────────
  Widget _buildCullingTab(BuildContext context, FinanceLoaded state) {
    return FutureBuilder<List<_InventoryCachedItem>>(
      future: sl<AnimalsRepository>().getAnimals().then((list) => list.map((a) {
        return _InventoryCachedItem(a.id, '${a.tagId} (${a.breed ?? "Unknown"})');
      }).toList()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final animals = snapshot.data!;
        if (animals.isEmpty) {
          return const Center(child: Text('No animals available for profit analysis.'));
        }

        return _AnimalFinancialDetailView(animals: animals);
      },
    );
  }

  static String _formatCategoryLabel(String cat) {
    switch (cat.toLowerCase()) {
      case 'yoghurt_sales':
        return 'Yoghurt Sales';
      case 'yoghurt_expense':
        return 'Yoghurt Factory Op. Expense';
      case 'yoghurt_raw_material_transfer':
        return 'Milk Transfer (Yoghurt)';
      case 'milk_sales':
        return 'Milk Sales (Dairy)';
      case 'animal_sales':
        return 'Livestock Sales';
      case 'poultry_sales':
        return 'Poultry & Egg Sales';
      case 'hatchery_sales':
        return 'Hatchery Sales';
      case 'feed':
        return 'Feed & Fodder';
      case 'medication':
        return 'Medication & Health';
      case 'labor':
        return 'Labor & Payroll';
      case 'equipment':
        return 'Equipment & Repairs';
      case 'utilities':
        return 'Utilities & Fuel';
      case 'misc':
        return 'Miscellaneous';
      default:
        return cat.replaceAll('_', ' ').toUpperCase();
    }
  }
}

class _AnimalFinancialDetailView extends StatefulWidget {
  final List<_InventoryCachedItem> animals;
  const _AnimalFinancialDetailView({required this.animals});

  @override
  State<_AnimalFinancialDetailView> createState() => _AnimalFinancialDetailViewState();
}

class _AnimalFinancialDetailViewState extends State<_AnimalFinancialDetailView> {
  late String _selectedAnimalId;
  Future<Map<String, dynamic>>? _summaryFuture;

  @override
  void initState() {
    super.initState();
    _selectedAnimalId = widget.animals.first.id;
    _fetchSummary();
  }

  void _fetchSummary() {
    setState(() {
      _summaryFuture = sl<FinanceRepository>().getAnimalFinancialSummary(_selectedAnimalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedAnimalId,
                  items: widget.animals.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Text(a.display, style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _selectedAnimalId = val;
                      _fetchSummary();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }
              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('No data found.'));
              }

              final rev = (data['direct_revenue'] as num?)?.toDouble() ?? 0.0;
              final totalCost = (data['total_costs'] as num?)?.toDouble() ?? 0.0;
              final net = (data['net_profit'] as num?)?.toDouble() ?? 0.0;
              final feedCost = (data['feed_cost'] as num?)?.toDouble() ?? 0.0;
              final healthCost = (data['health_cost'] as num?)?.toDouble() ?? 0.0;
              final laborCost = (data['labor_cost'] as num?)?.toDouble() ?? 0.0;
              final overhead = (data['allocated_overhead'] as num?)?.toDouble() ?? 0.0;

              final depr = data['depreciation'] as Map<String, dynamic>? ?? {};
              final bookVal = (depr['current_book_value'] as num?)?.toDouble() ?? 0.0;
              final cumDepr = (depr['cumulative_depreciation'] as num?)?.toDouble() ?? 0.0;

              final txs = (data['transactions'] as List?) ?? [];

              final f = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _metricBox('Direct Revenue', f.format(rev), Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _metricBox('Direct & Shared Costs', f.format(totalCost), Colors.red)),
                      const SizedBox(width: 8),
                      Expanded(child: _metricBox('Net Profit', f.format(net), net >= 0 ? AppColors.primary : Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('COST ALLOCATION BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 12),
                          _rowItem('Feed Cost', f.format(feedCost)),
                          _rowItem('Health & Medication', f.format(healthCost)),
                          _rowItem('Direct Labor Allocated', f.format(laborCost)),
                          _rowItem('Overhead Allocated', f.format(overhead)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CAPITAL ASSET & DEPRECIATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 12),
                          _rowItem('Current Book Value', f.format(bookVal)),
                          _rowItem('Cumulative Depreciation', f.format(cumDepr)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('LINKED TRANSACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                              Text('${txs.length} logs', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (txs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: Text('No individual transaction history logged yet.', style: TextStyle(fontSize: 12, color: Colors.grey))),
                            )
                          else
                            ...txs.map((t) {
                              final isIncome = t['type'] == 'income';
                              final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                              return Column(
                                children: [
                                  ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(t['description']?.isNotEmpty == true ? t['description'] : t['category'].toString().replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    subtitle: Text('${t['category']} • ${t['date']?.substring(0, 10)}', style: const TextStyle(fontSize: 11)),
                                    trailing: Text(
                                      '${isIncome ? '+' : '-'}${f.format(amt)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                ],
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
