import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import '../inventory/inventory_repository.dart';
import '../finance/finance_repository.dart';
import 'package:ifms_mobile/core/widgets/custom_charts.dart';
import 'poultry_bloc.dart';
import 'poultry_repository.dart';
import '../pharmacy/pharmacy_repository.dart';

class PoultryScreen extends StatefulWidget {
  const PoultryScreen({super.key});

  @override
  State<PoultryScreen> createState() => _PoultryScreenState();
}

class _PoultryScreenState extends State<PoultryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POULTRY BATCHES CONTROL'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ACTIVE BATCHES'),
            Tab(text: 'CLOSED ARCHIVE'),
          ],
        ),
      ),
      body: BlocBuilder<PoultryBloc, PoultryState>(
        builder: (context, state) {
          if (state is PoultryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PoultryLoaded) {
            final activeBatches = state.batches.where((b) => b.status == 'active').toList();
            final closedBatches = state.batches.where((b) => b.status == 'closed').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildBatchList(context, activeBatches, true),
                _buildBatchList(context, closedBatches, false),
              ],
            );
          }
          return const Center(child: Text('Error loading poultry data.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartBatchDialog(context),
        label: const Text('Start New Batch'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBatchList(BuildContext context, List<LocalPoultryBatche> batches, bool isActive) {
    if (batches.isEmpty) {
      return Center(
        child: Text(
          isActive ? 'No active broiler flocks.' : 'No archived flocks.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: batches.length,
      itemBuilder: (ctx, idx) {
        final batch = batches[idx];
        final ageDays = DateTime.now().difference(batch.startDate).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PoultryDetailScreen(batch: batch),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
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
                          'FLOCK BATCH #${batch.batchNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              batch.status.toUpperCase(),
                              style: TextStyle(
                                color: isActive ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showEditBatchDialog(context, batch),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _confirmDeleteBatch(context, batch),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'House/Pen Location: ${batch.houseName}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _smallStat('Count', '${batch.currentCount} / ${batch.initialCount} Birds'),
                      _smallStat('Age', '$ageDays Days'),
                      _smallStat('Start Date', DateFormat('yyyy-MM-dd').format(batch.startDate)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _smallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _showStartBatchDialog(BuildContext context) {
    final numberCtrl = TextEditingController();
    final houseCtrl = TextEditingController();
    final countCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final breedCtrl = TextEditingController(text: 'Cobb 500');
    final ageCtrl = TextEditingController(text: 'Day-Old');
    final supplierCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    String selectedType = 'broiler';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Start Flock Batch'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Poultry Type *'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'broiler', child: Text('Broilers')),
                        DropdownMenuItem(value: 'layer', child: Text('Layers')),
                        DropdownMenuItem(value: 'cockerel', child: Text('Cockerels')),
                        DropdownMenuItem(value: 'noiler', child: Text('Noilers')),
                        DropdownMenuItem(value: 'turkey', child: Text('Turkeys')),
                        DropdownMenuItem(value: 'duck', child: Text('Ducks')),
                      ],
                      onChanged: (v) => setStateDialog(() => selectedType = v!),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: numberCtrl,
                      decoration: const InputDecoration(labelText: 'Batch Number/ID *', hintText: 'e.g. 104'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: houseCtrl,
                      decoration: const InputDecoration(labelText: 'House/Pen Name *', hintText: 'e.g. Brooder Pen 2'),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: countCtrl,
                      decoration: const InputDecoration(labelText: 'Initial Count *', hintText: 'e.g. 500'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: costCtrl,
                      decoration: const InputDecoration(labelText: 'Chick Price per Bird (₦) *', hintText: 'e.g. 450'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: breedCtrl,
                      decoration: const InputDecoration(labelText: 'Breed', hintText: 'e.g. Cobb 500'),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: ageCtrl,
                      decoration: const InputDecoration(labelText: 'Age upon Stocking', hintText: 'e.g. Day-Old or 2 weeks'),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: supplierCtrl,
                      decoration: const InputDecoration(labelText: 'Supplier / Source', hintText: 'e.g. Zartech Farms'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 90)),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setStateDialog(() => startDate = picked);
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (numberCtrl.text.isEmpty || houseCtrl.text.isEmpty || countCtrl.text.isEmpty || costCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    final count = int.tryParse(countCtrl.text) ?? 0;
                    final price = double.tryParse(costCtrl.text) ?? 0.0;
                    final totalChickCost = count * price;

                    // Combine breed + age + source metadata for clean storage
                    final combinedBreed = '${breedCtrl.text.trim()} (${ageCtrl.text.trim()}, Source: ${supplierCtrl.text.trim().isEmpty ? "Unknown" : supplierCtrl.text.trim()})';

                    BlocProvider.of<PoultryBloc>(context).add(CreateBatch({
                      'batch_number': numberCtrl.text.trim(),
                      'house_name': houseCtrl.text.trim(),
                      'initial_count': count,
                      'initial_chick_cost': totalChickCost,
                      'breed': combinedBreed,
                      'batch_type': selectedType,
                      'start_date': startDate.toIso8601String().substring(0, 10),
                    }));
                    Navigator.pop(dialogCtx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Start Batch'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBatchDialog(BuildContext context, LocalPoultryBatche batch) {
    String breedVal = 'Cobb 500';
    String ageVal = 'Day-Old';
    String supplierVal = '';

    final numberCtrl = TextEditingController(text: batch.batchNumber);
    final houseCtrl = TextEditingController(text: batch.houseName);
    final countCtrl = TextEditingController(text: batch.initialCount.toString());
    final currentCtrl = TextEditingController(text: batch.currentCount.toString());
    final breedCtrl = TextEditingController(text: breedVal);
    final ageCtrl = TextEditingController(text: ageVal);
    final supplierCtrl = TextEditingController(text: supplierVal);
    DateTime startDate = batch.startDate;
    String selectedStatus = batch.status;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Flock Batch'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Flock Status *'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'closed', child: Text('Closed')),
                      ],
                      onChanged: (v) => setStateDialog(() => selectedStatus = v!),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: numberCtrl,
                      decoration: const InputDecoration(labelText: 'Batch Number/ID *'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: houseCtrl,
                      decoration: const InputDecoration(labelText: 'House/Pen Name *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: countCtrl,
                      decoration: const InputDecoration(labelText: 'Initial Count *'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: currentCtrl,
                      decoration: const InputDecoration(labelText: 'Current Count *'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: breedCtrl,
                      decoration: const InputDecoration(labelText: 'Breed'),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: ageCtrl,
                      decoration: const InputDecoration(labelText: 'Age upon Stocking'),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: supplierCtrl,
                      decoration: const InputDecoration(labelText: 'Supplier / Source'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setStateDialog(() => startDate = picked);
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (numberCtrl.text.isEmpty || houseCtrl.text.isEmpty || countCtrl.text.isEmpty || currentCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    final count = int.tryParse(countCtrl.text) ?? 0;
                    final current = int.tryParse(currentCtrl.text) ?? 0;
                    final combinedBreed = '${breedCtrl.text.trim()} (${ageCtrl.text.trim()}, Source: ${supplierCtrl.text.trim().isEmpty ? "Unknown" : supplierCtrl.text.trim()})';

                    BlocProvider.of<PoultryBloc>(context).add(UpdateBatch(batch.id, {
                      'batch_number': numberCtrl.text.trim(),
                      'house_name': houseCtrl.text.trim(),
                      'initial_count': count,
                      'current_count': current,
                      'breed': combinedBreed,
                      'start_date': startDate.toIso8601String().substring(0, 10),
                      'status': selectedStatus,
                      'initial_chick_cost': 0.0,
                    }));
                    Navigator.pop(dialogCtx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteBatch(BuildContext context, LocalPoultryBatche batch) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Delete Flock Batch'),
          content: Text('Are you sure you want to delete Flock Batch #${batch.batchNumber} located at ${batch.houseName}? All daily logs, mortality records, and sale logs associated with this batch will be permanently removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<PoultryBloc>(context).add(DeleteBatch(batch.id));
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class PoultryDetailScreen extends StatefulWidget {
  final LocalPoultryBatche batch;
  const PoultryDetailScreen({super.key, required this.batch});

  @override
  State<PoultryDetailScreen> createState() => _PoultryDetailScreenState();
}

class _PoultryDetailScreenState extends State<PoultryDetailScreen> {
  final _currencyFmt = NumberFormat.currency(symbol: '₦ ', decimalDigits: 2);
  late LocalPoultryBatche _currentBatch;
  late Future<Map<String, dynamic>> _kpiFuture;
  late Future<List<Map<String, dynamic>>> _timelineFuture;

  @override
  void initState() {
    super.initState();
    _currentBatch = widget.batch;
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _kpiFuture = sl<PoultryRepository>().getBatchKpi(_currentBatch.id);
      _timelineFuture = Future.wait([
        (sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localPoultryLogs)
              ..where((t) => t.batchId.equals(_currentBatch.id))
              ..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)]))
            .get(),
        (sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localAnimalMedicalRecords)
              ..where((t) => t.animalId.equals(_currentBatch.id))
              ..orderBy([(t) => OrderingTerm(expression: t.treatmentDate, mode: OrderingMode.desc)]))
            .get(),
        sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localMedications).get(),
      ]).then((results) {
        final logs = results[0] as List<LocalPoultryLog>;
        final meds = results[1] as List<LocalAnimalMedicalRecord>;
        final catalog = results[2] as List<LocalMedication>;
        
        final medMap = {for (var m in catalog) m.id: m};

        final merged = <Map<String, dynamic>>[];
        for (var l in logs) {
          merged.add({
            'type': 'poultry_log',
            'id': l.id,
            'date': l.logDate,
            'feed_bags': l.feedBags,
            'mortality': l.mortality,
            'average_weight': l.averageWeight,
            'raw_log': l,
          });
        }
        for (var m in meds) {
          final medName = medMap[m.medicationId]?.name ?? 'Unknown Medication';
          final medUnit = medMap[m.medicationId]?.unit ?? 'units';
          merged.add({
            'type': 'medication',
            'id': m.id,
            'date': m.treatmentDate,
            'medication_name': medName,
            'dose': m.administeredDose,
            'unit': medUnit,
            'condition': m.diagnosedCondition,
            'cost': m.cost,
            'raw_med': m,
          });
        }
        merged.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        return merged;
      });

      // Refresh the current batch to get updated live count and status
      sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localPoultryBatches)
        ..where((t) => t.id.equals(_currentBatch.id))
        ..getSingle().then((updatedBatch) {
          if (mounted) setState(() => _currentBatch = updatedBatch);
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ageDays = DateTime.now().difference(_currentBatch.startDate).inDays;
    final isActive = _currentBatch.status == 'active';

    return BlocListener<PoultryBloc, PoultryState>(
      listener: (context, state) {
        if (state is PoultryLoaded) {
          final match = state.batches.firstWhere((b) => b.id == _currentBatch.id, orElse: () => _currentBatch);
          setState(() {
            _currentBatch = match;
          });
          _refreshData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('FLOCK BATCH #${_currentBatch.batchNumber}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            )
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _kpiFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final kpis = snapshot.data!;
            final bool outbreakRisk = kpis['alerts']?['disease_outbreak_risk'] ?? false;
            final bool poorFcr = kpis['alerts']?['poor_fcr_alert'] ?? false;
            final bool highMortality = kpis['alerts']?['high_mortality_alert'] ?? false;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert Banners
                  if (outbreakRisk)
                    _buildAlertBanner('DISEASE OUTBREAK RISK DETECTED!', 'Flock mortality is rising rapidly (>2% in 48 hours). Administer vet diagnosis immediately!', AppColors.error)
                  else if (highMortality)
                    _buildAlertBanner('HIGH MORTALITY DETECTED!', 'Cumulative mortality has exceeded 5%. Audit temperature, ventilation, and water supplies.', Colors.orange)
                  else if (poorFcr)
                    _buildAlertBanner('POOR FEED CONVERSION RATIO!', 'FCR exceeds 2.2. Audit feeding recipes, check for feed waste, or audit bird weights.', Colors.orange),

                  const Text('PRODUCTION KPIs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildKpiGrid(kpis, ageDays),
                  const SizedBox(height: 16),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _timelineFuture,
                    builder: (context, timelineSnapshot) {
                      if (timelineSnapshot.hasData) {
                        return _buildPerformanceCharts(timelineSnapshot.data!);
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 24),

                  if (isActive) ...[

                    const Text('QUICK PERFORMANCE LOGGING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildQuickLogPanel(context),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showSaleDialog(context, kpis),
                        icon: const Icon(Icons.point_of_sale),
                        label: const Text('Log Sales / Harvest'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text('FLOCK LOG TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildTimelineList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertBanner(String title, String message, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKpiGrid(Map<String, dynamic> kpis, int ageDays) {
    final double fcr = double.parse((kpis['feed_conversion_ratio'] ?? 0.0).toString());
    final double mortalityRate = double.parse((kpis['mortality_rate_percent'] ?? 0.0).toString());
    final double avgWeight = double.parse((kpis['average_weight_kg'] ?? 0.04).toString());
    final double totalFeed = double.parse((kpis['total_feed_consumed_kg'] ?? 0.0).toString());
    final double costs = double.parse((kpis['total_costs'] ?? 0.0).toString());
    final double revenue = double.parse((kpis['revenue'] ?? 0.0).toString());
    final double profit = double.parse((kpis['net_profit'] ?? 0.0).toString());

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: [
        _kpiTile('Live Count', '${_currentBatch.currentCount} Birds', 'Initial: ${_currentBatch.initialCount}', Icons.flutter_dash, AppColors.primary),
        _kpiTile('Flock Age', '$ageDays Days', 'Started: ${DateFormat('MM-dd').format(_currentBatch.startDate)}', Icons.hourglass_empty, Colors.blue),
        _kpiTile('FCR', fcr.toStringAsFixed(2), fcr <= 1.8 ? 'Excellent' : fcr > 2.2 ? 'Poor Feed Convert' : 'Normal', Icons.feed, fcr > 2.2 ? AppColors.error : AppColors.secondary),
        _kpiTile('Mortality', '${mortalityRate.toStringAsFixed(1)}%', 'Deaths: ${widget.batch.initialCount - widget.batch.currentCount}', Icons.sentiment_very_dissatisfied, mortalityRate > 5.0 ? AppColors.error : Colors.green),
        _kpiTile('Avg Weight', '${avgWeight.toStringAsFixed(3)} kg', 'Sample Weight', Icons.scale, Colors.purple),
        _kpiTile('Total Feed', '${totalFeed.toStringAsFixed(0)} kg', 'Depleted from stock', Icons.warehouse, Colors.teal),
        _kpiTile('Outlay Cost', _currencyFmt.format(costs), 'Chicks + Feed + Meds', Icons.payments, Colors.red),
        _kpiTile('Net Revenue', _currencyFmt.format(revenue), 'Net Profit: ${_currencyFmt.format(profit)}', Icons.monetization_on, profit >= 0 ? Colors.green : AppColors.error),
      ],
    );
  }

  Widget _kpiTile(String label, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildQuickLogPanel(BuildContext context) {
    return Row(
      children: [
        _quickButton(context, Icons.lunch_dining_outlined, 'Log Feed', () => _showLogFeedDialog(context)),
        const SizedBox(width: 6),
        _quickButton(context, Icons.remove_circle_outline, 'Log Death', () => _showLogMortalityDialog(context)),
        const SizedBox(width: 6),
        _quickButton(context, Icons.monitor_weight_outlined, 'Log Weight', () => _showLogWeightDialog(context)),
        const SizedBox(width: 6),
        _quickButton(context, Icons.medical_services_outlined, 'Medicate', () => _showLogMedicationDialog(context)),
      ],
    );
  }

  Widget _quickButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _timelineFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No events or daily logs recorded.', style: TextStyle(color: Colors.grey))),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (ctx, idx) {
            final item = items[idx];
            final type = item['type'].toString();
            final date = item['date'] as DateTime;

            Widget leadingIcon = const Icon(Icons.assignment, color: AppColors.primary, size: 18);
            String title = '';

            if (type == 'poultry_log') {
              final parts = <String>[];
              final feedBags = item['feed_bags'] as int? ?? 0;
              final mortality = item['mortality'] as int? ?? 0;
              final averageWeight = item['average_weight'] as double?;

              if (feedBags > 0) parts.add('$feedBags Feed Bag(s)');
              if (mortality > 0) parts.add('$mortality Bird(s) Dead');
              if (averageWeight != null) parts.add('Avg Weight: ${averageWeight.toStringAsFixed(3)} kg');
              
              title = parts.isNotEmpty ? parts.join(' | ') : 'Manual Update';
            } else if (type == 'medication') {
              leadingIcon = const Icon(Icons.medical_services_outlined, color: Colors.red, size: 18);
              final medName = item['medication_name'].toString();
              final dose = double.parse(item['dose'].toString());
              final unit = item['unit'].toString();
              final cond = item['condition'].toString();
              final cost = double.parse(item['cost'].toString());
              
              title = 'Med: $medName ($dose $unit) for $cond | Cost: ${_currencyFmt.format(cost)}';
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: (type == 'medication' ? Colors.red : AppColors.primary).withValues(alpha: 0.1),
                  child: leadingIcon,
                ),
                title: Text(title),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(date)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                      onPressed: () => _showEditTimelineDialog(context, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: () => _confirmDeleteTimeline(context, item),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTimelineDialog(BuildContext context, Map<String, dynamic> item) async {
    try {
      if (item['type'] == 'poultry_log') {
        final rawLog = item['raw_log'];
        LocalPoultryLog? log;
        if (rawLog is LocalPoultryLog) {
          log = rawLog;
        } else {
          final logId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
          log = await (sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localPoultryLogs)
                ..where((t) => t.id.equals(logId)))
              .getSingleOrNull();
        }
        if (log == null) throw Exception('Log entry not found in database.');

        final feedCtrl = TextEditingController(text: log.feedBags.toString());
        final mortCtrl = TextEditingController(text: log.mortality.toString());
        final weightCtrl = TextEditingController(text: log.averageWeight?.toString() ?? '');

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: const Text('Edit Daily Log'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(textCapitalization: TextCapitalization.sentences, controller: feedCtrl,
                  decoration: const InputDecoration(labelText: 'Feed Bags Consumed'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(textCapitalization: TextCapitalization.sentences, controller: mortCtrl,
                  decoration: const InputDecoration(labelText: 'Mortality (Bird Deaths)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(textCapitalization: TextCapitalization.sentences, controller: weightCtrl,
                  decoration: const InputDecoration(labelText: 'Average Weight (kg)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final feed = int.tryParse(feedCtrl.text) ?? 0;
                    final mort = int.tryParse(mortCtrl.text) ?? 0;
                    final weight = double.tryParse(weightCtrl.text);
                    final dialogNav = Navigator.of(dialogCtx);

                    await sl<PoultryRepository>().updatePoultryLog(
                      log!,
                      feedBags: feed,
                      mortality: mort,
                      averageWeight: weight,
                    );

                    dialogNav.pop();
                    if (context.mounted) {
                      BlocProvider.of<PoultryBloc>(context).add(LoadPoultryData());
                    }
                    _refreshData();
                  } catch (err) {
                    debugPrint('Error updating log: $err');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        );
      }
      } else if (item['type'] == 'medication') {
        final rawMed = item['raw_med'];
        LocalAnimalMedicalRecord? med;
        if (rawMed is LocalAnimalMedicalRecord) {
          med = rawMed;
        } else {
          final medId = item['id']?.toString() ?? '';
          med = await (sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localAnimalMedicalRecords)
                ..where((t) => t.id.equals(medId)))
              .getSingleOrNull();
        }
        if (med == null) throw Exception('Medical record not found in database.');

        final doseCtrl = TextEditingController(text: med.administeredDose.toString());
        final condCtrl = TextEditingController(text: med.diagnosedCondition);
        final costCtrl = TextEditingController(text: med.cost.toString());

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: const Text('Edit Medication Treatment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(textCapitalization: TextCapitalization.sentences, controller: condCtrl,
                    decoration: const InputDecoration(labelText: 'Diagnosed Condition'),
                  ),
                  const SizedBox(height: 8),
                  TextField(textCapitalization: TextCapitalization.sentences, controller: doseCtrl,
                    decoration: const InputDecoration(labelText: 'Administered Dose'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 8),
                  TextField(textCapitalization: TextCapitalization.sentences, controller: costCtrl,
                    decoration: const InputDecoration(labelText: 'Treatment Cost (₦)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final dose = double.tryParse(doseCtrl.text) ?? med!.administeredDose;
                      final cond = condCtrl.text;
                      final cost = double.tryParse(costCtrl.text) ?? med!.cost;
                      final dialogNav = Navigator.of(dialogCtx);

                      await sl<PoultryRepository>().updateMedicalRecord(
                        med!,
                        dose: dose,
                        condition: cond,
                        cost: cost,
                      );

                      dialogNav.pop();
                      if (context.mounted) {
                        BlocProvider.of<PoultryBloc>(context).add(LoadPoultryData());
                      }
                      _refreshData();
                    } catch (err) {
                      debugPrint('Error updating medical log: $err');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e, stack) {
      debugPrint('Error showing edit dialog: $e\n$stack');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open edit dialog: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDeleteTimeline(BuildContext context, Map<String, dynamic> item) {
    try {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Delete Log Entry'),
          content: const Text('Are you sure you want to permanently delete this timeline log? This action will adjust flock metrics accordingly.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final dialogNav = Navigator.of(dialogCtx);
                  if (item['type'] == 'poultry_log') {
                    final rawLog = item['raw_log'];
                    LocalPoultryLog? log;
                    if (rawLog is LocalPoultryLog) {
                      log = rawLog;
                    } else {
                      final logId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
                      log = await (sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localPoultryLogs)
                            ..where((t) => t.id.equals(logId)))
                          .getSingleOrNull();
                    }
                    if (log == null) throw Exception('Log entry not found in database.');
                    await sl<PoultryRepository>().deletePoultryLog(log);
                  } else if (item['type'] == 'medication') {
                    final medId = item['id'].toString();
                    await sl<PoultryRepository>().deleteMedicalRecord(medId);
                  }
                  dialogNav.pop();
                  
                  if (context.mounted) {
                    BlocProvider.of<PoultryBloc>(context).add(LoadPoultryData());
                  }
                  _refreshData();
                } catch (err) {
                  debugPrint('Error deleting log: $err');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } catch (e, stack) {
      debugPrint('Error showing delete dialog: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open delete dialog: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showLogFeedDialog(BuildContext context) {
    final invRepo = sl<InventoryRepository>();
    final kgCtrl = TextEditingController(text: '25'); // Default 25kg bag equivalent
    final poultryBloc = BlocProvider.of<PoultryBloc>(context);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return FutureBuilder<List<LocalFeedFormula>>(
          future: invRepo.getFormulas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final formulas = snapshot.data!;
            if (formulas.isEmpty) {
              return AlertDialog(
                title: const Text('No Formulated Feed Available'),
                content: const Text('Please prepare formulated feed batches in the FIS before logging consumption.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Close')),
                ],
              );
            }

            String selectedFormulaId = formulas.first.id;

            return StatefulBuilder(
              builder: (ctx, setStateDialog) {
                final matchFormula = formulas.firstWhere((f) => f.id == selectedFormulaId);
                final double currentStock = matchFormula.currentStock;

                return AlertDialog(
                  title: const Text('Log Formulated Feed'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedFormulaId,
                        decoration: const InputDecoration(labelText: 'Select Formulated Feed'),
                        isExpanded: true,
                        items: formulas.map((f) {
                          return DropdownMenuItem(value: f.id, child: Text(f.name));
                        }).toList(),
                        onChanged: (v) => setStateDialog(() => selectedFormulaId = v!),
                      ),
                      const SizedBox(height: 8),
                      Text('Current Prepared Stock: ${currentStock.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: kgCtrl,
                        decoration: const InputDecoration(labelText: 'Quantity Consumed (kg) *'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        final kg = double.tryParse(kgCtrl.text) ?? 0.0;
                        if (kg <= 0) return;

                        if (kg > currentStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Insufficient stock. Only ${currentStock.toStringAsFixed(1)} kg available.'), backgroundColor: AppColors.error),
                          );
                          return;
                        }

                        final dialogNav = Navigator.of(dialogCtx);

                        // 1. Calculate cost per kg dynamically from ingredients
                        final costs = await invRepo.calculateFormulaCost(selectedFormulaId, 1.0);
                        double costPerKg = 0.0;
                        for (var c in costs) {
                          costPerKg += (c['line_cost'] as double);
                        }

                        // 2. Deduct formulated stock via logConsumption
                        await invRepo.logConsumption({
                          'animal_id': _currentBatch.id,
                          'formula_id': selectedFormulaId,
                          'quantity_kg': kg,
                          'log_date': DateTime.now().toIso8601String(),
                          'change_type': 'consumption',
                          'quantity_change': (kg / 25.0).toDouble(),
                          'related_entity_type': 'poultry_batch',
                          'related_entity_id': _currentBatch.id,
                          'notes': 'Consumed on flock batch #${_currentBatch.batchNumber}',
                        });

                        // 3. Add feed event to poultry batch logs
                        poultryBloc.add(LogBatchEvent(_currentBatch.id, {
                          'event_type': 'feed',
                          'quantity': kg,
                          'value_json': {
                            'feed_bags': (kg / 25.0).ceil(), // Estimate bags
                            'price_per_kg': costPerKg,
                          }
                        }));

                        dialogNav.pop();
                        _refreshData();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Log Consumption'),
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

  void _showLogMedicationDialog(BuildContext context) {
    final pharmRepo = sl<PharmacyRepository>();
    final poultryBloc = BlocProvider.of<PoultryBloc>(context);

    final doseCtrl = TextEditingController();
    final diagnosisCtrl = TextEditingController(text: 'Routine prophylaxis');
    final adminByCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return FutureBuilder<List<LocalMedication>>(
          future: pharmRepo.getMedications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final medications = snapshot.data!.where((m) => m.isActive).toList();
            if (medications.isEmpty) {
              return AlertDialog(
                title: const Text('No Medication Available'),
                content: const Text('Please add medications/vaccines to the Pharmacy catalog before logging treatment.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Close')),
                ],
              );
            }

            String selectedMedId = medications.first.id;

            return StatefulBuilder(
              builder: (ctx, setStateDialog) {
                final matchMed = medications.firstWhere((m) => m.id == selectedMedId);
                final double currentStock = matchMed.currentStock;

                return AlertDialog(
                  title: const Text('Log Flock Medication'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedMedId,
                          decoration: const InputDecoration(labelText: 'Select Medication / Vaccine *'),
                          isExpanded: true,
                          items: medications.map((m) {
                            return DropdownMenuItem(value: m.id, child: Text(m.name));
                          }).toList(),
                          onChanged: (v) => setStateDialog(() => selectedMedId = v!),
                        ),
                        const SizedBox(height: 8),
                        Text('Current Pharmacy Stock: ${currentStock.toStringAsFixed(1)} ${matchMed.unit}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: doseCtrl,
                          decoration: InputDecoration(labelText: 'Administered Dose (${matchMed.unit}) *'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: diagnosisCtrl,
                          decoration: const InputDecoration(labelText: 'Reason / Condition *'),
                        ),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: adminByCtrl,
                          decoration: const InputDecoration(labelText: 'Administered By (Optional)'),
                        ),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl,
                          decoration: const InputDecoration(labelText: 'Notes / Remarks (Optional)'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        final dose = double.tryParse(doseCtrl.text) ?? 0.0;
                        if (dose <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid dose quantity.'), backgroundColor: AppColors.error),
                          );
                          return;
                        }
                        if (diagnosisCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a diagnosis reason / condition.'), backgroundColor: AppColors.error),
                          );
                          return;
                        }

                        if (dose > currentStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Insufficient stock. Only $currentStock ${matchMed.unit} available.'), backgroundColor: AppColors.error),
                          );
                          return;
                        }

                        final dialogNav = Navigator.of(dialogCtx);

                        // 1. Log Treatment in Pharmacy Repository (this auto deducts stock & logs medication logs!)
                        await pharmRepo.logAnimalTreatment({
                          'animal_id': _currentBatch.id,
                          'medication_id': selectedMedId,
                          'administered_dose': dose,
                          'treatment_date': DateTime.now().toIso8601String(),
                          'diagnosed_condition': diagnosisCtrl.text.trim(),
                          'administered_by': adminByCtrl.text.trim().isEmpty ? null : adminByCtrl.text.trim(),
                          'notes': notesCtrl.text.trim().isEmpty ? 'Flock treatment Newcastle/routine' : notesCtrl.text.trim(),
                        });

                        // 2. Add vaccination event to poultry batch logs on backend
                        final cost = dose * matchMed.costPerUnit;
                        poultryBloc.add(LogBatchEvent(_currentBatch.id, {
                          'event_type': 'vaccination',
                          'quantity': dose,
                          'value_json': {
                            'cost': cost,
                            'medication_name': matchMed.name,
                            'condition': diagnosisCtrl.text.trim(),
                          }
                        }));

                        dialogNav.pop();
                        _refreshData();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Log Medication'),
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

  void _showLogMortalityDialog(BuildContext context) {
    final countCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Log Bird Mortality'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Flock Size: ${_currentBatch.currentCount} Birds', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(textCapitalization: TextCapitalization.sentences, controller: countCtrl,
                decoration: const InputDecoration(labelText: 'Mortality Count *'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final mort = int.tryParse(countCtrl.text) ?? 0;
                if (mort <= 0) return;
                if (mort > _currentBatch.currentCount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mortality count cannot exceed current flock size.'), backgroundColor: AppColors.error),
                  );
                  return;
                }

                BlocProvider.of<PoultryBloc>(context).add(LogBatchEvent(_currentBatch.id, {
                  'event_type': 'mortality',
                  'quantity': mort.toDouble(),
                  'value_json': null,
                }));

                Navigator.pop(dialogCtx);
                _refreshData();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Log Mortality'),
            ),
          ],
        );
      },
    );
  }

  void _showLogWeightDialog(BuildContext context) {
    final weightCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Log Weight Sample'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the average weight of sampled birds.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(textCapitalization: TextCapitalization.sentences, controller: weightCtrl,
                decoration: const InputDecoration(labelText: 'Average Weight (kg) *', hintText: 'e.g. 1.85'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final wt = double.tryParse(weightCtrl.text) ?? 0.0;
                if (wt <= 0) return;

                BlocProvider.of<PoultryBloc>(context).add(LogBatchEvent(_currentBatch.id, {
                  'event_type': 'weight_sample',
                  'quantity': wt,
                  'value_json': {
                    'avg_weight_kg': wt,
                  }
                }));

                Navigator.pop(dialogCtx);
                _refreshData();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Log Weight'),
            ),
          ],
        );
      },
    );
  }

  void _showSaleDialog(BuildContext context, Map<String, dynamic> kpis) {
    final birdsCtrl = TextEditingController(text: _currentBatch.currentCount.toString());
    final priceCtrl = TextEditingController();
    final weightCtrl = TextEditingController(text: kpis['average_weight_kg']?.toString() ?? '1.5');
    final customerCtrl = TextEditingController();
    bool isClosing = false;
    final poultryBloc = BlocProvider.of<PoultryBloc>(context);
    final nav = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final int count = int.tryParse(birdsCtrl.text) ?? 0;
            final double price = double.tryParse(priceCtrl.text) ?? 0.0;
            final double revenue = count * price;

            return AlertDialog(
              title: const Text('Log Sales / Harvest'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('flock sales details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    const Divider(),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: birdsCtrl,
                      decoration: const InputDecoration(labelText: 'Total Birds Sold *'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setStateDialog(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: priceCtrl,
                      decoration: const InputDecoration(labelText: 'Price per Bird (₦) *'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setStateDialog(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: weightCtrl,
                      decoration: const InputDecoration(labelText: 'Average Weight (kg) *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: customerCtrl,
                      decoration: const InputDecoration(labelText: 'Customer / Buyer Name', hintText: 'e.g. Market Distributors Ltd'),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Revenue:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(
                            _currencyFmt.format(revenue),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Close this batch', style: TextStyle(fontSize: 13)),
                      subtitle: const Text('Check this if all remaining birds are sold or the batch is finished.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: isClosing,
                      onChanged: (val) {
                        setStateDialog(() {
                          isClosing = val ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (birdsCtrl.text.isEmpty || priceCtrl.text.isEmpty || weightCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    if (count <= 0 || price <= 0) return;

                    final dialogNav = Navigator.of(dialogCtx);

                    // 1. Log Income Transaction in Finance Repository
                    await sl<FinanceRepository>().addTransaction({
                      'transaction_type': 'income',
                      'category': 'poultry_sales',
                      'amount': revenue,
                      'related_entity_type': 'poultry_batch',
                      'related_entity_id': _currentBatch.id,
                      'description': 'Harvest sales of $count birds at ₦$price each from batch #${_currentBatch.batchNumber}. Customer: ${customerCtrl.text.trim()}',
                      'transaction_date': DateTime.now().toIso8601String().substring(0, 10),
                    });

                    // 2. Log Sale and conditionally close batch in Poultry
                    poultryBloc.add(LogBatchSale(_currentBatch.id, {
                      'quantity': count,
                      'avg_weight_kg': double.parse(weightCtrl.text),
                      'revenue': revenue,
                      'is_closing': isClosing,
                    }));

                    dialogNav.pop();
                    if (isClosing || _currentBatch.currentCount - count <= 0) {
                      nav.pop(); // Go back to batch listing
                    } else {
                      _refreshData();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: Text(isClosing ? 'Close Batch & Log Sales' : 'Log Partial Sale'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPerformanceCharts(List<Map<String, dynamic>> timeline) {
    final logs = timeline.where((t) => t['type'] == 'poultry_log').toList().reversed.toList();
    
    final List<double> fcrData = [];
    final List<double> mortData = [];
    final List<String> labels = [];
    
    double cumMortality = 0.0;
    double cumFeedKg = 0.0;
    double currentAvgWeight = 0.04;
    int currentLiveCount = _currentBatch.initialCount;
    
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final date = log['date'] as DateTime;
      labels.add(DateFormat('dd/MM').format(date));
      
      final dailyMort = int.tryParse(log['mortality']?.toString() ?? '0') ?? 0;
      cumMortality += dailyMort;
      mortData.add(cumMortality);
      
      currentLiveCount = (currentLiveCount - dailyMort).clamp(0, _currentBatch.initialCount);

      final feedBags = int.tryParse(log['feed_bags']?.toString() ?? '0') ?? 0;
      cumFeedKg += feedBags * 25.0;

      final double? avgWeight = double.tryParse(log['average_weight']?.toString() ?? '');
      if (avgWeight != null && avgWeight > 0) {
        currentAvgWeight = avgWeight;
      }

      final liveWeight = currentAvgWeight * currentLiveCount;
      final initialWeight = _currentBatch.initialCount * 0.04;
      final weightGain = (liveWeight - initialWeight).clamp(0.0, double.infinity);
      final double fcr = weightGain > 0 ? (cumFeedKg / weightGain) : 1.5;
      fcrData.add(double.parse(fcr.toStringAsFixed(2)).clamp(0.5, 4.0));
    }
    
    // Adapt for fresh batches with limited logs so line chart renders beautifully from baseline start
    if (logs.isEmpty) {
      labels.addAll(['Start', 'Today']);
      mortData.addAll([0.0, 0.0]);
      fcrData.addAll([1.50, 1.50]);
    } else if (logs.length == 1) {
      labels.insert(0, 'Start');
      mortData.insert(0, 0.0);
      fcrData.insert(0, 1.50);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_graph_outlined, color: Colors.brown),
                SizedBox(width: 8),
                Text('FLOCK PERFORMANCE CURVES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Feed Conversion Ratio (FCR) Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            CustomLineChart(
              data: fcrData,
              labels: labels,
              lineColor: Colors.brown.shade700,
              gradientColors: [Colors.brown.shade200.withOpacity(0.4), Colors.brown.shade200.withOpacity(0.0)],
              height: 130,
            ),
            const SizedBox(height: 16),
            const Text('Cumulative Mortality Count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            CustomLineChart(
              data: mortData,
              labels: labels,
              lineColor: Colors.red.shade700,
              gradientColors: [Colors.red.shade200.withOpacity(0.4), Colors.red.shade200.withOpacity(0.0)],
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}

