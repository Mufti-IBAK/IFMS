import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import '../animals/animals_repository.dart';
import '../poultry/poultry_repository.dart';
import 'pharmacy_bloc.dart';
import '../../core/utils/dosage_calculator.dart';

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
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: AppColors.secondary,
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.medication), text: 'Rx Stock'),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    med.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.end,
                                  children: [
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
                                    if (med.concentration != null && med.concentration!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          med.concentration!,
                                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                      ),
                                    if (med.dosageRateText != null && med.dosageRateText!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Dose: ${med.dosageRateText!}',
                                          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 10),
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
    final concValCtrl = TextEditingController(text: '2.5');
    String concUnit = '%'; // '%', 'mg_ml', 'mg_tab', 'mg_g'
    final dosageMlCtrl = TextEditingController(text: '7.5');
    String selectedDosagePreset = '7.5mg_kg';

    // Wholesale Pricing Fields
    final numPacksCtrl = TextEditingController(text: '1');
    final costPackCtrl = TextEditingController();
    final unitsPackCtrl = TextEditingController(text: '100');

    String category = 'dewormer';
    String unit = 'ml';
    String purchaseUnitType = 'bottle';
    DateTime? expiryDate;

    int currentStep = 0; // 0: Basics, 1: Dosing & Safety, 2: Pricing & Stock

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

            // Concentration & Dosage auto-calculations
            final double rawConcVal = double.tryParse(concValCtrl.text) ?? 0.0;
            final double rateMgKg = double.tryParse(dosageMlCtrl.text) ?? 0.0;

            double? concMgPerMl;
            String concDisplayText = '';

            if (rawConcVal > 0) {
              if (concUnit == '%') {
                concMgPerMl = rawConcVal * 10.0; // 2.5% = 25 mg/ml
                concDisplayText = '$rawConcVal% (${concMgPerMl.toStringAsFixed(1)} mg/ml)';
              } else if (concUnit == 'mg_ml') {
                concMgPerMl = rawConcVal;
                concDisplayText = '${rawConcVal.toStringAsFixed(1)} mg/ml';
              } else if (concUnit == 'mg_tab') {
                concMgPerMl = rawConcVal;
                concDisplayText = '${rawConcVal.toStringAsFixed(1)} mg/tab';
              } else {
                concMgPerMl = rawConcVal;
                concDisplayText = '${rawConcVal.toStringAsFixed(1)} mg/g';
              }
            }

            // Live sample formula breakdown for a 42kg animal
            double? sampleActiveMg;
            double? sampleVolumeMl;
            if (rateMgKg > 0) {
              sampleActiveMg = 42.0 * rateMgKg;
              if (concMgPerMl != null && concMgPerMl > 0) {
                sampleVolumeMl = sampleActiveMg / concMgPerMl;
              }
            }

            final sheetHeight = MediaQuery.of(context).size.height * 0.82;

            return Container(
              height: sheetHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  // Modal Header with Drag Handle & Step Tabs
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.medication_liquid, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Add New Medication',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => Navigator.pop(dialogCtx),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 3 Step Tabs
                        Row(
                          children: [
                            _buildStepTab(
                              index: 0,
                              title: '1. General',
                              icon: Icons.info_outline,
                              isActive: currentStep == 0,
                              isCompleted: currentStep > 0,
                              onTap: () => setStateDialog(() => currentStep = 0),
                            ),
                            const SizedBox(width: 6),
                            _buildStepTab(
                              index: 1,
                              title: '2. Dosing',
                              icon: Icons.science_outlined,
                              isActive: currentStep == 1,
                              isCompleted: currentStep > 1,
                              onTap: () {
                                if (nameCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter Medication Name first'), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
                                setStateDialog(() => currentStep = 1);
                              },
                            ),
                            const SizedBox(width: 6),
                            _buildStepTab(
                              index: 2,
                              title: '3. Pricing',
                              icon: Icons.inventory_2_outlined,
                              isActive: currentStep == 2,
                              isCompleted: false,
                              onTap: () {
                                if (nameCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter Medication Name first'), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
                                setStateDialog(() => currentStep = 2);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Linear Step Progress Bar
                  LinearProgressIndicator(
                    value: (currentStep + 1) / 3.0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 3,
                  ),

                  // Step Content Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: IndexedStack(
                        index: currentStep,
                        children: [
                          // ══ STEP 0: BASICS & CONCENTRATION ══
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Step 1: General Details & Strength', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                              const SizedBox(height: 12),
                              TextField(
                                textCapitalization: TextCapitalization.sentences,
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Medication Name *',
                                  hintText: 'e.g. Levamisole 2.5% or Oxytetracycline 20%',
                                  prefixIcon: Icon(Icons.medication, size: 20),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: category,
                                decoration: const InputDecoration(
                                  labelText: 'Vet Category *',
                                  prefixIcon: Icon(Icons.category, size: 20),
                                ),
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
                                onChanged: (v) => setStateDialog(() => category = v!),
                              ),
                              const SizedBox(height: 14),
                              const Text('Drug Concentration (% or mg/ml)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: concValCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Concentration Value *',
                                        hintText: 'e.g. 2.5 or 25',
                                      ),
                                      onChanged: (v) => setStateDialog(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: concUnit,
                                      decoration: const InputDecoration(labelText: 'Unit *'),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(value: '%', child: Text('% (Percentage)')),
                                        DropdownMenuItem(value: 'mg_ml', child: Text('mg/ml (Liquid Conc.)')),
                                        DropdownMenuItem(value: 'mg_tab', child: Text('mg/tab (Tablet Strength)')),
                                        DropdownMenuItem(value: 'mg_g', child: Text('mg/g (Powder Conc.)')),
                                      ],
                                      onChanged: (v) => setStateDialog(() => concUnit = v!),
                                    ),
                                  ),
                                ],
                              ),
                              if (concMgPerMl != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.teal.shade200),
                                  ),
                                  child: Text(
                                    '💡 Active Concentration: ${concMgPerMl.toStringAsFixed(1)} mg/ml ${concUnit == "%" ? "(from $rawConcVal% × 10)" : ""}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal.shade800),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
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
                                    child: TextField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: thresholdCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Reorder At *', suffixText: 'units'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // ══ STEP 1: DOSING RATE & SAFETY ══
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Step 2: Dosing Rate & Withdrawal Safety', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                              const SizedBox(height: 10),
                              const Text('Active Ingredient Rate (mg / kg bodyweight)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  ChoiceChip(
                                    label: const Text('0.2 mg/kg (Ivermectin)'),
                                    selected: selectedDosagePreset == '0.2mg_kg',
                                    onSelected: (sel) {
                                      if (sel) {
                                        setStateDialog(() {
                                          selectedDosagePreset = '0.2mg_kg';
                                          dosageMlCtrl.text = '0.2';
                                        });
                                      }
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('7.5 mg/kg (Levamisole)'),
                                    selected: selectedDosagePreset == '7.5mg_kg',
                                    onSelected: (sel) {
                                      if (sel) {
                                        setStateDialog(() {
                                          selectedDosagePreset = '7.5mg_kg';
                                          dosageMlCtrl.text = '7.5';
                                        });
                                      }
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('10 mg/kg (Albendazole)'),
                                    selected: selectedDosagePreset == '10mg_kg',
                                    onSelected: (sel) {
                                      if (sel) {
                                        setStateDialog(() {
                                          selectedDosagePreset = '10mg_kg';
                                          dosageMlCtrl.text = '10';
                                        });
                                      }
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('20 mg/kg (LA Oxytet)'),
                                    selected: selectedDosagePreset == '20mg_kg',
                                    onSelected: (sel) {
                                      if (sel) {
                                        setStateDialog(() {
                                          selectedDosagePreset = '20mg_kg';
                                          dosageMlCtrl.text = '20';
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: dosageMlCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Dosage Rate (mg / kg bodyweight) *',
                                  hintText: 'e.g. 7.5',
                                  suffixText: 'mg / kg',
                                ),
                                onChanged: (v) => setStateDialog(() {}),
                              ),
                              if (sampleActiveMg != null && sampleVolumeMl != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.check_circle_outline, color: AppColors.primary, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            'Formula Verification (42 kg animal sample)',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('• Active drug needed: 42 kg × $rateMgKg mg/kg = ${sampleActiveMg.toStringAsFixed(1)} mg', style: const TextStyle(fontSize: 11)),
                                      Text(
                                        '• Dose volume: ${sampleActiveMg.toStringAsFixed(1)} mg ÷ ${concMgPerMl!.toStringAsFixed(1)} mg/ml = ${sampleVolumeMl.toStringAsFixed(1)} $unit',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: milkWithdrawCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Milk Withdrawal (Days)'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: meatWithdrawCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Meat Withdrawal (Days)'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                textCapitalization: TextCapitalization.sentences,
                                controller: supplierCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Supplier Name',
                                  prefixIcon: Icon(Icons.local_shipping_outlined, size: 20),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
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
                                          builder: (context, child) => Theme(
                                            data: Theme.of(context).copyWith(useMaterial3: false),
                                            child: MediaQuery(
                                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                              child: child!,
                                            ),
                                          ),
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
                              ),
                            ],
                          ),

                          // ══ STEP 2: PRICING & STOCK ══
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Step 3: Wholesale Pricing & Opening Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: purchaseUnitType,
                                decoration: const InputDecoration(
                                  labelText: 'Purchase Package Type *',
                                  prefixIcon: Icon(Icons.all_inbox, size: 20),
                                ),
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
                                onChanged: (v) => setStateDialog(() => purchaseUnitType = v!),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: numPacksCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(labelText: 'Packs/Boxes Bought *'),
                                      onChanged: (v) => setStateDialog(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: costPackCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(labelText: 'Cost Per Pack (₦) *'),
                                      onChanged: (v) => setStateDialog(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                textCapitalization: TextCapitalization.sentences,
                                controller: unitsPackCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Size / Dose Units inside each Pack *',
                                  hintText: 'e.g. 500 if 500 ml per bottle',
                                  suffixText: unit,
                                ),
                                onChanged: (v) => setStateDialog(() {}),
                              ),
                              const SizedBox(height: 14),
                              // Financial & Inventory Summary Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.calculate_outlined, color: Colors.green, size: 18),
                                        SizedBox(width: 6),
                                        Text('Inventory & Valuation Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Calculated Dose Unit Cost:', style: TextStyle(fontSize: 12)),
                                        Text(
                                          '₦ ${computedUnitCost.toStringAsFixed(2)} / $unit',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade800),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Opening Stock Added:', style: TextStyle(fontSize: 12)),
                                        Text(
                                          '${computedStock.toStringAsFixed(1)} $unit',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Outlay Purchase Cost:', style: TextStyle(fontSize: 12)),
                                        Text(
                                          '₦ ${totalCost.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Modal Action Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (currentStep > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setStateDialog(() => currentStep--),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Back'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (currentStep < 2)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (currentStep == 0 && nameCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter Medication Name first'), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
                                setStateDialog(() => currentStep++);
                              },
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('Next'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (nameCtrl.text.isEmpty || numPacksCtrl.text.isEmpty || costPackCtrl.text.isEmpty || unitsPackCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
                                final dMg = double.tryParse(dosageMlCtrl.text) ?? 7.5;
                                final ratePerKg = dMg > 0 ? dMg : null;
                                final rateText = '$dMg mg/kg';

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
                                  'concentration': concDisplayText.isNotEmpty ? concDisplayText : null,
                                  'concentration_value': rawConcVal > 0 ? rawConcVal : null,
                                  'concentration_unit': concUnit,
                                  'concentration_mg_per_ml': concMgPerMl,
                                  'dosage_rate_per_kg': ratePerKg,
                                  'dosage_rate_text': rateText,
                                }));
                                Navigator.pop(dialogCtx);
                              },
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Save Medication'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStepTab({
    required int index,
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    final color = isActive
        ? AppColors.primary
        : (isCompleted ? Colors.teal : Colors.grey.shade600);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : (isCompleted ? Colors.teal.withValues(alpha: 0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : (isCompleted ? Colors.teal.withValues(alpha: 0.4) : Colors.grey.shade300),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCompleted ? Icons.check_circle : icon,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMedicationDialog(BuildContext context, LocalMedication med) {
    final nameCtrl = TextEditingController(text: med.name);
    final thresholdCtrl = TextEditingController(text: med.reorderThreshold.toStringAsFixed(0));
    final supplierCtrl = TextEditingController(text: med.supplier ?? '');
    final milkWithdrawCtrl = TextEditingController(text: med.milkWithdrawalDays.toString());
    final meatWithdrawCtrl = TextEditingController(text: med.meatWithdrawalDays.toString());
    final costPerUnitCtrl = TextEditingController(text: med.costPerUnit.toStringAsFixed(2));
    final concentrationCtrl = TextEditingController(text: med.concentration ?? '');

    double initMl = 1.0;
    double initKg = 50.0;
    if (med.dosageRatePerKg != null && med.dosageRatePerKg! > 0) {
      initMl = 1.0;
      initKg = (1.0 / med.dosageRatePerKg!).roundToDouble();
      if (initKg <= 0) initKg = 1.0;
    }
    final dosageMlCtrl = TextEditingController(text: initMl.toStringAsFixed(0));
    final dosageKgCtrl = TextEditingController(text: initKg.toStringAsFixed(0));

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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: category,
                            decoration: const InputDecoration(labelText: 'Category *'),
                            items: ['antibiotic', 'vaccine', 'dewormer', 'vitamin', 'supplement', 'other']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                                .toList(),
                            onChanged: (v) => setStateDialog(() => category = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: concentrationCtrl,
                            decoration: const InputDecoration(labelText: 'Concentration', hintText: 'e.g. 100 mg/ml or 10%'),
                          ),
                        ),
                      ],
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
                    const Text('Dosage Rate (Weight-Based Dosage Calculation)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dosageMlCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Administer ($unit)',
                              hintText: 'e.g. 1',
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('PER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: dosageKgCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Body Weight (kg)',
                              hintText: 'e.g. 50',
                            ),
                          ),
                        ),
                      ],
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
                            final picked = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
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
                              final dMl = double.tryParse(dosageMlCtrl.text) ?? 1.0;
                              final dKg = double.tryParse(dosageKgCtrl.text) ?? 50.0;
                              final ratePerKg = dKg > 0 ? (dMl / dKg) : null;
                              final rateText = '$dMl $unit / $dKg kg';

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
                                  'concentration': concentrationCtrl.text.trim().isNotEmpty ? concentrationCtrl.text.trim() : null,
                                  'dosage_rate_per_kg': ratePerKg,
                                  'dosage_rate_text': rateText,
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
                  'weight': (isMap ? a['weight'] : a.weight) != null ? double.tryParse((isMap ? a['weight'] : a.weight).toString()) : null,
                });
              }
            }

            return StatefulBuilder(
              builder: (ctx, setDialogState) {
                final matchMed = medications.firstWhere((m) => m.id == selectedMedId);
                final selAnimal = activeAnimals.firstWhere((a) => a['id'] == selectedAnimalId, orElse: () => {});
                final double? animWeight = selAnimal['weight'] != null ? double.tryParse(selAnimal['weight'].toString()) : null;
                
                double rateMgKg = matchMed.dosageRatePerKg ?? 0.0;
                if (rateMgKg <= 0 && matchMed.dosageRateText != null) {
                  final rateMatch = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(matchMed.dosageRateText!);
                  if (rateMatch != null) {
                    rateMgKg = double.tryParse(rateMatch.group(1)!) ?? 0.0;
                  }
                }

                DosageResult? doseCalc;
                if (animWeight != null && animWeight > 0 && rateMgKg > 0) {
                  doseCalc = DosageCalculator.calculate(
                    weightKg: animWeight,
                    dosageRatePerKg: rateMgKg,
                    concentrationValue: matchMed.concentrationValue,
                    concentrationUnit: matchMed.concentrationUnit,
                    concentrationMgPerMl: matchMed.concentrationMgPerMl,
                    medicationUnit: matchMed.unit,
                    concentrationText: matchMed.concentration,
                  );

                  if (doseCtrl.text.isEmpty && doseCalc.volumeToAdminister != null && doseCalc.volumeToAdminister! > 0) {
                    doseCtrl.text = doseCalc.volumeToAdminister!.toStringAsFixed(1);
                  }
                }

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
                            final wText = a['weight'] != null ? ' - ${a['weight']}kg' : '';
                            return DropdownMenuItem(value: a['id'] as String, child: Text('Tag ${a['tag']} (${a['species']}$wText)'));
                          }).toList(),
                          onChanged: (v) => setDialogState(() {
                            selectedAnimalId = v;
                            doseCtrl.clear();
                          }),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: selectedMedId,
                          decoration: const InputDecoration(labelText: 'Administered Drug *'),
                          isExpanded: true,
                          items: medications.map((m) {
                            final conc = m.concentration != null ? ' (${m.concentration})' : '';
                            return DropdownMenuItem(value: m.id, child: Text('${m.name}$conc'));
                          }).toList(),
                          onChanged: (v) => setDialogState(() {
                            selectedMedId = v;
                            doseCtrl.clear();
                          }),
                        ),
                        if (doseCalc != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '💡 Smart Calculated Dosage for #${selAnimal['tag']} (${animWeight}kg):',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '• Active drug needed: $animWeight kg × ${rateMgKg.toStringAsFixed(1)} mg/kg = ${doseCalc.activeMgNeeded.toStringAsFixed(1)} mg',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                if (doseCalc.volumeToAdminister != null && doseCalc.volumeToAdminister! > 0)
                                  Text(
                                    '• Recommended Dose: ${doseCalc.volumeToAdminister!.toStringAsFixed(1)} ${doseCalc.unit}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
                              ],
                            ),
                          ),
                        ],
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
