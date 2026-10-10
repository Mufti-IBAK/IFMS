import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/database/local_db.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_calendar_dialog.dart';
import 'yoghurt_bloc.dart';
import 'yoghurt_repository.dart';

class YoghurtScreen extends StatefulWidget {
  const YoghurtScreen({super.key});

  @override
  State<YoghurtScreen> createState() => _YoghurtScreenState();
}

class _YoghurtScreenState extends State<YoghurtScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showDateInventoryBreakdown = false;

  final _currencyFmt = NumberFormat.currency(symbol: '₦ ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => YoghurtBloc(sl<YoghurtRepository>())..add(LoadYoghurtData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('YOGHURT PROCESSING HUB'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.blender), text: 'Batches'),
              Tab(icon: Icon(Icons.point_of_sale), text: 'Sales & Ledger'),
              Tab(icon: Icon(Icons.assignment_return), text: 'Returns'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Expenses'),
            ],
          ),
        ),
        body: BlocConsumer<YoghurtBloc, YoghurtState>(
          listener: (context, state) {
            if (state is YoghurtError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is YoghurtActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is YoghurtLoading && state is! YoghurtLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is YoghurtLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(context, state),
                  _buildBatchesTab(context, state),
                  _buildSalesTab(context, state),
                  _buildReturnsTab(context, state),
                  _buildExpensesTab(context, state),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: DASHBOARD OVERVIEW
  // ---------------------------------------------------------------------------
  Widget _buildDashboardTab(BuildContext context, YoghurtLoaded state) {
    final netProfit = state.totalRevenue - state.totalExpenses;

    return RefreshIndicator(
      onRefresh: () async => context.read<YoghurtBloc>().add(LoadYoghurtData()),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cold Store Tank Card & Price Setter Card
            Card(
              elevation: 3,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.water_drop, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cold Store Milk Tank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                          const SizedBox(height: 2),
                          Text('${state.inStoreMilkLiters.toStringAsFixed(1)} Liters Available', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text('Valued @ ${_currencyFmt.format(state.currentMilkPrice)}/L', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showTransferMilkDialog(context, state),
                      icon: const Icon(Icons.sync_alt, size: 16),
                      label: const Text('Transfer Milk'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Yoghurt Selling Price Configuration Card
            Card(
              elevation: 2,
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.shade300)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.sell, color: Colors.amber, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selling Price Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown)),
                          const SizedBox(height: 2),
                          Text('Bottle: ${_currencyFmt.format(state.pricePerBottle)}  •  Pack (12 btls): ${_currencyFmt.format(state.pricePerPack)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showPriceSetterDialog(context, state),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('CHANGE PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.brown.shade800, side: BorderSide(color: Colors.brown.shade400)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Store Inventory Header & Optional Date Breakdown Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Current Yoghurt Inventory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: Icon(_showDateInventoryBreakdown ? Icons.calendar_month : Icons.storage, size: 14, color: _showDateInventoryBreakdown ? Colors.white : Colors.purple),
                  label: Text(_showDateInventoryBreakdown ? 'Hide Breakdown' : 'Show Date Breakdown', style: TextStyle(fontSize: 11, color: _showDateInventoryBreakdown ? Colors.white : Colors.purple.shade900)),
                  selected: _showDateInventoryBreakdown,
                  selectedColor: Colors.purple.shade700,
                  backgroundColor: Colors.purple.shade50,
                  onSelected: (val) => setState(() => _showDateInventoryBreakdown = val),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Total Inventory Overview Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade900]),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL YOGHURT IN STORE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            const SizedBox(height: 6),
                            Text('${state.totalBottlesInStore} Bottles', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            Text('(~${state.totalPacksInStore} Packs of 12)', style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.liquor, color: Colors.white, size: 36),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white30, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInvMetric('Today\'s Output', '${state.todayBottlesProduced} btls'),
                        Container(height: 24, width: 1, color: Colors.white30),
                        _buildInvMetric('Monthly Output', '${state.monthlyBottlesProduced} btls'),
                        Container(height: 24, width: 1, color: Colors.white30),
                        _buildInvMetric('Replaced', '${state.totalReplacedBottles} btls'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Optional Date-by-Date Batch Breakdown Panel
            if (_showDateInventoryBreakdown) ...[
              const SizedBox(height: 14),
              Card(
                color: Colors.purple.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.purple.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.date_range, color: Colors.purple, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Remaining Inventory Grouped by Production Date',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.batchInventoryByDate.isEmpty)
                        const Text('No active remaining production batches in store.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: state.batchInventoryByDate.entries.map((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.purple.shade200),
                                boxShadow: const [BoxShadow(color: Colors.purple, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.purple),
                                  const SizedBox(width: 6),
                                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.purple.shade700, borderRadius: BorderRadius.circular(12)),
                                    child: Text('${entry.value} btls', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Financial Summary Metrics Grid
            const Text('Financial & Ledger Performance', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildKpiCard('Total Revenue', _currencyFmt.format(state.totalRevenue), Icons.payments, Colors.green),
                _buildKpiCard('Operational Expenses', _currencyFmt.format(state.totalExpenses), Icons.receipt_long, Colors.red.shade700),
                _buildKpiCard('Net Operating Margin', _currencyFmt.format(netProfit), Icons.trending_up, netProfit >= 0 ? Colors.teal : Colors.deepOrange),
                _buildKpiCard('Customer Receivables', _currencyFmt.format(state.totalClientReceivables), Icons.account_balance_wallet, Colors.orange.shade800),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecordBatchDialog(context, state),
                    icon: const Icon(Icons.blender, size: 18),
                    label: const Text('New Batch', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecordSaleDialog(context, state),
                    icon: const Icon(Icons.point_of_sale, size: 18),
                    label: const Text('Record Sale', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: MODERN PRODUCTION BATCHES CARDS (WITH EDIT & DELETE)
  // ---------------------------------------------------------------------------
  Widget _buildBatchesTab(BuildContext context, YoghurtLoaded state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordBatchDialog(context, state),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW BATCH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: state.batchHistory.isEmpty
          ? const Center(child: Text('No yoghurt production batches recorded yet.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.batchHistory.length,
              itemBuilder: (context, index) {
                final b = state.batchHistory[index];
                final pDateStr = DateFormat('dd MMM yyyy').format(b.productionDate);
                final percentRemaining = b.bottlesProduced > 0 ? (b.bottlesRemaining / b.bottlesProduced) : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.teal.shade100),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.primary, Colors.teal.shade800]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(b.batchNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            Row(
                              children: [
                                Text(pDateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showRecordBatchDialog(context, state, batchToEdit: b),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showDeleteConfirmDialog(
                                    context,
                                    title: 'Delete Batch',
                                    message: 'Are you sure you want to delete Batch #${b.batchNumber}? This action cannot be undone.',
                                    onConfirm: () => context.read<YoghurtBloc>().add(DeleteYoghurtBatchEvent(b.id)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Output Produced', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    '${b.bottlesProduced} Bottles (${b.packsProduced} Packs)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: b.bottlesRemaining > 0 ? Colors.green.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: b.bottlesRemaining > 0 ? Colors.green : Colors.grey),
                              ),
                              child: Text(
                                '${b.bottlesRemaining} Left in Store',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: b.bottlesRemaining > 0 ? Colors.green.shade900 : Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Stock Remaining Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentRemaining.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(percentRemaining > 0.3 ? Colors.green : Colors.amber.shade800),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Input Metrics Details
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Expanded(child: _buildBatchSubMetric('Raw Milk', '${b.milkInputLiters.toStringAsFixed(1)} L')),
                              Expanded(child: _buildBatchSubMetric('Cost/L', _currencyFmt.format(b.milkCostPerLiter))),
                              Expanded(child: _buildBatchSubMetric('Total Milk', _currencyFmt.format(b.totalMilkCost))),
                              Expanded(child: _buildBatchSubMetric('Add. Costs', _currencyFmt.format(b.additionalCosts))),
                            ],
                          ),
                        ),
                        if (b.notes != null && b.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Notes: ${b.notes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.teal)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBatchSubMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: MODERN SALES & CUSTOMER LEDGER CARDS (WITH EDIT & DELETE)
  // ---------------------------------------------------------------------------
  Widget _buildSalesTab(BuildContext context, YoghurtLoaded state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordSaleDialog(context, state),
        backgroundColor: Colors.teal.shade800,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('RECORD SALE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: state.salesHistory.isEmpty
          ? const Center(child: Text('No yoghurt sales recorded yet.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.salesHistory.length,
              itemBuilder: (context, index) {
                final s = state.salesHistory[index];
                final sDateStr = DateFormat('dd MMM yyyy').format(s.saleDate);

                Color balanceColor = Colors.green;
                String balanceLabel = 'Cleared (Paid in Full)';
                if (s.balancePayer == 'client_owes_farm') {
                  balanceColor = Colors.red;
                  balanceLabel = 'Client Owes: ${_currencyFmt.format(s.balanceDue)}';
                } else if (s.balancePayer == 'farm_owes_client') {
                  balanceColor = Colors.blue;
                  balanceLabel = 'Farm Owes: ${_currencyFmt.format(s.balanceDue)}';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.teal.shade100,
                                    child: const Icon(Icons.person, size: 18, color: Colors.teal),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      s.customerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_currencyFmt.format(s.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showRecordSaleDialog(context, state, saleToEdit: s),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showDeleteConfirmDialog(
                                    context,
                                    title: 'Delete Sale',
                                    message: 'Are you sure you want to delete this sale entry for ${s.customerName}?',
                                    onConfirm: () => context.read<YoghurtBloc>().add(DeleteYoghurtSaleEvent(s.id)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('Qty: ${s.quantityUnits} ${s.saleUnit} (${s.totalBottles} bottles)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            Text('Date: $sDateStr', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Paid: ${_currencyFmt.format(s.amountPaid)}  •  Unit: ${_currencyFmt.format(s.unitPrice)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: balanceColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: balanceColor)),
                              child: Text(balanceLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: balanceColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: MODERN RETURNS CARDS (WITH EDIT & DELETE)
  // ---------------------------------------------------------------------------
  Widget _buildReturnsTab(BuildContext context, YoghurtLoaded state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordReturnDialog(context, state),
        backgroundColor: Colors.amber.shade900,
        icon: const Icon(Icons.assignment_return, color: Colors.white),
        label: const Text('LOG RETURN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: state.returnHistory.isEmpty
          ? const Center(child: Text('No product returns or replacements recorded.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.returnHistory.length,
              itemBuilder: (context, index) {
                final r = state.returnHistory[index];
                final rDateStr = DateFormat('dd MMM yyyy').format(r.returnDate);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                r.customerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(rDateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showRecordReturnDialog(context, state, returnToEdit: r),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showDeleteConfirmDialog(
                                    context,
                                    title: 'Delete Return Record',
                                    message: 'Are you sure you want to delete this return record for ${r.customerName}?',
                                    onConfirm: () => context.read<YoghurtBloc>().add(DeleteYoghurtReturnEvent(r.id)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              avatar: const Icon(Icons.undo, size: 12, color: Colors.white),
                              label: Text('Returned: ${r.returnedBottles} btls', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.amber.shade800,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              avatar: const Icon(Icons.swap_horiz, size: 12, color: Colors.white),
                              label: Text('Replaced: ${r.replacedBottles} btls', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.teal.shade700,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        if (r.description != null && r.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Reason: ${r.description}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 5: MODERN EXPENSES CARDS (WITH EDIT & DELETE)
  // ---------------------------------------------------------------------------
  Widget _buildExpensesTab(BuildContext context, YoghurtLoaded state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordExpenseDialog(context, state),
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('LOG EXPENSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: state.expenseHistory.isEmpty
          ? const Center(child: Text('No yoghurt operational expenses logged.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.expenseHistory.length,
              itemBuilder: (context, index) {
                final e = state.expenseHistory[index];
                final eDateStr = DateFormat('dd MMM yyyy').format(e.expenseDate);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(e.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_currencyFmt.format(e.amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red.shade800)),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showRecordExpenseDialog(context, state, expenseToEdit: e),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showDeleteConfirmDialog(
                                    context,
                                    title: 'Delete Expense',
                                    message: 'Are you sure you want to delete this expense of ${_currencyFmt.format(e.amount)}?',
                                    onConfirm: () => context.read<YoghurtBloc>().add(DeleteYoghurtExpenseEvent(e.id)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(e.category.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.red.shade700,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text('Date: $eDateStr', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: DELETE CONFIRMATION DIALOG
  // ---------------------------------------------------------------------------
  void _showDeleteConfirmDialog(BuildContext context, {required String title, required String message, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL 0: YOGHURT SELLING PRICE SETTER DIALOG
  // ---------------------------------------------------------------------------
  void _showPriceSetterDialog(BuildContext context, YoghurtLoaded state) {
    final formKey = GlobalKey<FormState>();
    final bottleCtrl = TextEditingController(text: state.pricePerBottle.toStringAsFixed(0));
    final packCtrl = TextEditingController(text: state.pricePerPack.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sell, color: Colors.brown),
            SizedBox(width: 8),
            Expanded(child: Text('Set Yoghurt Selling Prices', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: bottleCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Selling Price per Bottle (₦) *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.liquor)),
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid price' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: packCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Selling Price per Pack (12 Bottles) (₦) *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2)),
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid price' : null,
                ),
              ],
            ),
          ),
        ),
      ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                context.read<YoghurtBloc>().add(UpdateYoghurtPriceEvent(
                      pricePerBottle: double.parse(bottleCtrl.text),
                      pricePerPack: double.parse(packCtrl.text),
                    ));
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
            child: const Text('Save Prices'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL 1: TRANSFER RAW MILK TO PRODUCTION
  // ---------------------------------------------------------------------------
  void _showTransferMilkDialog(BuildContext context, YoghurtLoaded state) {
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
          final estCost = qty * state.currentMilkPrice;

          return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.water_drop, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Transfer Raw Milk', overflow: TextOverflow.ellipsis)),
              ],
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cold Store Balance: ${state.inStoreMilkLiters.toStringAsFixed(1)} Liters (@ ${_currencyFmt.format(state.currentMilkPrice)}/L)', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'Quantity to Transfer (Liters) *', border: OutlineInputBorder(), suffixText: 'L'),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (v) {
                          final val = double.tryParse(v ?? '') ?? 0;
                          if (val <= 0) return 'Enter valid quantity';
                          if (val > state.inStoreMilkLiters) return 'Exceeds available cold store milk';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Material Value:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(_currencyFmt.format(estCost), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    context.read<YoghurtBloc>().add(TransferMilkToProductionEvent(
                          quantityLiters: double.parse(qtyCtrl.text),
                        ));
                    Navigator.pop(dialogCtx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Transfer'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL 2: RECORD / EDIT PRODUCTION BATCH
  // ---------------------------------------------------------------------------
  void _showRecordBatchDialog(BuildContext context, YoghurtLoaded state, {LocalYoghurtBatche? batchToEdit}) {
    final formKey = GlobalKey<FormState>();
    DateTime productionDate = batchToEdit?.productionDate ?? DateTime.now();

    final milkInputCtrl = TextEditingController(text: batchToEdit != null ? batchToEdit.milkInputLiters.toStringAsFixed(1) : '50');
    final bottlesCtrl = TextEditingController(text: batchToEdit != null ? batchToEdit.bottlesProduced.toString() : '120');
    final addCostsCtrl = TextEditingController(text: batchToEdit != null ? batchToEdit.additionalCosts.toStringAsFixed(0) : '2000');
    final notesCtrl = TextEditingController(text: batchToEdit?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final bottles = int.tryParse(bottlesCtrl.text) ?? 0;
          final packs = bottles ~/ 12;

          return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.blender, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(batchToEdit == null ? 'Record Production Batch' : 'Edit Production Batch', overflow: TextOverflow.ellipsis)),
              ],
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showResponsiveCalendarPicker(
                          context: context,
                          initialDate: productionDate,
                        );
                        if (picked != null) {
                          setDialogState(() => productionDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Production Date: ${DateFormat('yyyy-MM-dd').format(productionDate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: milkInputCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Raw Milk Used (Liters) *', border: OutlineInputBorder(), suffixText: 'L'),
                      validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter milk volume' : null,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('ℹ️ Raw milk price auto-calculated @ ${_currencyFmt.format(state.currentMilkPrice)}/L', style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: bottlesCtrl,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Total Bottles Output *', border: OutlineInputBorder(), suffixText: 'Bottles'),
                      onChanged: (_) => setDialogState(() {}),
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter bottles output' : null,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Equivalent to $packs Packs (1 Pack = 12 Bottles)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addCostsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Additional Costs (Culture, Packaging ₦)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Batch Notes / Observations', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
          ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    if (batchToEdit == null) {
                      context.read<YoghurtBloc>().add(RecordYoghurtBatchEvent(
                            productionDate: productionDate,
                            milkInputLiters: double.parse(milkInputCtrl.text),
                            bottlesProduced: int.parse(bottlesCtrl.text),
                            additionalCosts: double.tryParse(addCostsCtrl.text) ?? 0.0,
                            notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                          ));
                    } else {
                      context.read<YoghurtBloc>().add(EditYoghurtBatchEvent(
                            id: batchToEdit.id,
                            productionDate: productionDate,
                            milkInputLiters: double.parse(milkInputCtrl.text),
                            bottlesProduced: int.parse(bottlesCtrl.text),
                            additionalCosts: double.tryParse(addCostsCtrl.text) ?? 0.0,
                            notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                          ));
                    }
                    Navigator.pop(dialogCtx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: Text(batchToEdit == null ? 'Save Batch' : 'Update Batch'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL 3: RECORD / EDIT YOGHURT SALE
  // ---------------------------------------------------------------------------
  void _showRecordSaleDialog(BuildContext context, YoghurtLoaded state, {LocalYoghurtSale? saleToEdit}) {
    final formKey = GlobalKey<FormState>();
    DateTime saleDate = saleToEdit?.saleDate ?? DateTime.now();

    final nameCtrl = TextEditingController(text: saleToEdit?.customerName ?? '');
    final phoneCtrl = TextEditingController(text: saleToEdit?.customerPhone ?? '');
    final descCtrl = TextEditingController(text: saleToEdit?.description ?? '');
    final qtyCtrl = TextEditingController(text: saleToEdit != null ? saleToEdit.quantityUnits.toString() : '5');

    String saleUnit = saleToEdit?.saleUnit ?? 'packs'; // "packs" or "bottles"
    final defaultPrice = saleUnit == 'packs' ? state.pricePerPack : state.pricePerBottle;
    final unitPriceCtrl = TextEditingController(text: saleToEdit != null ? saleToEdit.unitPrice.toStringAsFixed(0) : defaultPrice.toStringAsFixed(0));
    final paidCtrl = TextEditingController(text: saleToEdit != null ? saleToEdit.amountPaid.toStringAsFixed(0) : (defaultPrice * 5).toStringAsFixed(0));

    String? selectedBatchId = saleToEdit?.selectedBatchId ?? 'auto';

    double calculateTotal() {
      final q = int.tryParse(qtyCtrl.text) ?? 0;
      final p = double.tryParse(unitPriceCtrl.text) ?? 0.0;
      return q * p;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final totalBill = calculateTotal();
          final amountPaid = double.tryParse(paidCtrl.text) ?? 0.0;
          final diff = totalBill - amountPaid;
          final balanceDue = diff.abs();

          String balanceText = 'Cleared';
          Color balanceColor = Colors.green;

          if (diff > 0.01) {
            balanceText = 'Client Owes Farm: ${_currencyFmt.format(balanceDue)}';
            balanceColor = Colors.red;
          } else if (diff < -0.01) {
            balanceText = 'Farm Owes Client: ${_currencyFmt.format(balanceDue)}';
            balanceColor = Colors.blue;
          }

          return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.point_of_sale, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(child: Text(saleToEdit == null ? 'Record Yoghurt Sale' : 'Edit Yoghurt Sale', overflow: TextOverflow.ellipsis)),
              ],
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showResponsiveCalendarPicker(
                          context: context,
                          initialDate: saleDate,
                        );
                        if (picked != null) {
                          setDialogState(() => saleDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sale Date: ${DateFormat('yyyy-MM-dd').format(saleDate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Specific Batch Selection Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedBatchId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Deduct From Production Batch / Date *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range, color: Colors.teal),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'auto',
                          child: Text('⚡ Auto-Deduct Oldest First (FIFO)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal), overflow: TextOverflow.ellipsis),
                        ),
                        ...state.batchHistory.where((b) => b.bottlesRemaining > 0).map((b) {
                          final dateStr = DateFormat('dd/MM/yyyy').format(b.productionDate);
                          return DropdownMenuItem(
                            value: b.id,
                            child: Text('$dateStr - Batch #${b.batchNumber} (${b.bottlesRemaining} btls left)', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                      ],
                      onChanged: (v) => setDialogState(() => selectedBatchId = v),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Customer / Client Name *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                      validator: (v) => v?.trim().isEmpty == true ? 'Enter customer name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Customer Phone', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: saleUnit,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unit Type *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2)),
                      items: const [
                        DropdownMenuItem(value: 'packs', child: Text('Packs (1 Pack = 12 Bottles)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'bottles', child: Text('Bottles (Single Unit)', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) {
                        setDialogState(() {
                          saleUnit = v!;
                          if (saleUnit == 'packs') {
                            unitPriceCtrl.text = state.pricePerPack.toStringAsFixed(0);
                          } else {
                            unitPriceCtrl.text = state.pricePerBottle.toStringAsFixed(0);
                          }
                          paidCtrl.text = calculateTotal().toStringAsFixed(0);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: 'Quantity ($saleUnit) *', border: const OutlineInputBorder()),
                      onChanged: (_) => setDialogState(() {
                        paidCtrl.text = calculateTotal().toStringAsFixed(0);
                      }),
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid quantity' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: unitPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: 'Unit Price per $saleUnit (₦) *', border: const OutlineInputBorder()),
                      onChanged: (_) => setDialogState(() {
                        paidCtrl.text = calculateTotal().toStringAsFixed(0);
                      }),
                      validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter unit price' : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Bill Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_currencyFmt.format(totalBill), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: paidCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Amount Paid (₦) *', border: OutlineInputBorder()),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: balanceColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: balanceColor)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(balanceText, style: TextStyle(fontWeight: FontWeight.bold, color: balanceColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    if (saleToEdit == null) {
                      context.read<YoghurtBloc>().add(RecordYoghurtSaleEvent(
                            saleDate: saleDate,
                            customerName: nameCtrl.text.trim(),
                            customerPhone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                            description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                            saleUnit: saleUnit,
                            quantityUnits: int.parse(qtyCtrl.text),
                            unitPrice: double.parse(unitPriceCtrl.text),
                            amountPaid: double.tryParse(paidCtrl.text) ?? 0.0,
                            selectedBatchId: selectedBatchId,
                          ));
                    } else {
                      context.read<YoghurtBloc>().add(EditYoghurtSaleEvent(
                            id: saleToEdit.id,
                            saleDate: saleDate,
                            customerName: nameCtrl.text.trim(),
                            customerPhone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                            description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                            saleUnit: saleUnit,
                            quantityUnits: int.parse(qtyCtrl.text),
                            unitPrice: double.parse(unitPriceCtrl.text),
                            amountPaid: double.tryParse(paidCtrl.text) ?? 0.0,
                            selectedBatchId: selectedBatchId,
                          ));
                    }
                    Navigator.pop(dialogCtx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
                child: Text(saleToEdit == null ? 'Save Sale' : 'Update Sale'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL 4: RECORD / EDIT RETURN & REPLACEMENT
  // ---------------------------------------------------------------------------
  void _showRecordReturnDialog(BuildContext context, YoghurtLoaded state, {LocalYoghurtReturn? returnToEdit}) {
    final formKey = GlobalKey<FormState>();
    DateTime returnDate = returnToEdit?.returnDate ?? DateTime.now();

    final nameCtrl = TextEditingController(text: returnToEdit?.customerName ?? '');
    final descCtrl = TextEditingController(text: returnToEdit?.description ?? 'Spoiled / Expired Stock Replacement');
    final initialCtrl = TextEditingController(text: returnToEdit != null ? returnToEdit.initialBoughtBottles.toString() : '24');
    final returnedCtrl = TextEditingController(text: returnToEdit != null ? returnToEdit.returnedBottles.toString() : '6');
    final replacedCtrl = TextEditingController(text: returnToEdit != null ? returnToEdit.replacedBottles.toString() : '6');

    String? selectedBatchId = returnToEdit?.selectedBatchId ?? 'auto';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.assignment_return, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(child: Text(returnToEdit == null ? 'Log Product Return' : 'Edit Product Return', overflow: TextOverflow.ellipsis)),
              ],
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showResponsiveCalendarPicker(
                          context: context,
                          initialDate: returnDate,
                        );
                        if (picked != null) {
                          setDialogState(() => returnDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Return Date: ${DateFormat('yyyy-MM-dd').format(returnDate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Icon(Icons.calendar_today, size: 16, color: Colors.amber),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Specific Batch Selection Dropdown for replacement deduction
                    DropdownButtonFormField<String>(
                      value: selectedBatchId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Deduct Replacement From Batch / Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2, color: Colors.amber),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'auto',
                          child: Text('⚡ Auto-Deduct Oldest First (FIFO)', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        ...state.batchHistory.where((b) => b.bottlesRemaining > 0).map((b) {
                          final dateStr = DateFormat('dd/MM/yyyy').format(b.productionDate);
                          return DropdownMenuItem(
                            value: b.id,
                            child: Text('$dateStr - Batch #${b.batchNumber} (${b.bottlesRemaining} btls left)', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                      ],
                      onChanged: (v) => setDialogState(() => selectedBatchId = v),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Customer / Client Name *', border: OutlineInputBorder()),
                      validator: (v) => v?.trim().isEmpty == true ? 'Enter customer name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Reason for Return *', border: OutlineInputBorder()),
                      validator: (v) => v?.trim().isEmpty == true ? 'Enter reason' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: initialCtrl,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Initial Bottles Bought *', border: OutlineInputBorder()),
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid initial count' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: returnedCtrl,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Bottles Returned *', border: OutlineInputBorder()),
                      validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Enter valid count' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: replacedCtrl,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Bottles Replaced from Store *', border: OutlineInputBorder()),
                      validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Enter valid count' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    if (returnToEdit == null) {
                      context.read<YoghurtBloc>().add(RecordYoghurtReturnEvent(
                            returnDate: returnDate,
                            customerName: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            initialBoughtBottles: int.parse(initialCtrl.text),
                            returnedBottles: int.parse(returnedCtrl.text),
                            replacedBottles: int.parse(replacedCtrl.text),
                            selectedBatchId: selectedBatchId,
                          ));
                    } else {
                      context.read<YoghurtBloc>().add(EditYoghurtReturnEvent(
                            id: returnToEdit.id,
                            returnDate: returnDate,
                            customerName: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            initialBoughtBottles: int.parse(initialCtrl.text),
                            returnedBottles: int.parse(returnedCtrl.text),
                            replacedBottles: int.parse(replacedCtrl.text),
                            selectedBatchId: selectedBatchId,
                          ));
                    }
                    Navigator.pop(dialogCtx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
                child: Text(returnToEdit == null ? 'Log Return' : 'Update Return'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL 5: RECORD / EDIT OPERATIONAL EXPENSE
  // ---------------------------------------------------------------------------
  void _showRecordExpenseDialog(BuildContext context, YoghurtLoaded state, {LocalYoghurtExpense? expenseToEdit}) {
    final formKey = GlobalKey<FormState>();
    DateTime expenseDate = expenseToEdit?.expenseDate ?? DateTime.now();

    final descCtrl = TextEditingController(text: expenseToEdit?.description ?? '');
    final amountCtrl = TextEditingController(text: expenseToEdit != null ? expenseToEdit.amount.toStringAsFixed(0) : '');
    String category = expenseToEdit?.category ?? 'culture_ingredients';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(expenseToEdit == null ? 'Log Yoghurt Expense' : 'Edit Yoghurt Expense', overflow: TextOverflow.ellipsis)),
              ],
            ),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () async {
                          final picked = await showResponsiveCalendarPicker(
                            context: context,
                            initialDate: expenseDate,
                          );
                          if (picked != null) {
                            setDialogState(() => expenseDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Expense Date: ${DateFormat('yyyy-MM-dd').format(expenseDate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Icon(Icons.calendar_today, size: 16, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'Expense Description *', border: OutlineInputBorder()),
                        validator: (v) => v?.trim().isEmpty == true ? 'Enter description' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'culture_ingredients', child: Text('Culture & Starter Ingredients', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'sugar_flavoring', child: Text('Sugar & Flavors', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'packaging', child: Text('Bottles, Caps & Labels', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'utility_power', child: Text('Electricity & Power', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'maintenance', child: Text('Factory Equipment Maintenance', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'logistics_fuel', child: Text('Logistics & Delivery Fuel', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'other', child: Text('Other General Expense', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setDialogState(() => category = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'Amount Used (₦) *', border: OutlineInputBorder()),
                        validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid amount' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    if (expenseToEdit == null) {
                      context.read<YoghurtBloc>().add(RecordYoghurtExpenseEvent(
                            expenseDate: expenseDate,
                            description: descCtrl.text.trim(),
                            category: category,
                            amount: double.parse(amountCtrl.text),
                          ));
                    } else {
                      context.read<YoghurtBloc>().add(EditYoghurtExpenseEvent(
                            id: expenseToEdit.id,
                            expenseDate: expenseDate,
                            description: descCtrl.text.trim(),
                            category: category,
                            amount: double.parse(amountCtrl.text),
                          ));
                    }
                    Navigator.pop(dialogCtx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
                child: Text(expenseToEdit == null ? 'Save Expense' : 'Update Expense'),
              ),
            ],
          );
        },
      ),
    );
  }
}
