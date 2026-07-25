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
import '../settings/settings_controller.dart';
import 'finance_bloc.dart';

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
  int _selectedWeek = 0; // 0 = All Weeks, 1 = Wk 1 (1-7), 2 = Wk 2 (8-14), 3 = Wk 3 (15-21), 4 = Wk 4 (22+)

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
            final id = a.id;
            final tag = a.tagId;
            final species = a.species;
            return _InventoryCachedItem(id, '$tag ($species)');
          }).toList();

          _flocksList = flocks.map((f) {
            return _InventoryCachedItem(f.id, '${f.batchNumber} (Flock)');
          }).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state is FinanceError) {
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
        if (state is FinanceLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is FinanceLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('FINANCIAL LEDGER'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Export Monthly Account Statement PDF',
                  onPressed: () {
                    FinancePdfExportService.exportMonthlyAccountStatementPdf(
                      transactions: state.transactions,
                      selectedMonth: _selectedMonth,
                      ownerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.ownerEmail : null,
                      managerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.managerEmail : null,
                    );
                  },
                ),
                if (_tabController.index == 1)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                    tooltip: 'Clear Ledger',
                    onPressed: () => _confirmClearLedger(context),
                  ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: AppColors.secondary,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
                  Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Ledger'),
                  Tab(icon: Icon(Icons.gavel_outlined), text: 'Culling Recommendations'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(context, state),
                _buildLedgerTab(context, state),
                _buildCullingTab(context, state),
              ],
            ),
            floatingActionButton: _tabController.index == 1
                ? FloatingActionButton.extended(
                    onPressed: () => _showLogTransactionDialog(context),
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Record Tx', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : null,
          );
        } else if (state is FinanceError) {
          return Scaffold(
            appBar: AppBar(title: const Text('FINANCIAL LEDGER')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => BlocProvider.of<FinanceBloc>(context).add(LoadFinanceData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Unknown State')),
        );
      },
    );
  }

  Widget _buildWeekSegmentTab(int weekIndex, String label) {
    final isSelected = _selectedWeek == weekIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedWeek = weekIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade800,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // TAB 1: DASHBOARD
  // ──────────────────────────────────────────────
  Widget _buildDashboardTab(BuildContext context, FinanceLoaded state) {
    // 1. Filter transactions by Month, Week, AND Reconciliation status
    final filteredTxs = state.transactions.where((t) {
      if (!t.isReconciled) return false; // ONLY RECONCILED TRANSACTIONS REFLECT ON FINANCIAL RECORDS & DASHBOARD
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
    final Map<String, double> categoryBreakdown = {};

    for (var tx in filteredTxs) {
      final amt = tx.amount;
      if (tx.transactionType == 'income') {
        totalRevenue += amt;
      } else {
        totalExpenses += amt;
      }
      categoryBreakdown[tx.category] = (categoryBreakdown[tx.category] ?? 0.0) + amt;
    }

    final netProfit = totalRevenue - totalExpenses;
    final margin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

    // 2. Compute Bar Graph Data (CustomBarChart) for the selected week / month
    final List<String> chartLabels = [];
    final List<double> chartRevenue = [];
    final List<double> chartExpenses = [];

    if (_selectedWeek == 0) {
      // All Weeks Mode (4 Weeks of the Month)
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
      // Specific Week Mode: plot days of that specific week!
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

    // 3. Category Donut Chart Data
    final List<double> donutValues = [];
    final List<String> donutLabels = [];
    categoryBreakdown.forEach((k, v) {
      if (v > 0) {
        donutValues.add(v);
        donutLabels.add(k.replaceAll('_', ' ').toUpperCase());
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
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'PERIOD: ${DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
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
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
                            trailing: Text(
                              _currencyFormatter.format(val),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: isRevenueCat ? Colors.green : Colors.red),
                            ),
                          ),
                          const Divider(height: 1, thickness: 0.5),
                        ],
                      );
                    }),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _kpiCard(String label, String value, IconData icon, Color color, String subText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          const SizedBox(height: 2),
          Text(subText, style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // TAB 2: CONSOLIDATED LEDGER
  // ──────────────────────────────────────────────
  Widget _buildMonthSelectorHeader(FinanceLoaded state) {
    final monthFormat = DateFormat('MMMM yyyy');
    final isCurrentMonth = _selectedMonth.year == DateTime.now().year && _selectedMonth.month == DateTime.now().month;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.purple),
            tooltip: 'Previous Month',
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
              });
            },
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                helpText: 'SELECT LEDGER MONTH',
              );
              if (picked != null) {
                setState(() {
                  _selectedMonth = DateTime(picked.year, picked.month, 1);
                });
              }
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.purple, size: 18),
                const SizedBox(width: 4),
                Text(
                  monthFormat.format(_selectedMonth).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.purple),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.purple, size: 20),
                tooltip: 'Export Statement PDF',
                onPressed: () {
                  FinancePdfExportService.exportMonthlyAccountStatementPdf(
                    transactions: state.transactions,
                    selectedMonth: _selectedMonth,
                    ownerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.ownerEmail : null,
                    managerEmail: sl.isRegistered<SettingsController>() ? sl<SettingsController>().profile?.managerEmail : null,
                  );
                },
              ),
              if (!isCurrentMonth)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime.now();
                    });
                  },
                  child: const Text('THIS MONTH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
                ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.purple),
                tooltip: 'Next Month',
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // TAB 2: CONSOLIDATED LEDGER
  // ──────────────────────────────────────────────
  Widget _buildLedgerTab(BuildContext context, FinanceLoaded state) {
    final filteredTransactions = state.transactions.where((tx) {
      return tx.transactionDate.year == _selectedMonth.year &&
             tx.transactionDate.month == _selectedMonth.month;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: _buildMonthSelectorHeader(state),
        ),
        Expanded(
          child: filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'No transactions recorded for ${DateFormat('MMMM yyyy').format(_selectedMonth)}.',
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'This month is a clean sheet. Use "+ Record Tx" or operate farm modules to log activity.',
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

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: () => _showLedgerActionsBottomSheet(context, tx),
                        leading: CircleAvatar(
                          backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                          child: Icon(
                            isIncome ? Icons.trending_up : Icons.trending_down,
                            color: isIncome ? Colors.green : Colors.red,
                            size: 22,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                tx.description?.isNotEmpty == true ? tx.description! : tx.category.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
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
                                child: const Text('MANUAL', style: TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (isReconciled)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green.shade200, width: 0.5),
                                ),
                                child: const Text('APPROVED', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${tx.category.replaceAll('_', ' ').toUpperCase()} • ${DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate)}',
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
                    Text(
                      tx.description?.isNotEmpty == true ? tx.description! : tx.category.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                Text('Category: ${tx.category.replaceAll('_', ' ').toUpperCase()}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate)}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Linked Asset: $displayLink', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                if (isManual) ...[
                  Row(
                    children: [
                      if (!isReconciled) ...[
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
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(sheetCtx);
                              BlocProvider.of<FinanceBloc>(context).add(ReconcileTransactionEvent(tx.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Transaction reconciled successfully.')),
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
                                Text('RECONCILED (LOCKED)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                              ],
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
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock_outline, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'System Auto-Captured Entry\nThis transaction was automatically logged by operational activity (poultry, pharmacy, staff advance, animal sale) and is read-only for audit compliance.',
                            style: TextStyle(fontSize: 11, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                ? ['milk_sales', 'animal_sales', 'poultry_sales', 'hatchery_sales', 'misc']
                : ['feed', 'medication', 'labor', 'equipment', 'utilities', 'misc'];

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
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                      items: categoryOptions.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.replaceAll('_', ' ').toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
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
                      const SnackBar(content: Text('Transaction updated successfully.')),
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

  // ──────────────────────────────────────────────
  // TAB 3: CULLING RECOMMENDER
  // ──────────────────────────────────────────────
  Widget _buildCullingTab(BuildContext context, FinanceLoaded state) {
    final list = state.cullingRecommendations;

    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.done_all, color: Colors.green, size: 48),
              SizedBox(height: 12),
              Text(
                'ALL COWS ARE ECONOMICALLY PRODUCTIVE',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(height: 6),
              Text('No cows flagged for health, economic or reproductive failures.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final rec = list[index];
        final reasons = rec['reasons'] as List? ?? [];
        final bookValue = double.tryParse(rec['book_value']?.toString() ?? '0.0') ?? 0.0;
        final salvageValue = double.tryParse(rec['salvage_value']?.toString() ?? '0.0') ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                        const Icon(Icons.gavel, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Tag: ${rec['tag_id'] ?? "Unknown"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      'Salvage: ${_currencyFormatter.format(salvageValue)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Flag Reasons:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: reasons.map<Widget>((r) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200, width: 0.5),
                      ),
                      child: Text(
                        r.toString().toUpperCase(),
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Asset Book Value: ${_currencyFormatter.format(bookValue)}', style: const TextStyle(fontSize: 12)),
                    ElevatedButton.icon(
                      onPressed: () => _showCullActionDialog(context, rec),
                      icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                      label: const Text('Cull & Sell', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  void _showCullActionDialog(BuildContext context, Map<String, dynamic> rec) {
    final animalId = rec['animal_id']?.toString() ?? '';
    final tag = rec['tag_id']?.toString() ?? '';
    final salvageValue = double.tryParse(rec['salvage_value']?.toString() ?? '0.0') ?? 0.0;

    final priceCtrl = TextEditingController(text: salvageValue.toString());

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Execute Cull: Animal $tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This action will archive the animal status to "sold" and record a transaction in your accounts ledger.'),
              const SizedBox(height: 16),
              TextField(textCapitalization: TextCapitalization.sentences, controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Sale Price (₦) *',
                  hintText: 'e.g. 150000',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                final price = double.tryParse(priceCtrl.text) ?? salvageValue;
                Navigator.pop(dialogCtx);

                try {
                  await sl<AnimalsRepository>().updateAnimal(animalId, {'status': 'sold'});

                  if (context.mounted) {
                    BlocProvider.of<FinanceBloc>(context).add(AddTransaction({
                      'transaction_type': 'income',
                      'category': 'animal_sales',
                      'amount': price,
                      'related_entity_type': 'animal',
                      'related_entity_id': animalId,
                      'description': 'CULLED AND SOLD: Cow $tag',
                      'transaction_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    }));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cow $tag culled successfully and registered sale of ₦${price.toStringAsFixed(2)}')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to cull: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('CULL & SELL', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // TRANSACTION DIALOG LOGGER
  // ──────────────────────────────────────────────
  void _showLogTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        String type = 'expense';
        String category = 'feed';
        final amountCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        DateTime selectedDate = DateTime.now();

        bool linkToEntity = false;
        String entityType = 'animal';
        String? selectedEntityId;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final categoryOptions = type == 'income'
                ? ['milk_sales', 'animal_sales', 'poultry_sales', 'hatchery_sales', 'misc']
                : ['feed', 'medication', 'labor', 'equipment', 'utilities', 'misc'];

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

                    TextField(textCapitalization: TextCapitalization.sentences, controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount (₦) *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                      items: categoryOptions.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.replaceAll('_', ' ').toUpperCase()),
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
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
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

                    TextField(textCapitalization: TextCapitalization.sentences, controller: descCtrl,
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
                            return TextField(textCapitalization: TextCapitalization.sentences, controller: textEditingController,
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
}
