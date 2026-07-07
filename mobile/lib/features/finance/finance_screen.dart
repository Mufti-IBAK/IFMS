import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../animals/animals_repository.dart';
import '../poultry/poultry_repository.dart';
import '../../core/database/local_db.dart';
import 'package:ifms_mobile/core/widgets/custom_charts.dart';
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
            final isMap = a is Map;
            final id = (isMap ? a['id'] : a.id)?.toString() ?? '';
            final tag = (isMap ? a['tag_id'] : a.tagId)?.toString() ?? 'Unknown';
            final species = (isMap ? a['species'] : a.species)?.toString() ?? 'Cow';
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
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is FinanceLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('ENTERPRISE FINANCIALS'),
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => BlocProvider.of<FinanceBloc>(context).add(LoadFinanceData()),
                    child: const Text('Retry'),
                  ),
                ],
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

  // ──────────────────────────────────────────────
  // TAB 1: DASHBOARD
  // ──────────────────────────────────────────────
  Widget _buildDashboardTab(BuildContext context, FinanceLoaded state) {
    final revenue = double.tryParse(state.overallProfit['total_revenue']?.toString() ?? '0.0') ?? 0.0;
    final expenses = double.tryParse(state.overallProfit['total_expenses']?.toString() ?? '0.0') ?? 0.0;
    final profit = double.tryParse(state.overallProfit['net_profit']?.toString() ?? '0.0') ?? 0.0;
    final margin = revenue > 0 ? (profit / revenue) * 100 : 0.0;

    // Compute weekly totals for the last 4 weeks (7-day intervals)
    final weeklyRevenue = List.filled(4, 0.0);
    final weeklyExpenses = List.filled(4, 0.0);
    final now = DateTime.now();
    for (var tx in state.transactions) {
      final daysDiff = now.difference(tx.transactionDate).inDays;
      if (daysDiff >= 0 && daysDiff < 28) {
        final weekIdx = (daysDiff / 7).floor(); // 0 to 3
        if (weekIdx >= 0 && weekIdx < 4) {
          if (tx.transactionType == 'income') {
            weeklyRevenue[3 - weekIdx] += tx.amount;
          } else {
            weeklyExpenses[3 - weekIdx] += tx.amount;
          }
        }
      }
    }

    // Prepare Category Donut Chart data
    final List<double> donutValues = [];
    final List<String> donutLabels = [];
    final List<Color> donutColors = [
      Colors.teal,
      Colors.amber.shade700,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
      Colors.orange,
    ];

    if (state.overallProfit['breakdown'] != null) {
      final breakdown = state.overallProfit['breakdown'] as Map;
      breakdown.forEach((k, v) {
        final val = double.tryParse(v.toString()) ?? 0.0;
        if (val > 0) {
          donutValues.add(val);
          donutLabels.add(k.toString().replaceAll('_', ' ').toUpperCase());
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _compactFormatter.format(revenue),
                Icons.trending_up,
                Colors.green,
                '₦ ${revenue.toStringAsFixed(0)}',
              ),
              _kpiCard(
                'Total Expenses',
                _compactFormatter.format(expenses),
                Icons.trending_down,
                Colors.red,
                '₦ ${expenses.toStringAsFixed(0)}',
              ),
              _kpiCard(
                'Net Cash Flow',
                _compactFormatter.format(profit),
                Icons.account_balance_wallet,
                profit >= 0 ? AppColors.primary : Colors.orange,
                '₦ ${profit.toStringAsFixed(0)}',
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

          // CASH FLOW COMPARISON CHART
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
                      Icon(Icons.bar_chart, color: Colors.teal),
                      SizedBox(width: 8),
                      Text('WEEKLY CASH FLOW (LAST 4 WEEKS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomBarChart(
                    primaryData: weeklyRevenue,
                    secondaryData: weeklyExpenses,
                    labels: const ['Wk -3', 'Wk -2', 'Wk -1', 'This Wk'],
                    primaryColor: Colors.green.shade700,
                    secondaryColor: Colors.red.shade700,
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
                      centerValue: _compactFormatter.format(revenue),
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
  Widget _buildLedgerTab(BuildContext context, FinanceLoaded state) {
    final transactions = state.transactions;

    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions recorded in the farm ledger yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx.transactionType == 'income';
        final isReconciled = tx.isReconciled;

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
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.shade200, width: 0.5),
                    ),
                    child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${tx.category.replaceAll('_', ' ').toUpperCase()} • ${DateFormat('yyyy-MM-dd').format(tx.transactionDate)}',
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
    );
  }

  void _showLedgerActionsBottomSheet(BuildContext context, LocalTransaction tx) {
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
                Text('Date: ${DateFormat('yyyy-MM-dd').format(tx.transactionDate)}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Linked Asset: $displayLink', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (!isReconciled) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            BlocProvider.of<FinanceBloc>(context).add(ReconcileTransactionEvent(tx.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction submitted for reconciliation approval.')),
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
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _confirmReverseTransaction(context, tx);
                        },
                        icon: const Icon(Icons.settings_backup_restore, color: Colors.white),
                        label: const Text('Reverse Tx', style: TextStyle(color: Colors.white)),
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

  void _confirmReverseTransaction(BuildContext context, LocalTransaction tx) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Confirm Transaction Reversal'),
        content: Text('This will post an opposite entry to balance out the ₦${tx.amount.toStringAsFixed(2)} transaction. Proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              BlocProvider.of<FinanceBloc>(context).add(ReverseTransactionEvent(tx.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reversal transaction recorded.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('REVERSE ENTRY', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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

                    InputDatePickerFormField(
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDate: selectedDate,
                      onDateSubmitted: (d) {
                        setDialogState(() => selectedDate = d);
                      },
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
                      'transaction_date': DateFormat('yyyy-MM-dd').format(selectedDate),
                      if (linkToEntity && selectedEntityId != null) ...{
                        'related_entity_type': entityType,
                        'related_entity_id': selectedEntityId,
                      }
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
