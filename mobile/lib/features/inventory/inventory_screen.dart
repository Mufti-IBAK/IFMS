import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/database/local_db.dart';
import '../../core/utils/feed_report_service.dart';
import '../animals/animals_repository.dart';
import 'inventory_bloc.dart';
import 'inventory_repository.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFmt = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

  // Cached state data to prevent unmounting and resetting the active tab index on reload
  List<dynamic>? _cachedItems;
  List<dynamic>? _cachedLogs;
  List<LocalFeedFormula>? _cachedFormulas;
  List<LocalFeedConsumptionLog>? _cachedConsumption;
  Map<String, String> _animalTagMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      // Rebuild the Floating Action Button when switching tabs
      setState(() {});
    });
    _loadAnimalTags();
  }

  Future<void> _loadAnimalTags() async {
    try {
      final repo = sl<AnimalsRepository>();
      final list = await repo.getAnimals();
      final map = <String, String>{};
      for (var a in list) {
        final isMap = a is Map;
        final id = ((isMap ? a['id'] : a.id)?.toString() ?? '').toLowerCase();
        final tag = (isMap ? a['tag_id'] : a.tagId)?.toString() ?? '';
        final species = ((isMap ? a['species'] : a.species) ?? '').toString().toUpperCase();
        if (id.isNotEmpty) {
          map[id] = '$tag ($species)';
        }
      }
      if (mounted) {
        setState(() {
          _animalTagMap = map;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is InventoryLoaded) {
          _cachedItems = state.items;
          _cachedLogs = state.logs;
          _cachedFormulas = state.formulas;
          _cachedConsumption = state.consumptionLogs;
        }
      },
      builder: (context, state) {
        final isLoading = state is InventoryLoading;
        final hasCachedData = _cachedItems != null;

        // Update caches if the current state is loaded
        if (state is InventoryLoaded) {
          _cachedItems = state.items;
          _cachedLogs = state.logs;
          _cachedFormulas = state.formulas;
          _cachedConsumption = state.consumptionLogs;
        }

        // Show full screen indicator if loading and there's no cache
        if (isLoading && !hasCachedData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('FARM INVENTORY'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.storage), text: 'Stock Items'),
                Tab(icon: Icon(Icons.science), text: 'Feed Formulas'),
                Tab(icon: Icon(Icons.assignment), text: 'Feeding Plan'),
                Tab(icon: Icon(Icons.point_of_sale), text: 'POS & Ops'),
                Tab(icon: Icon(Icons.history), text: 'Activity Logs'),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => _exportPdf(context),
                icon: const Icon(Icons.picture_as_pdf, color: AppColors.tertiary),
                tooltip: 'Export Feed Report',
              ),
              IconButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Synchronizing feed inventory...')),
                  );
                  await sl<SyncManager>().triggerSync();
                  if (context.mounted) {
                    BlocProvider.of<InventoryBloc>(context).add(LoadInventoryItems());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feed inventory sync complete!')),
                    );
                  }
                },
                icon: const Icon(Icons.sync, color: AppColors.info),
              ),
            ],
          ),
          body: Column(
            children: [
              // Inline Linear progress indicator when loading in the background
              if (isLoading)
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStockTab(context, _cachedItems ?? []),
                    _buildFormulasTab(context, _cachedFormulas ?? [], _cachedItems ?? []),
                    FeedingPlanTab(formulas: _cachedFormulas ?? []),
                    OperationsPOSTab(formulas: _cachedFormulas ?? [], items: _cachedItems ?? []),
                    _buildLogsTab(context, _cachedLogs ?? [], _cachedConsumption ?? [], _cachedItems ?? []),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFAB(context, _cachedItems ?? []),
        );
      },
    );
  }

  void _exportPdf(BuildContext context) {
    if (_cachedItems != null && _cachedFormulas != null && _cachedConsumption != null) {
      FeedReportService.generateFeedAnalyticsReport(
        items: _cachedItems!,
        formulas: _cachedFormulas!,
        consumptionLogs: _cachedConsumption!,
        repository: sl<InventoryRepository>(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait until data is loaded to export PDF')),
      );
    }
  }

  // ═══════════════════════════════════════════
  // DYNAMIC FAB BASED ON CURRENT TAB
  // ═══════════════════════════════════════════

  Widget? _buildFAB(BuildContext context, List<dynamic> feedItems) {
    switch (_tabController.index) {
      case 0: // Stock Items Tab
        return FloatingActionButton.extended(
          key: const ValueKey('fab_stock'),
          onPressed: () => _showAddFeedItemDialog(context),
          label: const Text('Add Feed Item'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        );
      case 1: // Feed Formulas Tab
        return FloatingActionButton.extended(
          key: const ValueKey('fab_formula'),
          onPressed: () => _showAddFormulaDialog(context),
          label: const Text('New Formula'),
          icon: const Icon(Icons.science),
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
        );
      case 4: // Activity Logs Tab
        return FloatingActionButton.extended(
          key: const ValueKey('fab_logs'),
          onPressed: () => _showLogConsumptionDialog(context),
          label: const Text('Log Feeding'),
          icon: const Icon(Icons.grass),
          backgroundColor: AppColors.tertiary,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }

  // ═══════════════════════════════════════════
  // TAB 1: STOCK ITEMS
  // ═══════════════════════════════════════════

  Widget _buildStockTab(BuildContext context, List<dynamic> items) {
    final lowStock = items.where((i) {
      final stock = double.tryParse(i['current_stock'].toString()) ?? 0.0;
      final threshold = double.tryParse(i['reorder_threshold'].toString()) ?? 0.0;
      return stock <= threshold;
    }).toList();



    double totalValue = 0.0;
    for (var i in items) {
      if (i is Map) {
        final stock = double.tryParse(i['current_stock']?.toString() ?? '0.0') ?? 0.0;
        final costPerUnit = double.tryParse(i['cost_per_unit']?.toString() ?? '0.0') ?? 0.0;
        totalValue += stock * costPerUnit;
      } else {
        // Drift LocalFeedItemData object
        totalValue += (i.currentStock ?? 0.0) * (i.costPerUnit ?? 0.0);
      }
    }

    return Column(
      children: [
        // KPI Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _kpiCard('Total Items', '${items.length}', Icons.inventory_2, AppColors.primary),
              const SizedBox(width: 12),
              _kpiCard('Low Stock', '${lowStock.length}', Icons.warning_amber, AppColors.warning),
              const SizedBox(width: 12),
              _kpiCard('Total Value', _currencyFmt.format(totalValue), Icons.payments, AppColors.secondary),
            ],
          ),
        ),

        // Quick log button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogStockEntryDialog(context),
              icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
              label: const Text('Log Stock Entry / Purchase', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Items list
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No feed items yet. Add one to get started!'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final stock = double.tryParse(item['current_stock'].toString()) ?? 0.0;
                    final threshold = double.tryParse(item['reorder_threshold'].toString()) ?? 0.0;
                    final costPerUnit = double.tryParse(item['cost_per_unit'].toString()) ?? 0.0;
                    final costKg = double.tryParse((item['cost_per_kg'] ?? costPerUnit).toString()) ?? costPerUnit;
                    final weightPerUnit = double.tryParse((item['weight_per_unit'] ?? 1.0).toString()) ?? 1.0;
                    final isLow = stock <= threshold;
                    final maxStock = threshold * 3;
                    final progress = maxStock > 0 ? (stock / maxStock).clamp(0.0, 1.0) : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.grass,
                                  color: isLow ? AppColors.error : AppColors.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        'Pack: ${weightPerUnit.toStringAsFixed(1)} kg/l at ${_currencyFmt.format(costPerUnit)} (${_currencyFmt.format(costKg)}/kg)',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isLow)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('LOW', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Current Stock: ${stock.toStringAsFixed(1)} ${item['unit'] ?? "units"}'),
                                Text('Reorder Level: ${threshold.toStringAsFixed(1)} ${item['unit'] ?? "units"}'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(isLow ? AppColors.error : AppColors.primary),
                              ),
                            ),
                            if (item['supplier'] != null && item['supplier'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Supplier: ${item['supplier']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                            const Divider(height: 24, thickness: 0.5),
                            Align(
                              alignment: Alignment.center,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showLogStockEntryDialog(context, preselectedItemId: item['id'] as String),
                                    icon: const Icon(Icons.add_circle_outline, size: 16),
                                    label: const Text('Update Stock', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showEditFeedItemDialog(context, item),
                                    icon: const Icon(Icons.edit_note, size: 16),
                                    label: const Text('Edit Info', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _confirmDeleteFeedItem(context, item['id'] as String, item['name'] as String),
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Delete', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // TAB 2: FEED FORMULAS
  // ═══════════════════════════════════════════

  Widget _buildFormulasTab(BuildContext context, List<LocalFeedFormula> formulas, List<dynamic> feedItems) {
    if (formulas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No feed formulas yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Create a formula to calculate feed costs', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: formulas.length,
      itemBuilder: (context, index) {
        final formula = formulas[index];
        final unitLabel = _batchUnitLabel(formula.batchUnit);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showFormulaDetails(context, formula, feedItems),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.science, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formula.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Batch Size: ${formula.batchSize.toStringAsFixed(0)} kg ($unitLabel)', style: TextStyle(color: Colors.grey.shade600)),
                        if (formula.notes != null && formula.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(formula.notes!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _batchUnitLabel(String unit) {
    switch (unit) {
      case 'per_tonne':
        return 'Per Tonne';
      case 'per_100kg':
        return 'Per 100kg';
      case 'per_50kg':
        return 'Per 50kg';
      case 'per_1kg':
        return 'Per 1kg';
      default:
        return 'Custom';
    }
  }

  void _showFormulaDetails(BuildContext context, LocalFeedFormula formula, List<dynamic> feedItems) {
    final repo = sl<InventoryRepository>();
    double targetBatch = formula.batchSize;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx2, setSheetState) {
            return BlocBuilder<InventoryBloc, InventoryState>(
              builder: (blocCtx, blocState) {
                if (blocState is! InventoryLoaded) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Find the updated formula from latest BLoC state
                final updatedFormula = blocState.formulas.firstWhere(
                  (f) => f.id == formula.id,
                  orElse: () => formula,
                );

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: repo.calculateFormulaCost(updatedFormula.id, targetBatch),
                  builder: (futureCtx, snapshot) {
                    final calculated = snapshot.data ?? [];
                    final isCalculating = snapshot.connectionState == ConnectionState.waiting;
                    
                    double totalCost = calculated.fold(0.0, (sum, c) => sum + (c['line_cost'] as double));
                    double totalPercent = calculated.fold(0.0, (sum, c) => sum + (c['percentage'] as double));

                    return DraggableScrollableSheet(
                      initialChildSize: 0.85,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      expand: false,
                      builder: (_, scrollController) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: ListView(
                            controller: scrollController,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      updatedFormula.name,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () {
                                      Navigator.of(sheetCtx2).pop();
                                      BlocProvider.of<InventoryBloc>(context).add(DeleteFeedFormula(updatedFormula.id));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Formula deleted')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const Divider(),

                              // Batch size selector
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Calculate For:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  TextButton.icon(
                                    onPressed: () => _showCustomBatchDialog(context, targetBatch, (customVal) {
                                      setSheetState(() => targetBatch = customVal);
                                    }),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Custom Size'),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _batchChip(sheetCtx2, 'Per Tonne (1000kg)', 1000, targetBatch, (v) {
                                    setSheetState(() => targetBatch = v);
                                  }),
                                  _batchChip(sheetCtx2, 'Per 100kg', 100, targetBatch, (v) {
                                    setSheetState(() => targetBatch = v);
                                  }),
                                  _batchChip(sheetCtx2, 'Per 50kg', 50, targetBatch, (v) {
                                    setSheetState(() => targetBatch = v);
                                  }),
                                  _batchChip(sheetCtx2, 'Per 1kg', 1, targetBatch, (v) {
                                    setSheetState(() => targetBatch = v);
                                  }),
                                  if (targetBatch != 1000 && targetBatch != 100 && targetBatch != 50 && targetBatch != 1)
                                    _batchChip(sheetCtx2, 'Custom (${targetBatch.toStringAsFixed(1)}kg)', targetBatch, targetBatch, (v) {}),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Ingredients Table
                              if (isCalculating)
                                const SizedBox(
                                  height: 100,
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              else if (calculated.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(child: Text('No ingredients added yet.')),
                                )
                              else
                                Column(
                                  children: calculated.map((c) {
                                    final double qty = c['quantity_kg'];
                                    final String qtyLabel = qty >= 1.0 
                                        ? '${qty.toStringAsFixed(1)} kg' 
                                        : '${(qty * 1000).toStringAsFixed(0)} g';
                                    final double pct = c['percentage'] as double;
                                    final double costPerUnit = c['cost_per_unit'] as double;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${pct.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          c['feed_item_name'] ?? 'Unknown',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Required: $qtyLabel', style: const TextStyle(fontSize: 12)),
                                              Text(
                                                'Rate: ${_currencyFmt.format(costPerUnit)}/kg',
                                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _currencyFmt.format(c['line_cost']),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                              onPressed: () {
                                                BlocProvider.of<InventoryBloc>(context).add(
                                                  RemoveFormulaIngredient(c['ingredient_id'] as String)
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 16),

                              // Summary Box
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.outlineVariant),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Recipe Percentage:', style: TextStyle(fontWeight: FontWeight.w500)),
                                        Text(
                                          '${totalPercent.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: (totalPercent - 100).abs() < 0.5 ? AppColors.primary : AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Batch Cost (${targetBatch.toStringAsFixed(1)} kg):', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text(_currencyFmt.format(totalCost), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Calculated cost per kg:', style: TextStyle(fontWeight: FontWeight.w500)),
                                        Text(
                                          targetBatch > 0 ? _currencyFmt.format(totalCost / targetBatch) : '—',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Add ingredient button
                              OutlinedButton.icon(
                                onPressed: () => _showAddIngredientDialog(context, updatedFormula.id, blocState.items),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Ingredient'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCustomBatchDialog(BuildContext context, double current, Function(double) onSubmitted) {
    final ctrl = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Custom Batch Size'),
        content: TextField(textCapitalization: TextCapitalization.sentences, controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Batch Size in Kilograms (kg)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final double? val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                onSubmitted(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Calculate'),
          )
        ],
      ),
    );
  }

  Widget _batchChip(BuildContext context, String label, double value, double current, Function(double) onTap) {
    final isSelected = (value - current).abs() < 0.1;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TAB 3: ACTIVITY LOGS
  // ═══════════════════════════════════════════

  Widget _buildLogsTab(BuildContext context, List<dynamic> logs, List<LocalFeedConsumptionLog> consumption, List<dynamic> items) {
    final combined = <Map<String, dynamic>>[];

    for (var log in logs) {
      final itemName = _findItemName(items, log['item_id']?.toString());
      combined.add({
        'type': 'stock',
        'title': '${log['change_type']?.toString().toUpperCase() ?? 'CHANGE'} — $itemName',
        'subtitle': 'Qty: ${log['quantity_change']} | Balance: ${log['balance_after']}',
        'notes': log['notes'] ?? '',
        'date': DateTime.tryParse(log['log_date']?.toString() ?? '') ?? DateTime.now(),
        'icon': Icons.swap_horiz,
        'color': AppColors.info,
      });
    }

    for (var c in consumption) {
      LocalFeedFormula? formula;
      if (_cachedFormulas != null) {
        for (var f in _cachedFormulas!) {
          if (f.id == c.feedItemId) {
            formula = f;
            break;
          }
        }
      }
      final formulaName = formula?.name ?? 'Formulated Feed';
      final animalTag = _animalTagMap[c.animalId.toLowerCase()] ?? c.animalId;
      
      combined.add({
        'type': 'consumption',
        'title': 'FED — $formulaName',
        'subtitle': 'Animal: $animalTag | ${c.quantityKg.toStringAsFixed(1)} kg',
        'notes': c.notes ?? '',
        'date': c.logDate,
        'icon': Icons.grass,
        'color': AppColors.secondary,
      });
    }

    combined.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    if (combined.isEmpty) {
      return const Center(child: Text('No activity logs found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final entry = combined[index];
        final date = entry['date'] as DateTime;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (entry['color'] as Color).withValues(alpha: 0.15),
              child: Icon(entry['icon'] as IconData, color: entry['color'] as Color, size: 20),
            ),
            title: Text(entry['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['subtitle'] as String, style: const TextStyle(fontSize: 12)),
                if ((entry['notes'] as String).isNotEmpty)
                  Text(entry['notes'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            trailing: Text(DateFormat('dd/MM HH:mm').format(date), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ),
        );
      },
    );
  }

  String _findItemName(List<dynamic> items, String? itemId) {
    if (itemId == null) return 'Unknown';
    for (var i in items) {
      if (i is Map && i['id']?.toString() == itemId.toString()) {
        return i['name']?.toString() ?? itemId;
      }
    }
    return itemId;
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ADD FEED ITEM DIALOG (IMPROVED CONFIG)
  // ═══════════════════════════════════════════

  void _showAddFeedItemDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final packSizeCtrl = TextEditingController(text: '50'); // default 50kg bag
    final unitCostCtrl = TextEditingController();
    final initialStockCtrl = TextEditingController(text: '0');
    final thresholdCtrl = TextEditingController(text: '100');
    final supplierCtrl = TextEditingController();
    String purchaseUnit = 'bags';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            // Live calculated values to guide the user
            final double packSize = double.tryParse(packSizeCtrl.text) ?? 1.0;
            final double unitCost = double.tryParse(unitCostCtrl.text) ?? 0.0;
            final double stockUnits = double.tryParse(initialStockCtrl.text) ?? 0.0;

            final double computedCostPerKg = packSize > 0 ? unitCost / packSize : 0.0;
            final double computedTotalStockKg = stockUnits * packSize;

            return AlertDialog(
              title: const Text('Add Feed Stock Item'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(textCapitalization: TextCapitalization.sentences, controller: nameCtrl, decoration: const InputDecoration(labelText: 'Feed Ingredient Name *', hintText: 'e.g. Yellow Maize, GNC')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: purchaseUnit,
                      decoration: const InputDecoration(labelText: 'Purchase Unit (Unit Type) *'),
                      items: ['bags', 'litres', 'kg', 'tonnes'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setDialogState(() => purchaseUnit = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: packSizeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Pack Size / Capacity per unit (kg or litres) *',
                        hintText: 'e.g. 50 for a 50kg bag',
                      ),
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: unitCostCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cost per Unit/Pack (₦) *',
                        hintText: 'e.g. 30000 for one bag',
                      ),
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: initialStockCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Initial Stock (in Units/Bags) *',
                        hintText: 'e.g. 10 bags',
                      ),
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: thresholdCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Reorder Level Threshold (in kg/litres) *',
                        hintText: '100.0',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: supplierCtrl, decoration: const InputDecoration(labelText: 'Supplier Name', hintText: 'e.g. Premier Feed Mills')),
                    const SizedBox(height: 16),
                    
                    // Dynamic live helper calculations
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Computed Cost/kg:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              Text(_currencyFmt.format(computedCostPerKg), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Stock Weight:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              Text('${computedTotalStockKg.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || packSizeCtrl.text.isEmpty || unitCostCtrl.text.isEmpty || initialStockCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    BlocProvider.of<InventoryBloc>(context).add(AddFeedItem({
                      'name': nameCtrl.text.trim(),
                      'unit': purchaseUnit,
                      'weight_per_unit': packSizeCtrl.text.trim(),
                      'cost_per_unit': unitCostCtrl.text.trim(),
                      'current_stock': initialStockCtrl.text.trim(), // Repos converted: stockInUnits * weightPerUnit
                      'reorder_threshold': thresholdCtrl.text.isNotEmpty ? thresholdCtrl.text.trim() : '100',
                      'supplier': supplierCtrl.text.trim(),
                    }));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feed stock item registered!'), backgroundColor: AppColors.secondary),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditFeedItemDialog(BuildContext context, Map<String, dynamic> item) {
    final nameCtrl = TextEditingController(text: item['name']?.toString());
    final packSizeCtrl = TextEditingController(text: (item['weight_per_unit'] ?? 1.0).toString());
    final unitCostCtrl = TextEditingController(text: (item['cost_per_unit'] ?? 0.0).toString());
    
    // For editing stock, let's allow updating stock directly or keeping current
    final weightPerUnit = double.tryParse((item['weight_per_unit'] ?? 1.0).toString()) ?? 1.0;
    final currentStockKg = double.tryParse((item['current_stock'] ?? 0.0).toString()) ?? 0.0;
    final currentStockUnits = currentStockKg / weightPerUnit;

    final initialStockCtrl = TextEditingController(text: currentStockUnits.toStringAsFixed(1));
    final thresholdCtrl = TextEditingController(text: (item['reorder_threshold'] ?? 100.0).toString());
    final supplierCtrl = TextEditingController(text: item['supplier']?.toString() ?? '');
    String purchaseUnit = item['unit']?.toString() ?? 'bags';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final double packSize = double.tryParse(packSizeCtrl.text) ?? 1.0;
            final double unitCost = double.tryParse(unitCostCtrl.text) ?? 0.0;
            final double stockUnits = double.tryParse(initialStockCtrl.text) ?? 0.0;

            final double computedCostPerKg = packSize > 0 ? unitCost / packSize : 0.0;
            final double computedTotalStockKg = stockUnits * packSize;

            return AlertDialog(
              title: Text('Edit Feed Stock Item: ${item['name']}'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(textCapitalization: TextCapitalization.sentences, controller: nameCtrl, decoration: const InputDecoration(labelText: 'Feed Ingredient Name *')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: purchaseUnit,
                      decoration: const InputDecoration(labelText: 'Purchase Unit (Unit Type) *'),
                      items: ['bags', 'litres', 'kg', 'tonnes'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setDialogState(() => purchaseUnit = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: packSizeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Pack Size / Capacity per unit (kg or litres) *',
                      ),
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: unitCostCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cost per Unit/Pack (₦) *',
                      ),
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: initialStockCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Current Stock (in Units/Bags) *',
                      ),
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: thresholdCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Reorder Level Threshold (in kg/litres) *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: supplierCtrl, decoration: const InputDecoration(labelText: 'Supplier Name')),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Computed Cost/kg:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              Text(_currencyFmt.format(computedCostPerKg), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Stock Weight:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              Text('${computedTotalStockKg.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || packSizeCtrl.text.isEmpty || unitCostCtrl.text.isEmpty || initialStockCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    BlocProvider.of<InventoryBloc>(context).add(EditFeedItem(item['id'].toString(), {
                      'name': nameCtrl.text.trim(),
                      'unit': purchaseUnit,
                      'weight_per_unit': packSizeCtrl.text.trim(),
                      'cost_per_unit': unitCostCtrl.text.trim(),
                      'current_stock': initialStockCtrl.text.trim(),
                      'reorder_threshold': thresholdCtrl.text.isNotEmpty ? thresholdCtrl.text.trim() : '100',
                      'supplier': supplierCtrl.text.trim(),
                    }));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feed stock item details updated!'), backgroundColor: AppColors.secondary),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteFeedItem(BuildContext context, String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Feed Stock Item'),
        content: Text('Are you sure you want to delete "$itemName"? This will remove it from the stock dashboard list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<InventoryBloc>(context).add(DeleteFeedItem(itemId));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feed item deleted'), backgroundColor: AppColors.error),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // LOG STOCK ENTRY DIALOG
  // ═══════════════════════════════════════════

  void _showLogStockEntryDialog(BuildContext context, {String? preselectedItemId}) {
    if (_cachedItems == null || _cachedItems!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No feed items available. Register items first.')),
      );
      return;
    }

    String? selectedItemId = preselectedItemId;
    String changeType = 'purchase';
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Map<String, dynamic>? match;
            if (selectedItemId != null) {
              for (var i in _cachedItems!) {
                if (i is Map && i['id'] == selectedItemId) {
                  match = Map<String, dynamic>.from(i);
                  break;
                }
              }
            }
            final String unitLabel = match != null ? (match['unit'] ?? 'units').toString() : 'units';

            return AlertDialog(
              title: const Text('Log Feed Stock Entry'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedItemId,
                      decoration: const InputDecoration(labelText: 'Feed Ingredient *'),
                      items: _cachedItems!.map<DropdownMenuItem<String>>((i) {
                        return DropdownMenuItem(value: i['id'] as String, child: Text(i['name'] as String));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedItemId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: changeType,
                      decoration: const InputDecoration(labelText: 'Entry Type'),
                      items: ['purchase', 'return', 'adjustment', 'waste'].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => changeType = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity ($unitLabel) *',
                        hintText: 'e.g. number of packs/bags or total kg',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes', hintText: 'Optional')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (selectedItemId == null || qtyCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    
                    // Repos expect absolute base qty units.
                    // If we input in bags/packs, we need to convert to base unit weight.
                    final double qtyInput = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                    final double packSize = match != null ? (double.tryParse(match['weight_per_unit']?.toString() ?? '1') ?? 1.0) : 1.0;
                    final double baseQty = qtyInput * packSize;

                    BlocProvider.of<InventoryBloc>(context).add(AddInventoryLog({
                      'item_id': selectedItemId,
                      'change_type': changeType,
                      'quantity_change': baseQty.toString(), // logged in kg/litres
                      'notes': notesCtrl.text.trim(),
                    }));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stock entry logged successfully!'), backgroundColor: AppColors.secondary),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // ADD FORMULA DIALOG
  // ═══════════════════════════════════════════

  void _showAddFormulaDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String batchUnit = 'per_tonne';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            double batchSize = 1000.0;
            if (batchUnit == 'per_100kg') batchSize = 100.0;
            if (batchUnit == 'per_50kg') batchSize = 50.0;
            if (batchUnit == 'per_1kg') batchSize = 1.0;

            return AlertDialog(
              title: const Text('New Feed Formula'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(textCapitalization: TextCapitalization.sentences, controller: nameCtrl, decoration: const InputDecoration(labelText: 'Formula Name *', hintText: 'e.g. Broiler Starter')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: batchUnit,
                      decoration: const InputDecoration(labelText: 'Standard Batch Size'),
                      items: const [
                        DropdownMenuItem(value: 'per_tonne', child: Text('Per Tonne (1000 kg)')),
                        DropdownMenuItem(value: 'per_100kg', child: Text('Per 100 kg')),
                        DropdownMenuItem(value: 'per_50kg', child: Text('Per 50 kg')),
                        DropdownMenuItem(value: 'per_1kg', child: Text('Per 1 kg')),
                      ],
                      onChanged: (v) => setDialogState(() => batchUnit = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Recipe Notes', hintText: 'Optional')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Formula name is required'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    BlocProvider.of<InventoryBloc>(context).add(AddFeedFormula({
                      'name': nameCtrl.text.trim(),
                      'batch_size': batchSize.toString(),
                      'batch_unit': batchUnit,
                      'notes': notesCtrl.text.trim(),
                    }));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Formula created! Tap it to add ingredients.'), backgroundColor: AppColors.secondary),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // ADD INGREDIENT DIALOG (RECALCS PREVIEW)
  // ═══════════════════════════════════════════

  void _showAddIngredientDialog(BuildContext context, String formulaId, List<dynamic> feedItems) {
    if (feedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No feed items available. Register items first.')),
      );
      return;
    }

    String? selectedItemId;
    final percentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            // Safe loop-based lookup to avoid runtime list/map casting issues
            Map<dynamic, dynamic>? match;
            for (var item in feedItems) {
              if (item is Map && item['id']?.toString() == selectedItemId) {
                match = item;
                break;
              }
            }

            final double costKg = match != null 
                ? (double.tryParse((match['cost_per_kg'] ?? match['cost_per_unit'] ?? 0.0).toString()) ?? 0.0) 
                : 0.0;

            final double pctInput = double.tryParse(percentCtrl.text) ?? 0.0;

            // Live helpers
            final double weightPer1000 = 1000.0 * pctInput / 100.0;
            final double costPer1000 = weightPer1000 * costKg;

            return AlertDialog(
              title: const Text('Add Recipe Ingredient'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedItemId,
                      decoration: const InputDecoration(labelText: 'Feed Ingredient *'),
                      isExpanded: true,
                      items: feedItems.map<DropdownMenuItem<String>>((i) {
                        final id = i['id']?.toString() ?? '';
                        final name = i['name']?.toString() ?? 'Unnamed';
                        return DropdownMenuItem(value: id, child: Text(name));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedItemId = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: percentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Required Percentage (%) *',
                        hintText: 'e.g. 30 for 30% of recipe',
                      ),
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    
                    // Live formulation helpers
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Live Recipe Preview (Per Tonne):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Weight needed:', style: TextStyle(fontSize: 12)),
                              Text('${weightPer1000.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimated Cost:', style: TextStyle(fontSize: 12)),
                              Text(_currencyFmt.format(costPer1000), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (selectedItemId == null || percentCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    BlocProvider.of<InventoryBloc>(context).add(AddFormulaIngredient(formulaId, {
                      'feed_item_id': selectedItemId,
                      'percentage': percentCtrl.text.trim(),
                    }));
                    Navigator.of(ctx).pop(); // Close ingredient dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingredient added successfully!'), backgroundColor: AppColors.secondary),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // LOG ANIMAL FEEDING DIALOG
  // ═══════════════════════════════════════════

  void _showLogConsumptionDialog(BuildContext context) {
    if (_cachedFormulas == null || _cachedFormulas!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No feed formulas registered. Please create a feed formula first.')),
      );
      return;
    }

    final repo = sl<AnimalsRepository>();
    final inventoryRepo = sl<InventoryRepository>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        String? selectedAnimalId;
        String? selectedFormulaId;
        List<LocalFormulaIngredient>? selectedIngredients;
        final qtyCtrl = TextEditingController();
        final notesCtrl = TextEditingController();
        DateTime logDate = DateTime.now();

        double getCostPerKg(String feedItemId) {
          if (_cachedItems == null) return 0.0;
          Map<String, dynamic>? item;
          for (var i in _cachedItems!) {
            if (i is Map && i['id'] == feedItemId) {
              item = Map<String, dynamic>.from(i);
              break;
            }
          }
          if (item == null) return 0.0;
          final costPerUnit = double.tryParse(item['cost_per_unit']?.toString() ?? '0.0') ?? 0.0;
          final weightPerUnit = double.tryParse((item['weight_per_unit'] ?? 1.0).toString()) ?? 1.0;
          return double.tryParse((item['cost_per_kg'] ?? (costPerUnit / weightPerUnit)).toString()) ?? (costPerUnit / weightPerUnit);
        }

        return FutureBuilder<List<dynamic>>(
          future: repo.getAnimals(),
          builder: (futureCtx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final list = snapshot.data ?? [];
            final animals = <Map<String, dynamic>>[];
            for (var a in list) {
              final isMap = a is Map;
              final status = ((isMap ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
              if (status != 'dead') {
                animals.add({
                  'id': (isMap ? a['id'] : a.id)?.toString() ?? '',
                  'tag_number': (isMap ? a['tag_id'] : a.tagId)?.toString() ?? '',
                  'species': (isMap ? a['species'] : a.species)?.toString() ?? '',
                });
              }
            }

            if (animals.isEmpty) {
              return AlertDialog(
                title: const Text('Log Animal Feeding'),
                content: const Text('No active animals found. Please register active animals in the Farm Registry first.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('OK'),
                  ),
                ],
              );
            }

            return StatefulBuilder(
              builder: (ctx, setDialogState) {
                // Live calculation of cost and ingredients weight
                double totalCost = 0.0;
                final breakdownRows = <Widget>[];

                if (selectedIngredients != null && qtyCtrl.text.isNotEmpty) {
                  final totalQty = double.tryParse(qtyCtrl.text) ?? 0.0;
                  for (var ing in selectedIngredients!) {
                    final pct = ing.percentage;
                    final qtyIng = totalQty * (pct / 100.0);
                    final costPerKg = getCostPerKg(ing.feedItemId);
                    final costIng = qtyIng * costPerKg;
                    totalCost += costIng;

                    String itemName = 'Unknown';
                    if (_cachedItems != null) {
                      for (var i in _cachedItems!) {
                        if (i is Map && i['id'] == ing.feedItemId) {
                          itemName = i['name']?.toString() ?? 'Unknown';
                          break;
                        }
                      }
                    }

                    breakdownRows.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$itemName (${pct.toStringAsFixed(0)}%):', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('${qtyIng.toStringAsFixed(1)} kg | ₦ ${costIng.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }
                }

                return AlertDialog(
                  title: const Text('Log Animal Feeding'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedAnimalId,
                          decoration: const InputDecoration(labelText: 'Animal *'),
                          isExpanded: true,
                          items: animals.map<DropdownMenuItem<String>>((a) {
                            final tag = a['tag_number'] ?? '';
                            final species = a['species'] ?? '';
                            return DropdownMenuItem(value: a['id'] as String, child: Text('$tag ($species)'));
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedAnimalId = v),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedFormulaId,
                          decoration: const InputDecoration(labelText: 'Formulated Feed *'),
                          isExpanded: true,
                          items: _cachedFormulas!.map<DropdownMenuItem<String>>((f) {
                            return DropdownMenuItem(value: f.id, child: Text(f.name));
                          }).toList(),
                          onChanged: (v) {
                            setDialogState(() {
                              selectedFormulaId = v;
                              selectedIngredients = null;
                            });
                            if (v != null) {
                              inventoryRepo.getFormulaIngredients(v).then((ingredients) {
                                if (ctx.mounted) {
                                  setDialogState(() {
                                    selectedIngredients = ingredients;
                                  });
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Quantity Fed (kg) *', hintText: 'e.g. 10.0'),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Date'),
                          subtitle: Text(DateFormat('yyyy-MM-dd').format(logDate)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: logDate,
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setDialogState(() => logDate = picked);
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes', hintText: 'Optional')),
                        
                        if (breakdownRows.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Auto-Calculated Consumption Breakdown:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...breakdownRows,
                          const SizedBox(height: 8),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Quantity Fed:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(
                                '${(double.tryParse(qtyCtrl.text) ?? 0.0).toStringAsFixed(1)} kg',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Estimated Cost:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(
                                '₦ ${totalCost.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedAnimalId == null || selectedFormulaId == null || qtyCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                          );
                          return;
                        }
                        
                        final fName = _cachedFormulas!.firstWhere((f) => f.id == selectedFormulaId).name;
                        final finalNotes = 'Cost: ₦ ${totalCost.toStringAsFixed(0)}${notesCtrl.text.isNotEmpty ? " | Notes: ${notesCtrl.text.trim()}" : ""}';
                        
                        BlocProvider.of<InventoryBloc>(context).add(LogFeedConsumption({
                          'animal_id': selectedAnimalId,
                          'formula_id': selectedFormulaId,
                          'formula_name': fName,
                          'quantity_kg': qtyCtrl.text.trim(),
                          'log_date': logDate.toIso8601String(),
                          'notes': finalNotes,
                        }));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feeding logged & ingredients deducted!'), backgroundColor: AppColors.secondary),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Log Feeding'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class FeedingPlanTab extends StatefulWidget {
  final List<LocalFeedFormula> formulas;
  const FeedingPlanTab({Key? key, required this.formulas}) : super(key: key);

  @override
  State<FeedingPlanTab> createState() => _FeedingPlanTabState();
}

class _FeedingPlanTabState extends State<FeedingPlanTab> {
  bool _isAutoFeeding = false;

  double _getCalculatedFeed(String species, double weight) {
    final s = species.toLowerCase();
    if (s == 'bovine' || s == 'cow') {
      return weight * 0.025;
    } else if (s == 'caprine' || s == 'goat') {
      return weight * 0.035;
    } else if (s == 'ovine' || s == 'sheep') {
      return weight * 0.035;
    } else if (s == 'poultry' || s == 'chicken') {
      return weight * 0.10;
    }
    return weight * 0.03;
  }

  double _getDefaultWeight(String species) {
    final s = species.toLowerCase();
    if (s == 'bovine' || s == 'cow') return 400.0;
    if (s == 'caprine' || s == 'goat') return 45.0;
    if (s == 'ovine' || s == 'sheep') return 55.0;
    if (s == 'poultry' || s == 'chicken') return 2.0;
    return 50.0;
  }

  @override
  Widget build(BuildContext context) {
    final animalsRepo = sl<AnimalsRepository>();
    final inventoryRepo = sl<InventoryRepository>();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        animalsRepo.getAnimals(),
        inventoryRepo.getFeedingPlans(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final animalsList = snapshot.data?[0] as List<dynamic>? ?? [];
        final plans = snapshot.data?[1] as List<LocalFeedingPlan>? ?? [];

        // Filter active animals only (dead excluded)
        final activeAnimals = <Map<String, dynamic>>[];
        for (var a in animalsList) {
          final isMap = a is Map;
          final status = ((isMap ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
          if (status != 'dead') {
            activeAnimals.add({
              'id': (isMap ? a['id'] : a.id)?.toString() ?? '',
              'tag_id': (isMap ? a['tag_id'] : a.tagId)?.toString() ?? 'Unknown',
              'species': (isMap ? a['species'] : a.species)?.toString() ?? 'Other',
              'weight': double.tryParse((isMap ? a['weight'] : a.weight)?.toString() ?? '') ?? 0.0,
            });
          }
        }

        if (activeAnimals.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'No active animals found. Register active animals in the Farm Registry first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        // Calculate total feed statistics
        double totalDailyNeeded = 0.0;
        for (var plan in plans) {
          totalDailyNeeded += plan.quantityKg;
        }

        return Column(
          children: [
            // KPI Panel
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          const Text('Daily Feed Requirement', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text('${totalDailyNeeded.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          const Text('Weekly Projection', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text('${(totalDailyNeeded * 7).toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          const Text('Monthly Projection', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text('${(totalDailyNeeded * 30).toStringAsFixed(0)} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.tertiary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Daily Automation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAutoFeeding || plans.isEmpty
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final bloc = BlocProvider.of<InventoryBloc>(context);
                          setState(() => _isAutoFeeding = true);
                          int count = 0;
                          try {
                            for (var plan in plans) {
                              await inventoryRepo.logConsumption({
                                'animal_id': plan.animalId,
                                'formula_id': plan.formulaId,
                                'quantity_kg': plan.quantityKg.toString(),
                                'log_date': DateTime.now().toIso8601String().substring(0, 10),
                                'notes': 'Auto-logged from active Daily Feeding Plan',
                              });
                              count++;
                            }
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Successfully auto-logged feeding for $count animals!'),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                              bloc.add(LoadInventoryItems());
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Feeding auto-log failed: ${e.toString()}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isAutoFeeding = false);
                            }
                          }
                        },
                  icon: _isAutoFeeding
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.flash_on),
                  label: const Text('AUTO-LOG TODAY\'S FEEDING', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Animals Feed Assignment Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: activeAnimals.length,
                itemBuilder: (ctx, index) {
                  final animal = activeAnimals[index];
                  final animalId = animal['id'] as String;
                  final tag = animal['tag_id'] as String;
                  final species = animal['species'] as String;
                  final double actualWeight = animal['weight'] as double;
                  final double weight = actualWeight > 0 ? actualWeight : _getDefaultWeight(species);

                  LocalFeedingPlan? plan;
                  for (var p in plans) {
                    if (p.animalId == animalId) {
                      plan = p;
                      break;
                    }
                  }

                  final double calculatedQty = _getCalculatedFeed(species, weight);

                  return AnimalFeedPlanCard(
                    animalId: animalId,
                    tag: tag,
                    species: species,
                    weight: weight,
                    isWeightEstimated: actualWeight == 0,
                    calculatedQty: calculatedQty,
                    initialPlan: plan,
                    formulas: widget.formulas,
                    onSave: (formulaId, quantity) async {
                      final messenger = ScaffoldMessenger.of(context);
                      final newPlan = LocalFeedingPlan(
                        id: animalId,
                        animalId: animalId,
                        formulaId: formulaId,
                        quantityKg: quantity,
                        isAutoFeed: true,
                      );
                      await inventoryRepo.saveFeedingPlan(newPlan);
                      setState(() {});
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Feeding plan saved!'), backgroundColor: AppColors.secondary),
                        );
                      }
                    },
                    onDelete: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await inventoryRepo.deleteFeedingPlan(animalId);
                      setState(() {});
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Feeding plan cleared.'), backgroundColor: AppColors.warning),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class AnimalFeedPlanCard extends StatefulWidget {
  final String animalId;
  final String tag;
  final String species;
  final double weight;
  final bool isWeightEstimated;
  final double calculatedQty;
  final LocalFeedingPlan? initialPlan;
  final List<LocalFeedFormula> formulas;
  final Function(String formulaId, double quantity) onSave;
  final VoidCallback onDelete;

  const AnimalFeedPlanCard({
    Key? key,
    required this.animalId,
    required this.tag,
    required this.species,
    required this.weight,
    required this.isWeightEstimated,
    required this.calculatedQty,
    required this.initialPlan,
    required this.formulas,
    required this.onSave,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<AnimalFeedPlanCard> createState() => _AnimalFeedPlanCardState();
}

class _AnimalFeedPlanCardState extends State<AnimalFeedPlanCard> {
  String? _selectedFormulaId;
  final _qtyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _qtyCtrl.text = widget.initialPlan != null
        ? widget.initialPlan!.quantityKg.toStringAsFixed(1)
        : widget.calculatedQty.toStringAsFixed(1);
    _selectedFormulaId = widget.initialPlan?.formulaId ?? (widget.formulas.isNotEmpty ? widget.formulas.first.id : null);
  }

  @override
  void didUpdateWidget(covariant AnimalFeedPlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPlan != oldWidget.initialPlan) {
      _qtyCtrl.text = widget.initialPlan != null
          ? widget.initialPlan!.quantityKg.toStringAsFixed(1)
          : widget.calculatedQty.toStringAsFixed(1);
      _selectedFormulaId = widget.initialPlan?.formulaId ?? (widget.formulas.isNotEmpty ? widget.formulas.first.id : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBovine = widget.species.toLowerCase() == 'bovine' || widget.species.toLowerCase() == 'cow';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isBovine ? Icons.agriculture : Icons.grass,
                  color: widget.initialPlan != null ? AppColors.secondary : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animal Tag: ${widget.tag}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${widget.species.toUpperCase()} • ${widget.weight.toStringAsFixed(0)} kg${widget.isWeightEstimated ? " (Default)" : ""}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (widget.initialPlan != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFormulaId,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Feed',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    items: widget.formulas.map((f) {
                      return DropdownMenuItem(value: f.id, child: Text(f.name, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedFormulaId = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(textCapitalization: TextCapitalization.sentences, controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Qty (kg)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                        onPressed: () {
                          setState(() {
                            _qtyCtrl.text = widget.calculatedQty.toStringAsFixed(1);
                          });
                        },
                        tooltip: 'Reset to weight-based formula value',
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sci Requirement: ${widget.calculatedQty.toStringAsFixed(1)} kg/day',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontStyle: FontStyle.italic),
                ),
                Row(
                  children: [
                    if (widget.initialPlan != null)
                      TextButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, size: 14),
                        label: const Text('Clear', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_selectedFormulaId == null || _qtyCtrl.text.isEmpty) return;
                        final qty = double.tryParse(_qtyCtrl.text) ?? widget.calculatedQty;
                        widget.onSave(_selectedFormulaId!, qty);
                      },
                      icon: const Icon(Icons.save, size: 14),
                      label: Text(widget.initialPlan != null ? 'Update' : 'Save', style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
  }
}

class OperationsPOSTab extends StatefulWidget {
  final List<LocalFeedFormula> formulas;
  final List<dynamic> items;
  const OperationsPOSTab({Key? key, required this.formulas, required this.items}) : super(key: key);

  @override
  State<OperationsPOSTab> createState() => _OperationsPOSTabState();
}

class _OperationsPOSTabState extends State<OperationsPOSTab> {
  @override
  Widget build(BuildContext context) {
    final inventoryRepo = sl<InventoryRepository>();

    return FutureBuilder<List<LocalFeedingPlan>>(
      future: inventoryRepo.getFeedingPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final plans = snapshot.data ?? [];

        final consumptionRates = <String, double>{};
        for (var p in plans) {
          consumptionRates[p.formulaId] = (consumptionRates[p.formulaId] ?? 0.0) + p.quantityKg;
        }

        final lowItems = widget.items.where((i) {
          final stock = double.tryParse(i['current_stock']?.toString() ?? '0.0') ?? 0.0;
          final threshold = double.tryParse(i['reorder_threshold']?.toString() ?? '0.0') ?? 0.0;
          return stock <= threshold;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showFormulateBatchDialog(context),
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  label: const Text('FORMULATE & PREPARE FEED BATCH', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (lowItems.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'LOW STOCK ALERTS (Ingredients)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...lowItems.map((i) {
                  final stock = double.tryParse(i['current_stock']?.toString() ?? '0.0') ?? 0.0;
                  final thresh = double.tryParse(i['reorder_threshold']?.toString() ?? '0.0') ?? 0.0;
                  final def = thresh - stock;
                  return Card(
                    color: AppColors.errorContainer.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.error, width: 0.5)),
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.warning_amber, color: AppColors.error),
                      title: Text(i['name']?.toString() ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Current: ${stock.toStringAsFixed(1)} ${i['unit']} | Reorder Threshold: ${thresh.toStringAsFixed(1)} ${i['unit']} (Deficit: ${def.toStringAsFixed(1)} ${i['unit']})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: i['supplier'] != null && i['supplier'].toString().isNotEmpty
                          ? Chip(
                              label: Text(
                                i['supplier'].toString(),
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                              ),
                              backgroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            )
                          : null,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],

              const Text(
                'FORMULATED FEED STOCK LEVELS',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (widget.formulas.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No feed formulas found. Add feed formulas under the Feed Formulas tab first.'),
                  ),
                )
              else
                ...widget.formulas.map((f) {
                  final stock = f.currentStock;
                  final rate = consumptionRates[f.id] ?? 0.0;
                  final daysLeft = rate > 0 ? stock / rate : -1.0;

                  Color statusColor = AppColors.primary;
                  String projectionText = 'No active consumption';
                  if (rate > 0) {
                    if (daysLeft < 2.0) {
                      statusColor = AppColors.error;
                      projectionText = 'Runs out in ${daysLeft.toStringAsFixed(1)} days (CRITICAL)';
                    } else if (daysLeft < 5.0) {
                      statusColor = AppColors.warning;
                      projectionText = 'Runs out in ${daysLeft.toStringAsFixed(1)} days';
                    } else {
                      statusColor = AppColors.secondary;
                      projectionText = 'Runs out in ${daysLeft.toStringAsFixed(1)} days';
                    }
                  }

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Stock: ${stock.toStringAsFixed(1)} kg',
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daily Consumption: ${rate.toStringAsFixed(1)} kg/day',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              Text(
                                projectionText,
                                style: TextStyle(
                                  color: rate > 0 ? statusColor : Colors.grey,
                                  fontWeight: rate > 0 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (rate > 0) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (daysLeft / 14.0).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showFormulateBatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        String? selectedFormulaId;
        final qtyCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Prepare Formulated Feed'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedFormulaId,
                    decoration: const InputDecoration(labelText: 'Feed Formula *'),
                    isExpanded: true,
                    items: widget.formulas.map((f) {
                      return DropdownMenuItem(value: f.id, child: Text(f.name));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedFormulaId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(textCapitalization: TextCapitalization.sentences, controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Batch Size to Formulate (kg) *',
                      hintText: 'e.g. 100',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedFormulaId == null || qtyCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid positive quantity'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    BlocProvider.of<InventoryBloc>(context).add(PrepareFormulaBatch(selectedFormulaId!, qty));
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feed batch formulation processing...'), backgroundColor: AppColors.primary),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                  child: const Text('Formulate Batch'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
