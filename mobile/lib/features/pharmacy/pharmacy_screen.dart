import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import '../animals/animals_repository.dart';
import '../poultry/poultry_repository.dart';
import 'pharmacy_bloc.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFmt = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

  List<LocalMedication>? _cachedMeds;
  List<LocalMedicationLog>? _cachedLogs;
  List<LocalAnimalMedicalRecord>? _cachedRecords;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PharmacyBloc, PharmacyState>(
      listener: (context, state) {
        if (state is PharmacyLoaded) {
          _cachedMeds = state.medications;
          _cachedLogs = state.logs;
          _cachedRecords = state.medicalRecords;
          setState(() {});
        } else if (state is PharmacyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PharmacyLoading;

        if (state is PharmacyLoaded) {
          _cachedMeds = state.medications;
          _cachedLogs = state.logs;
          _cachedRecords = state.medicalRecords;
        }

        if (isLoading && _cachedMeds == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('VETERINARY APOTHECARY'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.medication), text: 'Meds Stock'),
                Tab(icon: Icon(Icons.history_edu), text: 'Treatments'),
                Tab(icon: Icon(Icons.analytics), text: 'Audit Logs'),
              ],
            ),
          ),
          body: Column(
            children: [
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
                    _buildMedsTab(context, _cachedMeds ?? []),
                    _buildTreatmentsTab(context, _cachedRecords ?? [], _cachedMeds ?? []),
                    _buildLogsTab(context, _cachedLogs ?? [], _cachedMeds ?? []),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFAB(context, _cachedMeds ?? []),
        );
      },
    );
  }

  Widget? _buildFAB(BuildContext context, List<LocalMedication> medications) {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () => _showAddMedicationDialog(context),
          label: const Text('Add Medication'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        );
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => _showLogTreatmentDialog(context, medications),
          label: const Text('Log Treatment'),
          icon: const Icon(Icons.health_and_safety),
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }

  // ═══════════════════════════════════════════
  // TAB 1: MEDICATIONS STOCK
  // ═══════════════════════════════════════════

  Widget _buildMedsTab(BuildContext context, List<LocalMedication> meds) {
    final lowStock = meds.where((m) => m.currentStock <= m.reorderThreshold).toList();
    final totalValue = meds.fold<double>(0.0, (s, m) => s + (m.currentStock * m.costPerUnit));

    return Column(
      children: [
        // Summary KPI
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _kpiCard('Total Valuation', _currencyFmt.format(totalValue), Icons.payments, AppColors.primary),
              const SizedBox(width: 12),
              _kpiCard('Low Stock Alerts', '${lowStock.length} Medications', Icons.warning_amber, AppColors.error),
            ],
          ),
        ),

        // List
        Expanded(
          child: meds.isEmpty
              ? const Center(child: Text('No medications registered. Add one using the button below.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: meds.length,
                  itemBuilder: (ctx, idx) {
                    final med = meds[idx];
                    final isLow = med.currentStock <= med.reorderThreshold;
                    final progress = med.currentStock > 0
                        ? (med.currentStock / (med.reorderThreshold * 3.0)).clamp(0.0, 1.0)
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(med.category).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getCategoryDisplayName(med.category).toUpperCase(),
                                    style: TextStyle(
                                      color: _getCategoryColor(med.category),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (med.expiryDate != null)
                                  Text(
                                    'Expires: ${DateFormat('yyyy-MM-dd').format(med.expiryDate!)}',
                                    style: TextStyle(
                                      color: med.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)))
                                          ? Colors.orange
                                          : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  )
                                else
                                  const Text('No Expiry Date', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Stock: ${med.currentStock.toStringAsFixed(1)} ${med.unit}', style: TextStyle(fontWeight: FontWeight.bold, color: isLow ? AppColors.error : Colors.black)),
                                Text('Unit Cost: ₦ ${med.costPerUnit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(isLow ? AppColors.error : AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Withdrawals - Milk: ${med.milkWithdrawalDays}d | Meat: ${med.meatWithdrawalDays}d',
                                    style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11, fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                                      onPressed: () => _showEditMedicationDialog(context, med),
                                      tooltip: 'Edit Details',
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                      onPressed: () => _showRestockDialog(context, med),
                                      tooltip: 'Restock Drug',
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () => _showDiscardDialog(context, med),
                                      tooltip: 'Log Wastage',
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // TAB 2: ANIMAL TREATMENTS
  // ═══════════════════════════════════════════

  Widget _buildTreatmentsTab(BuildContext context, List<LocalAnimalMedicalRecord> records, List<LocalMedication> medications) {
    if (records.isEmpty) {
      return const Center(child: Text('No treatment records logged. Use "+ Log Treatment" below.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (ctx, idx) {
        final rec = records[idx];
        final med = medications.firstWhere((m) => m.id == rec.medicationId,
            orElse: () => LocalMedication(
                  id: rec.medicationId,
                  name: 'Unknown medication',
                  category: 'other',
                  unit: 'units',
                  currentStock: 0,
                  reorderThreshold: 0,
                  costPerUnit: 0,
                  isActive: true,
                  milkWithdrawalDays: 0,
                  meatWithdrawalDays: 0,
                ));

        final hasWithdrawal = rec.withdrawalEndDate != null && rec.withdrawalEndDate!.isAfter(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FutureBuilder<dynamic>(
                        future: (sl<AnimalsRepository>().db.select(sl<AnimalsRepository>().db.localAnimals)..where((t) => t.id.equals(rec.animalId))).getSingleOrNull(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final animalTag = snapshot.data!.tagId;
                            final species = ' (${snapshot.data!.species.toString().toUpperCase()})';
                            return Text(
                              'Animal: $animalTag$species',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          // Fallback to checking if it is a poultry batch
                          return FutureBuilder<dynamic>(
                            future: (sl<PoultryRepository>().db.select(sl<PoultryRepository>().db.localPoultryBatches)..where((t) => t.id.equals(rec.animalId))).getSingleOrNull(),
                            builder: (context, batchSnap) {
                              if (batchSnap.hasData && batchSnap.data != null) {
                                return Text(
                                  'Flock Batch #${batchSnap.data!.batchNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text(
                                'Animal ID: ${rec.animalId.split('-').first}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                              );
                            }
                          );
                        },
                      ),
                    ),
                    Text(
                      _currencyFmt.format(rec.cost),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Diagnosis: ${rec.diagnosedCondition}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Administered: ${rec.administeredDose} ${med.unit} of ${med.name}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(rec.treatmentDate)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                if (rec.administeredBy != null) ...[
                  const SizedBox(height: 4),
                  Text('Administered By: ${rec.administeredBy}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
                if (rec.notes != null && rec.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Notes: ${rec.notes}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
                if (hasWithdrawal) ...[
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Active Withdrawal ends: ${DateFormat('yyyy-MM-dd').format(rec.withdrawalEndDate!)}',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // TAB 3: AUDIT LOGS
  // ═══════════════════════════════════════════

  Widget _buildLogsTab(BuildContext context, List<LocalMedicationLog> logs, List<LocalMedication> medications) {
    if (logs.isEmpty) {
      return const Center(child: Text('No audit logs recorded yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (ctx, idx) {
        final log = logs[idx];
        final med = medications.firstWhere((m) => m.id == log.medicationId,
            orElse: () => LocalMedication(
                  id: log.medicationId,
                  name: 'Unknown medication',
                  category: 'other',
                  unit: 'units',
                  currentStock: 0,
                  reorderThreshold: 0,
                  costPerUnit: 0,
                  isActive: true,
                  milkWithdrawalDays: 0,
                  meatWithdrawalDays: 0,
                ));

        Color changeColor = Colors.grey;
        if (log.changeType == 'purchase') {
          changeColor = Colors.green;
        } else if (log.changeType == 'treatment' || log.changeType == 'discard') {
          changeColor = Colors.red;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: changeColor.withValues(alpha: 0.15),
              child: Icon(
                log.changeType == 'purchase'
                    ? Icons.add_shopping_cart
                    : log.changeType == 'treatment'
                        ? Icons.health_and_safety
                        : Icons.delete_outline,
                color: changeColor,
                size: 20,
              ),
            ),
            title: Text('${log.changeType.toUpperCase()} - ${med.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change: ${log.quantityChange > 0 ? "+" : ""}${log.quantityChange} ${med.unit} | Balance: ${log.balanceAfter} ${med.unit}',
                  style: const TextStyle(fontSize: 11),
                ),
                if (log.notes != null && log.notes!.isNotEmpty)
                  Text('Notes: ${log.notes}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
            trailing: Text(DateFormat('dd/MM HH:mm').format(log.logDate), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ),
        );
      },
    );
  }

  String _getCategoryDisplayName(String key) {
    switch (key) {
      case 'antibiotic':
        return 'Antibiotic';
      case 'vaccine':
        return 'Vaccine';
      case 'dewormer':
        return 'Dewormer';
      case 'ectoparasiticide':
        return 'Ectoparasiticide';
      case 'nsaid':
        return 'NSAID (Painkiller)';
      case 'hormone':
        return 'Hormone / Breeding';
      case 'supplement':
        return 'Supplement / Vitamin';
      case 'antiseptic':
        return 'Antiseptic / Disinfectant';
      case 'rehydration':
        return 'Rehydration / IV';
      case 'anesthetic':
        return 'Anesthetic / Sedative';
      default:
        return 'Other';
    }
  }

  Color _getCategoryColor(String key) {
    switch (key) {
      case 'antibiotic':
        return Colors.red;
      case 'vaccine':
        return Colors.green;
      case 'dewormer':
        return Colors.brown;
      case 'ectoparasiticide':
        return Colors.purple;
      case 'nsaid':
        return Colors.orange;
      case 'hormone':
        return Colors.pink;
      case 'supplement':
        return Colors.teal;
      case 'antiseptic':
        return Colors.indigo;
      case 'rehydration':
        return Colors.blue;
      case 'anesthetic':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  // ═══════════════════════════════════════════
  // MODALS AND DIALOGS
  // ═══════════════════════════════════════════

  void _showAddMedicationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final thresholdCtrl = TextEditingController(text: '10');
    final supplierCtrl = TextEditingController();
    final milkWithdrawCtrl = TextEditingController(text: '0');
    final meatWithdrawCtrl = TextEditingController(text: '0');

    // Wholesale Pricing Fields
    final numPacksCtrl = TextEditingController(text: '1');
    final costPackCtrl = TextEditingController();
    final unitsPackCtrl = TextEditingController(text: '100');

    String category = 'antibiotic';
    String unit = 'ml';
    String purchaseUnitType = 'box';
    DateTime? expiryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            // Live calculations
            final double numPacks = double.tryParse(numPacksCtrl.text) ?? 0.0;
            final double costPack = double.tryParse(costPackCtrl.text) ?? 0.0;
            final double unitsPack = double.tryParse(unitsPackCtrl.text) ?? 0.0;

            final double computedStock = numPacks * unitsPack;
            final double computedUnitCost = unitsPack > 0 ? (costPack / unitsPack) : 0.0;
            final double totalCost = numPacks * costPack;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Medication', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Medication General Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    const Divider(),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Medication Name *', hintText: 'e.g. Oxytetracycline 20%'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Vet Category *'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'antibiotic', child: Text('Antibiotic / Antimicrobial')),
                        DropdownMenuItem(value: 'vaccine', child: Text('Vaccine')),
                        DropdownMenuItem(value: 'dewormer', child: Text('Dewormer / Anthelmintic')),
                        DropdownMenuItem(value: 'ectoparasiticide', child: Text('Ectoparasiticide (Tick/Flea)')),
                        DropdownMenuItem(value: 'nsaid', child: Text('NSAID (Anti-inflammatory/Pain)')),
                        DropdownMenuItem(value: 'hormone', child: Text('Hormone / Breeding')),
                        DropdownMenuItem(value: 'supplement', child: Text('Supplement / Vitamin')),
                        DropdownMenuItem(value: 'antiseptic', child: Text('Antiseptic / Disinfectant')),
                        DropdownMenuItem(value: 'rehydration', child: Text('Rehydration / IV Fluids')),
                        DropdownMenuItem(value: 'anesthetic', child: Text('Anesthetic / Sedative')),
                        DropdownMenuItem(value: 'other', child: Text('Other / Miscellaneous')),
                      ],
                      onChanged: (v) => category = v!,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: unit,
                            decoration: const InputDecoration(labelText: 'Dose Admin Unit *'),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'ml', child: Text('Milliliters (ml)')),
                              DropdownMenuItem(value: 'mg', child: Text('Milligrams (mg)')),
                              DropdownMenuItem(value: 'g', child: Text('Grams (g)')),
                              DropdownMenuItem(value: 'tabs', child: Text('Tablets (tabs)')),
                              DropdownMenuItem(value: 'doses', child: Text('Doses')),
                              DropdownMenuItem(value: 'vials', child: Text('Vials')),
                              DropdownMenuItem(value: 'ampoules', child: Text('Ampoules')),
                              DropdownMenuItem(value: 'sachets', child: Text('Sachets')),
                              DropdownMenuItem(value: 'bolus', child: Text('Bolus')),
                            ],
                            onChanged: (v) => setStateDialog(() => unit = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(textCapitalization: TextCapitalization.sentences, controller: thresholdCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Reorder At *', suffixText: 'units'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Wholesale Purchase & Unit Cost Auto-Calc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    const Divider(),
                    DropdownButtonFormField<String>(
                      initialValue: purchaseUnitType,
                      decoration: const InputDecoration(labelText: 'Purchase Package Type *'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'pack', child: Text('Pack')),
                        DropdownMenuItem(value: 'box', child: Text('Box')),
                        DropdownMenuItem(value: 'bottle', child: Text('Bottle')),
                        DropdownMenuItem(value: 'vial', child: Text('Vial')),
                        DropdownMenuItem(value: 'ampoule', child: Text('Ampoule')),
                        DropdownMenuItem(value: 'sachet', child: Text('Sachet')),
                        DropdownMenuItem(value: 'tub', child: Text('Tub')),
                      ],
                      onChanged: (v) => purchaseUnitType = v!,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(textCapitalization: TextCapitalization.sentences, controller: numPacksCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Packs/Boxes Bought *'),
                            onChanged: (v) => setStateDialog(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(textCapitalization: TextCapitalization.sentences, controller: costPackCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Cost Per Pack (₦) *'),
                            onChanged: (v) => setStateDialog(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: unitsPackCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Size / Dose Units inside each Pack *',
                        hintText: 'e.g. 500 if 500 ml per bottle',
                        suffixText: unit,
                      ),
                      onChanged: (v) => setStateDialog(() {}),
                    ),
                    const SizedBox(height: 12),
                    // Summary Calculation Preview Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('Calculated Dose Unit Cost:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '₦ ${computedUnitCost.toStringAsFixed(2)} / $unit',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('Total Opening Stock Added:', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${computedStock.toStringAsFixed(1)} $unit',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('Total Purchase Outlay:', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '₦ ${totalCost.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Withdrawal Safety & Logistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(textCapitalization: TextCapitalization.sentences, controller: milkWithdrawCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Milk Withdrawal (Days)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(textCapitalization: TextCapitalization.sentences, controller: meatWithdrawCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Meat Withdrawal (Days)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: supplierCtrl, decoration: const InputDecoration(labelText: 'Supplier Name')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expiryDate == null
                                ? 'No Expiry Date Selected'
                                : 'Expires: ${DateFormat('yyyy-MM-dd').format(expiryDate!)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) {
                              setStateDialog(() => expiryDate = picked);
                            }
                          },
                          child: const Text('Pick Expiry'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameCtrl.text.isEmpty || numPacksCtrl.text.isEmpty || costPackCtrl.text.isEmpty || unitsPackCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              BlocProvider.of<PharmacyBloc>(context).add(AddMedication({
                                'name': nameCtrl.text.trim(),
                                'category': category,
                                'unit': unit,
                                'current_stock': computedStock.toString(),
                                'reorder_threshold': thresholdCtrl.text.trim(),
                                'cost_per_unit': computedUnitCost.toString(),
                                'batch_number': null,
                                'milk_withdrawal_days': milkWithdrawCtrl.text.trim(),
                                'meat_withdrawal_days': meatWithdrawCtrl.text.trim(),
                                'supplier': supplierCtrl.text.trim().isNotEmpty ? supplierCtrl.text.trim() : null,
                                'expiry_date': expiryDate?.toIso8601String(),
                              }));
                              Navigator.pop(dialogCtx);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text('Save Medication'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditMedicationDialog(BuildContext context, LocalMedication med) {
    final nameCtrl = TextEditingController(text: med.name);
    final thresholdCtrl = TextEditingController(text: med.reorderThreshold.toStringAsFixed(0));
    final supplierCtrl = TextEditingController(text: med.supplier ?? '');
    final milkWithdrawCtrl = TextEditingController(text: med.milkWithdrawalDays.toString());
    final meatWithdrawCtrl = TextEditingController(text: med.meatWithdrawalDays.toString());
    final costPerUnitCtrl = TextEditingController(text: med.costPerUnit.toStringAsFixed(2));

    String category = med.category;
    String unit = med.unit;
    DateTime? expiryDate = med.expiryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit Medication Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Medication Name *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category *'),
                      items: ['antibiotic', 'vaccine', 'dewormer', 'vitamin', 'supplement', 'other']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setStateDialog(() => category = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: unit,
                      decoration: const InputDecoration(labelText: 'Unit *'),
                      items: ['ml', 'g', 'kg', 'bolus', 'vial', 'tablets', 'units']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setStateDialog(() => unit = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: thresholdCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Reorder Level Threshold *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costPerUnitCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Cost Per Unit (₦) *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: milkWithdrawCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Milk Withdrawal (Days) *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: meatWithdrawCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Meat Withdrawal (Days) *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: supplierCtrl,
                      decoration: const InputDecoration(labelText: 'Supplier Name'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          expiryDate == null
                              ? 'No Expiry Date Set'
                              : 'Expires: ${DateFormat('yyyy-MM-dd').format(expiryDate!)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) {
                              setStateDialog(() => expiryDate = picked);
                            }
                          },
                          child: const Text('Pick Expiry'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameCtrl.text.isEmpty || thresholdCtrl.text.isEmpty || costPerUnitCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              BlocProvider.of<PharmacyBloc>(context).add(EditMedication(
                                med.id,
                                {
                                  'name': nameCtrl.text.trim(),
                                  'category': category,
                                  'unit': unit,
                                  'reorder_threshold': thresholdCtrl.text.trim(),
                                  'cost_per_unit': costPerUnitCtrl.text.trim(),
                                  'milk_withdrawal_days': milkWithdrawCtrl.text.trim(),
                                  'meat_withdrawal_days': meatWithdrawCtrl.text.trim(),
                                  'supplier': supplierCtrl.text.trim().isNotEmpty ? supplierCtrl.text.trim() : null,
                                  'expiry_date': expiryDate?.toIso8601String(),
                                },
                              ));
                              Navigator.pop(dialogCtx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRestockDialog(BuildContext context, LocalMedication med) {
    final numPacksCtrl = TextEditingController(text: '1');
    final costPackCtrl = TextEditingController();
    final unitsPackCtrl = TextEditingController(text: '100');
    final notesCtrl = TextEditingController();
    String purchaseUnitType = 'box';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final double numPacks = double.tryParse(numPacksCtrl.text) ?? 0.0;
            final double costPack = double.tryParse(costPackCtrl.text) ?? 0.0;
            final double unitsPack = double.tryParse(unitsPackCtrl.text) ?? 0.0;

            final double computedQtyAdded = numPacks * unitsPack;
            final double computedUnitCost = unitsPack > 0 ? (costPack / unitsPack) : 0.0;
            final double totalCost = numPacks * costPack;

            return AlertDialog(
              title: Text('Restock "${med.name}"'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Stock: ${med.currentStock} ${med.unit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Text('Purchase & Cost Calculations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    const Divider(),
                    DropdownButtonFormField<String>(
                      initialValue: purchaseUnitType,
                      decoration: const InputDecoration(labelText: 'Purchase Package Type *'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'pack', child: Text('Pack')),
                        DropdownMenuItem(value: 'box', child: Text('Box')),
                        DropdownMenuItem(value: 'bottle', child: Text('Bottle')),
                        DropdownMenuItem(value: 'vial', child: Text('Vial')),
                        DropdownMenuItem(value: 'ampoule', child: Text('Ampoule')),
                        DropdownMenuItem(value: 'sachet', child: Text('Sachet')),
                        DropdownMenuItem(value: 'tub', child: Text('Tub')),
                      ],
                      onChanged: (v) => purchaseUnitType = v!,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(textCapitalization: TextCapitalization.sentences, controller: numPacksCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Packs/Boxes Bought *'),
                            onChanged: (v) => setStateDialog(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(textCapitalization: TextCapitalization.sentences, controller: costPackCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Cost Per Pack (₦) *'),
                            onChanged: (v) => setStateDialog(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: unitsPackCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Units inside each Pack *',
                        hintText: 'e.g. 500 if 500 ml per bottle',
                        suffixText: med.unit,
                      ),
                      onChanged: (v) => setStateDialog(() {}),
                    ),
                    const SizedBox(height: 12),
                    // Summary calculated card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('Calculated Dose Unit Cost:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₦ ${computedUnitCost.toStringAsFixed(2)} / ${med.unit}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('Dose Units Added to Stock:', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${computedQtyAdded.toStringAsFixed(1)} ${med.unit}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('Total Outlay Cost:', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₦ ${totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl,
                      decoration: const InputDecoration(labelText: 'Restock Notes (optional)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (numPacksCtrl.text.isEmpty || costPackCtrl.text.isEmpty || unitsPackCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    if (computedQtyAdded <= 0) return;
                    BlocProvider.of<PharmacyBloc>(context).add(UpdateMedicationStock({
                      'medication_id': med.id,
                      'change_type': 'purchase',
                      'quantity_change': computedQtyAdded,
                      'cost_per_unit': computedUnitCost,
                      'notes': notesCtrl.text.trim().isNotEmpty
                          ? notesCtrl.text.trim()
                          : 'Restocked $numPacks $purchaseUnitType(s) at ₦${computedUnitCost.toStringAsFixed(2)} per ${med.unit}',
                    }));
                    Navigator.pop(dialogCtx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Restock'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDiscardDialog(BuildContext context, LocalMedication med) {
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Log Waste / Discard for "${med.name}"'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Stock: ${med.currentStock} ${med.unit}'),
              const SizedBox(height: 8),
              TextField(textCapitalization: TextCapitalization.sentences, controller: qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Discard Quantity (${med.unit}) *'),
              ),
              const SizedBox(height: 8),
              TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Reason for Discard (e.g. Expired) *'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                if (qty <= 0 || notesCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                  );
                  return;
                }
                BlocProvider.of<PharmacyBloc>(context).add(DiscardStock({
                  'medication_id': med.id,
                  'quantity_change': -qty,
                  'notes': notesCtrl.text.trim(),
                }));
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('Log Discard'),
            ),
          ],
        );
      },
    );
  }

  void _showLogTreatmentDialog(BuildContext context, List<LocalMedication> medications) {
    if (medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register at least one medication in Pharmacy Stock first!'), backgroundColor: AppColors.error),
      );
      return;
    }

    final animalsRepo = sl<AnimalsRepository>();
    final pharmacyBloc = BlocProvider.of<PharmacyBloc>(context);

    String? selectedAnimalId;
    String? selectedMedId = medications.first.id;
    final doseCtrl = TextEditingController();
    final diagnosisCtrl = TextEditingController();
    final adminByCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime treatmentDate = DateTime.now();
    double totalCost = 0.0;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return FutureBuilder<List<dynamic>>(
          future: animalsRepo.getAnimals(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawList = snapshot.data ?? [];
            final activeAnimals = <Map<String, dynamic>>[];
            for (var a in rawList) {
              final isMap = a is Map;
              final status = ((isMap ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
              if (status != 'dead') {
                activeAnimals.add({
                  'id': (isMap ? a['id'] : a.id)?.toString() ?? '',
                  'tag': (isMap ? a['tag_id'] : a.tagId)?.toString() ?? 'Unknown',
                  'species': (isMap ? a['species'] : a.species)?.toString() ?? 'Other',
                });
              }
            }

            return StatefulBuilder(
              builder: (ctx, setDialogState) {
                final matchMed = medications.firstWhere((m) => m.id == selectedMedId);

                // Auto calculate treatment cost dynamically in forms
                final double dose = double.tryParse(doseCtrl.text) ?? 0.0;
                totalCost = dose * matchMed.costPerUnit;

                return AlertDialog(
                  title: const Text('Log Animal Medical Treatment'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedAnimalId,
                          decoration: const InputDecoration(labelText: 'Select Animal *'),
                          isExpanded: true,
                          items: activeAnimals.map((a) {
                            return DropdownMenuItem(value: a['id'] as String, child: Text('Tag ${a['tag']} (${a['species']})'));
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedAnimalId = v),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: selectedMedId,
                          decoration: const InputDecoration(labelText: 'Administered Drug *'),
                          isExpanded: true,
                          items: medications.map((m) {
                            return DropdownMenuItem(value: m.id, child: Text(m.name));
                          }).toList(),
                          onChanged: (v) => setDialogState(() {
                            selectedMedId = v;
                          }),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(textCapitalization: TextCapitalization.sentences, controller: doseCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(labelText: 'Dosage (${matchMed.unit}) *'),
                                onChanged: (v) => setDialogState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Estimated Cost', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currencyFmt.format(totalCost),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: diagnosisCtrl, decoration: const InputDecoration(labelText: 'Diagnosed Condition / Reason *', hintText: 'e.g. Mastitis, Hoof Rot')),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: adminByCtrl, decoration: const InputDecoration(labelText: 'Administered By (Doctor/Worker)')),
                        const SizedBox(height: 8),
                        TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl, decoration: const InputDecoration(labelText: 'General Treatment Notes')),
                        if (matchMed.milkWithdrawalDays > 0 || matchMed.meatWithdrawalDays > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Withdrawal Periods: Milk ${matchMed.milkWithdrawalDays}d | Meat ${matchMed.meatWithdrawalDays}d',
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedAnimalId == null || selectedMedId == null || doseCtrl.text.isEmpty || diagnosisCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                          );
                          return;
                        }

                        pharmacyBloc.add(LogTreatment({
                          'animal_id': selectedAnimalId,
                          'medication_id': selectedMedId,
                          'administered_dose': doseCtrl.text.trim(),
                          'treatment_date': treatmentDate.toIso8601String(),
                          'diagnosed_condition': diagnosisCtrl.text.trim(),
                          'administered_by': adminByCtrl.text.trim().isNotEmpty ? adminByCtrl.text.trim() : null,
                          'notes': notesCtrl.text.trim(),
                        }));
                        Navigator.pop(dialogCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Treatment logged successfully!'), backgroundColor: AppColors.secondary),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Log Treatment'),
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
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
