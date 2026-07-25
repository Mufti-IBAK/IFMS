import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import '../../core/theme/app_colors.dart';
import 'poultry_repository.dart';
import 'poultry_bloc.dart';
import 'widgets/log_flock_treatment_sheet.dart';
import 'widgets/log_flock_feed_sheet.dart';
import 'widgets/log_flock_adjustment_sheet.dart';

class PoultryFlockProfileScreen extends StatefulWidget {
  final LocalPoultryBatche batch;
  const PoultryFlockProfileScreen({super.key, required this.batch});

  @override
  State<PoultryFlockProfileScreen> createState() => _PoultryFlockProfileScreenState();
}

class _PoultryFlockProfileScreenState extends State<PoultryFlockProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = sl<PoultryRepository>();

  late LocalPoultryBatche _currentBatch;
  Map<String, double> _financialSummary = {};
  List<LocalPoultryFeedLog> _feedLogs = [];
  List<LocalPoultryTreatment> _treatments = [];
  List<LocalPoultryAdjustment> _adjustments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentBatch = widget.batch;
    _tabController = TabController(length: 4, vsync: this);
    _refreshFlockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshFlockData() async {
    setState(() => _loading = true);
    final latestBatch = await (_repo.db.select(_repo.db.localPoultryBatches)..where((t) => t.id.equals(widget.batch.id))).getSingleOrNull();
    final summary = await _repo.getFlockFinancialSummary(widget.batch.id);
    final feeds = await _repo.getFlockFeedLogs(widget.batch.id);
    final meds = await _repo.getFlockTreatments(widget.batch.id);
    final adjs = await _repo.getFlockAdjustments(widget.batch.id);

    if (mounted) {
      setState(() {
        if (latestBatch != null) _currentBatch = latestBatch;
        _financialSummary = summary;
        _feedLogs = feeds;
        _treatments = meds;
        _adjustments = adjs;
        _loading = false;
      });
    }
  }

  int get _daysActive {
    return DateTime.now().difference(_currentBatch.startDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final b = _currentBatch;
    final totalLoss = b.initialCount - b.currentCount;
    final mortalityPct = b.initialCount > 0 ? (totalLoss / b.initialCount * 100) : 0.0;
    final netProfit = _financialSummary['netProfitLoss'] ?? 0.0;

    return BlocListener<PoultryBloc, PoultryState>(
      listener: (context, state) {
        if (state is PoultryLoaded) {
          _refreshFlockData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flock Profile #${b.batchNumber}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshFlockData,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.grass), text: 'FEED LOGS'),
              Tab(icon: Icon(Icons.medication), text: 'HEALTH & MEDS'),
              Tab(icon: Icon(Icons.heart_broken), text: 'MORTALITY & RESTOCK'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'PROFITABILITY'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // KPI Top Dashboard Header Card
                  Container(
                    width: double.infinity,
                    color: AppColors.primaryContainer.withOpacity(0.4),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${b.houseName} (${b.breed ?? "Poultry"})',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                Text(
                                  'Started ${DateFormat('MMM dd, yyyy').format(b.startDate)} ($_daysActive days active)',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            Chip(
                              label: Text(b.status.toUpperCase()),
                              backgroundColor: b.status == 'active' ? Colors.green.shade100 : Colors.grey.shade200,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: b.status == 'active' ? Colors.green.shade900 : Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 4 Cards Row
                        Row(
                          children: [
                            _kpiSmallCard('Active Count', '${b.currentCount} / ${b.initialCount}', Icons.pets, Colors.blue),
                            const SizedBox(width: 8),
                            _kpiSmallCard('Mortality Rate', '${mortalityPct.toStringAsFixed(1)}%', Icons.heart_broken, Colors.red),
                            const SizedBox(width: 8),
                            _kpiSmallCard('Feed Expenses', '₦${(_financialSummary['cumulativeFeedCost'] ?? 0.0).toStringAsFixed(0)}', Icons.grass, Colors.orange),
                            const SizedBox(width: 8),
                            _kpiSmallCard('Net Profit/Loss', '₦${netProfit.toStringAsFixed(0)}', Icons.payments, netProfit >= 0 ? Colors.green : Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFeedTab(),
                        _buildHealthTab(),
                        _buildAdjustmentsTab(),
                        _buildProfitabilityTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _kpiSmallCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center, maxLines: 1),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: FEED LOGS ---
  Widget _buildFeedTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => LogFlockFeedSheet(batchId: widget.batch.id),
          ).then((_) => _refreshFlockData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Feed'),
        backgroundColor: Colors.orange,
      ),
      body: _feedLogs.isEmpty
          ? const Center(child: Text('No feed logged for this flock yet. Tap "+ Log Feed" to record daily feed.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _feedLogs.length,
              itemBuilder: (ctx, idx) {
                final f = _feedLogs[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(Icons.grass, color: Colors.white),
                    ),
                    title: Text('${f.feedName} (${f.quantityKg.toStringAsFixed(1)} kg)'),
                    subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(f.logDate)} | ₦${f.costPerKg}/kg\nSource: ${f.feedSourceType.toUpperCase()}'),
                    trailing: Text(
                      '₦${f.totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // --- TAB 2: HEALTH & TREATMENTS ---
  Widget _buildHealthTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => LogFlockTreatmentSheet(batchId: widget.batch.id),
          ).then((_) => _refreshFlockData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Treatment'),
        backgroundColor: Colors.teal,
      ),
      body: _treatments.isEmpty
          ? const Center(child: Text('No treatments/medications recorded yet. Tap "+ Log Treatment" to record one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _treatments.length,
              itemBuilder: (ctx, idx) {
                final t = _treatments[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.medication, color: Colors.white),
                    ),
                    title: Text('${t.medicationName} (${t.quantityUsed} ${t.unit})'),
                    subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(t.treatmentDate)}\n${t.notes ?? "No notes"}'),
                    trailing: Text(
                      '₦${t.totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // --- TAB 3: MORTALITY & ADJUSTMENTS ---
  Widget _buildAdjustmentsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => LogFlockAdjustmentSheet(batchId: widget.batch.id),
          ).then((_) => _refreshFlockData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Adjustment'),
        backgroundColor: AppColors.error,
      ),
      body: _adjustments.isEmpty
          ? const Center(child: Text('No headcount adjustments recorded yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _adjustments.length,
              itemBuilder: (ctx, idx) {
                final a = _adjustments[idx];
                final isAdd = a.adjustmentType == 'addition';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdd ? Colors.green : Colors.red,
                      child: Icon(isAdd ? Icons.add_circle : Icons.remove_circle, color: Colors.white),
                    ),
                    title: Text('${a.adjustmentType.toUpperCase()}: ${a.headCount} birds'),
                    subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(a.adjustmentDate)}\nReason: ${a.reasonNotes ?? "N/A"}'),
                  ),
                );
              },
            ),
    );
  }

  // --- TAB 4: PROFITABILITY & FINANCIAL BREAKDOWN ---
  Widget _buildProfitabilityTab() {
    final acqCost = _financialSummary['acquisitionCost'] ?? 0.0;
    final feedCost = _financialSummary['cumulativeFeedCost'] ?? 0.0;
    final medCost = _financialSummary['cumulativeHealthCost'] ?? 0.0;
    final totalExp = _financialSummary['totalExpenses'] ?? 0.0;
    final revenue = _financialSummary['totalRevenue'] ?? 0.0;
    final netProfit = _financialSummary['netProfitLoss'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Flock Financial Performance Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _summaryRow('Initial Chick / Stock Purchase Cost', '₦${acqCost.toStringAsFixed(2)}', Colors.black87),
                  const Divider(),
                  _summaryRow('Cumulative Feed Expenses', '₦${feedCost.toStringAsFixed(2)}', Colors.orange),
                  const Divider(),
                  _summaryRow('Cumulative Health & Medication Expenses', '₦${medCost.toStringAsFixed(2)}', Colors.teal),
                  const Divider(),
                  _summaryRow('TOTAL FLOCK EXPENSES', '₦${totalExp.toStringAsFixed(2)}', Colors.red, isBold: true),
                  const Divider(thickness: 2),
                  _summaryRow('TOTAL REVENUE FROM SALES', '₦${revenue.toStringAsFixed(2)}', Colors.green, isBold: true),
                  const Divider(thickness: 2),
                  _summaryRow(
                    'NET ESTIMATED FLOCK PROFIT / LOSS',
                    '₦${netProfit.toStringAsFixed(2)}',
                    netProfit >= 0 ? Colors.green : Colors.red,
                    isBold: true,
                    fontSize: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color, {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
