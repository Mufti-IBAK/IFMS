import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/brooding_pdf_export_service.dart';
import 'poultry_repository.dart';

class BroodingBatchProfileScreen extends StatefulWidget {
  final LocalBroodingBatche batch;
  const BroodingBatchProfileScreen({super.key, required this.batch});

  @override
  State<BroodingBatchProfileScreen> createState() => _BroodingBatchProfileScreenState();
}

class _BroodingBatchProfileScreenState extends State<BroodingBatchProfileScreen> {
  final _repo = sl<PoultryRepository>();
  late LocalBroodingBatche _currentBatch;
  List<LocalBroodingLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentBatch = widget.batch;
    _refreshBrooderData();
  }

  Future<void> _refreshBrooderData() async {
    setState(() => _loading = true);
    final latest = await (_repo.db.select(_repo.db.localBroodingBatches)..where((t) => t.id.equals(widget.batch.id))).getSingleOrNull();
    final logsList = await _repo.getBroodingLogs(widget.batch.id);
    if (mounted) {
      setState(() {
        if (latest != null) _currentBatch = latest;
        _logs = logsList;
        _loading = false;
      });
    }
  }

  double get _totalFeedCost => _logs.fold(0.0, (sum, l) => sum + l.feedCost);
  double get _totalMedCost => _logs.fold(0.0, (sum, l) => sum + l.medicationCost);
  double get _totalAccumulatedCost => _currentBatch.initialChickCost + _totalFeedCost + _totalMedCost;

  Future<void> _exportPdf() async {
    try {
      await BroodingPdfExportService.exportBroodingBatchPdf(
        batch: _currentBatch,
        logs: _logs,
        totalAccumulatedCost: _totalAccumulatedCost,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  int get _ageDays => DateTime.now().difference(_currentBatch.startDate).inDays;

  int get _targetDays {
    final diff = _currentBatch.targetGraduationDate.difference(_currentBatch.startDate).inDays;
    return diff > 0 ? diff : 28;
  }

  bool get _canGraduate {
    final remainingDays = _targetDays - _ageDays;
    return remainingDays <= 3;
  }

  double get _displayTemp {
    for (var l in _logs) {
      if (l.temperatureCelsius != null && l.temperatureCelsius! > 0) {
        return l.temperatureCelsius!;
      }
    }
    return _currentBatch.initialTemperatureCelsius;
  }

  bool get _hasLoggedTemp {
    return _logs.any((l) => l.temperatureCelsius != null && l.temperatureCelsius! > 0);
  }

  // Temperature target helper based on chick age
  double get _recommendedTemp {
    final week = (_ageDays / 7).floor() + 1;
    if (week <= 1) return 33.0; // Week 1: 32-34°C
    if (week == 2) return 30.0; // Week 2: 29-31°C
    if (week == 3) return 27.0; // Week 3: 26-28°C
    return 24.0;               // Week 4+: 23-25°C
  }

  @override
  Widget build(BuildContext context) {
    final b = _currentBatch;
    final totalLoss = b.initialCount - b.currentCount;
    final mortalityPct = b.initialCount > 0 ? (totalLoss / b.initialCount * 100) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Brooder Pen ${b.penName} (#${b.batchNumber})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF Report',
            onPressed: _exportPdf,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshBrooderData),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top KPI Summary Card
                Container(
                  color: Colors.purple.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${b.breed ?? "Chicks"} (Age: $_ageDays Days / ${_ageDays ~/ 7} Wks)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                              ),
                              Text('Started: ${DateFormat('MMM dd, yyyy').format(b.startDate)} | Rec. Target: ${_recommendedTemp.toStringAsFixed(0)}°C'),
                            ],
                          ),
                          Chip(
                            label: Text(b.status.toUpperCase()),
                            backgroundColor: b.status == 'brooding' ? Colors.purple.shade100 : Colors.grey.shade300,
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: b.status == 'brooding' ? Colors.purple.shade900 : Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _statBox('CHICK COUNT', '${b.currentCount} / ${b.initialCount}', Icons.flutter_dash, Colors.purple),
                          const SizedBox(width: 8),
                          _statBox(
                            _hasLoggedTemp ? 'LIVE TEMP' : 'INITIAL TEMP',
                            '${_displayTemp.toStringAsFixed(1)}°C',
                            Icons.thermostat,
                            Colors.deepOrange,
                          ),
                          const SizedBox(width: 8),
                          _statBox('MORTALITY', '${mortalityPct.toStringAsFixed(1)}%', Icons.heart_broken, mortalityPct > 5 ? Colors.red : Colors.green),
                          const SizedBox(width: 8),
                          _statBox('ACCUM. COST', '₦${_totalAccumulatedCost.toStringAsFixed(0)}', Icons.payments, Colors.teal),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.add_circle, color: Colors.white, size: 18),
                              label: const Text('Log Daily Temp & Feed', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              onPressed: () => _showLogEntryDialog(context),
                            ),
                          ),
                          if (b.status == 'brooding') ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _canGraduate ? AppColors.primary : Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: Icon(_canGraduate ? Icons.school : Icons.lock, color: Colors.white, size: 18),
                                label: Text(
                                  _canGraduate ? 'Graduate to Main Flock' : 'Locked (${_targetDays - _ageDays}d Left)',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  if (!_canGraduate) {
                                    final unlockDay = _targetDays - 3;
                                    final remaining = _targetDays - _ageDays;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Graduation is locked until Day $unlockDay (when 3 days remain). Current age: $_ageDays of $_targetDays days ($remaining days remaining).'),
                                        backgroundColor: Colors.purple.shade800,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  _showGraduationDialog(context);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Daily Brooder Environmental & Health History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),

                // Brooder Logs List
                Expanded(
                  child: _logs.isEmpty
                      ? const Center(child: Text('No daily brooding entries logged yet. Tap "Log Daily Temp & Feed".'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _logs.length,
                          itemBuilder: (ctx, idx) {
                            final l = _logs[idx];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('yyyy-MM-dd HH:mm').format(l.logDate), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                        if (l.temperatureCelsius != null)
                                          Chip(
                                            avatar: const Icon(Icons.thermostat, size: 14, color: Colors.deepOrange),
                                            label: Text('${l.temperatureCelsius}°C (${l.heatingStatus ?? "Heat ON"})'),
                                            backgroundColor: Colors.deepOrange.shade50,
                                            padding: EdgeInsets.zero,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Starter Feed: ${l.starterFeedKg} kg (₦${l.feedCost}) | Loss: ${l.mortalityCount} deaths, ${l.cullCount} culls'),
                                    if (l.medicationGiven != null && l.medicationGiven!.isNotEmpty)
                                      Text('Medication/Vaccine: ${l.medicationGiven} (₦${l.medicationCost})', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                    if (l.notes != null && l.notes!.isNotEmpty)
                                      Text('Notes: ${l.notes}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _statBox(String label, String val, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: col),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 1),
            Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogEntryDialog(BuildContext context) async {
    final tempCtrl = TextEditingController();
    final feedKgCtrl = TextEditingController();
    final feedCostCtrl = TextEditingController(text: '0');
    final commercialFeedNameCtrl = TextEditingController();
    final mortCtrl = TextEditingController(text: '0');
    
    // Vaccine Separate Fields
    bool isVaccineGiven = false;
    final vaccineNameCtrl = TextEditingController();
    final vaccineCostCtrl = TextEditingController(text: '0');

    // Medication Pharmacy Fields
    final medDoseCtrl = TextEditingController(text: '1.0');
    final medCostCtrl = TextEditingController(text: '0');
    final weightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String heatStatus = 'active';

    String feedCategoryType = 'formulated'; // 'formulated' or 'commercial'
    LocalFeedFormula? selectedFormula;
    LocalFeedItem? selectedCommercialFeed;
    LocalMedication? selectedPharmacyMed;

    final db = _repo.db;
    final availableFormulas = await db.select(db.localFeedFormulas).get();
    final availableCommercialFeeds = await (db.select(db.localFeedItems)
      ..where((t) => t.category.equals('feed'))).get();
    final availableMeds = await db.select(db.localMedications).get();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          void updateFormulatedCost() {
            if (selectedFormula != null) {
              final kg = double.tryParse(feedKgCtrl.text.trim()) ?? 0.0;
              final total = kg * 650.0; // Estimated ₦650/kg for in-house starter formula
              feedCostCtrl.text = total.toStringAsFixed(2);
            }
          }

          void updateCommercialCost() {
            if (selectedCommercialFeed != null) {
              final kg = double.tryParse(feedKgCtrl.text.trim()) ?? 0.0;
              final price = selectedCommercialFeed!.costPerKg > 0
                  ? selectedCommercialFeed!.costPerKg
                  : selectedCommercialFeed!.costPerUnit;
              final total = kg * price;
              feedCostCtrl.text = total.toStringAsFixed(2);
            }
          }

          void updateMedicationCost() {
            if (selectedPharmacyMed != null) {
              final dose = double.tryParse(medDoseCtrl.text.trim()) ?? 1.0;
              final total = dose * selectedPharmacyMed!.costPerUnit;
              medCostCtrl.text = total.toStringAsFixed(2);
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 16, right: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log Daily Brooder Entry', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.purple)),
                  const SizedBox(height: 12),

                  // 1. Temp & Heater Status
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tempCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Brooder Temp (°C)', hintText: 'e.g. 33.5', prefixIcon: Icon(Icons.thermostat)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: heatStatus,
                          decoration: const InputDecoration(labelText: 'Heater Status'),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Heater ON')),
                            DropdownMenuItem(value: 'off', child: Text('Heater OFF')),
                            DropdownMenuItem(value: 'adjusted', child: Text('Adjusted')),
                          ],
                          onChanged: (v) => setSheetState(() => heatStatus = v ?? 'active'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Feed Type Selector (Formulated vs Commercial Market)
                  const Text('Starter Feed Source / Category *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('In-House Formulated Feed', style: TextStyle(fontSize: 11)),
                          selected: feedCategoryType == 'formulated',
                          selectedColor: Colors.purple.shade100,
                          onSelected: (val) {
                            if (val) setSheetState(() => feedCategoryType = 'formulated');
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Pre-Formulated (Market)', style: TextStyle(fontSize: 11)),
                          selected: feedCategoryType == 'commercial',
                          selectedColor: Colors.teal.shade100,
                          onSelected: (val) {
                            if (val) setSheetState(() => feedCategoryType = 'commercial');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (feedCategoryType == 'formulated') ...[
                    if (availableFormulas.isNotEmpty) ...[
                      DropdownButtonFormField<LocalFeedFormula>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select Formulated Feed *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.rice_bowl, color: Colors.purple),
                        ),
                        value: selectedFormula,
                        items: availableFormulas.map((f) {
                          return DropdownMenuItem(
                            value: f,
                            child: Text('${f.name} (Stock: ${f.currentStock} kg)'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setSheetState(() {
                            selectedFormula = val;
                            updateFormulatedCost();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ] else ...[
                    if (availableCommercialFeeds.isNotEmpty) ...[
                      DropdownButtonFormField<LocalFeedItem>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select Commercial Feed Item *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.store, color: Colors.teal),
                        ),
                        value: selectedCommercialFeed,
                        items: availableCommercialFeeds.map((cf) {
                          final price = cf.costPerKg > 0 ? cf.costPerKg : cf.costPerUnit;
                          return DropdownMenuItem(
                            value: cf,
                            child: Text('${cf.name} (Stock: ${cf.currentStock} kg | ₦${price.toStringAsFixed(0)}/kg)'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setSheetState(() {
                            selectedCommercialFeed = val;
                            if (val != null) {
                              commercialFeedNameCtrl.text = val.name;
                            }
                            updateCommercialCost();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: commercialFeedNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Commercial Feed Brand / Name',
                        hintText: 'e.g. TopFeeds Starter Crumbles',
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: feedKgCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Feed Consumed (kg)', prefixIcon: Icon(Icons.grass)),
                          onChanged: (_) {
                            if (feedCategoryType == 'formulated') {
                              updateFormulatedCost();
                            } else {
                              updateCommercialCost();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: feedCostCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Total Feed Cost (₦)', prefixIcon: Icon(Icons.payments)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Separate Vaccine Entry
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Vaccine Administered Today?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                        value: isVaccineGiven,
                        onChanged: (val) {
                          setSheetState(() => isVaccineGiven = val ?? false);
                        },
                      ),
                    ),
                  ),
                  if (isVaccineGiven) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: vaccineNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Vaccine Name / Type *',
                              hintText: 'e.g. Gumboro IBD / ND Lasota',
                              prefixIcon: Icon(Icons.vaccines, color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: vaccineCostCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Amount Spent to Buy (₦) *',
                              hintText: 'e.g. 2500',
                              prefixIcon: Icon(Icons.payments, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // 4. Separate Pharmacy Medication Picker & Auto Cost Calculation
                  const Text('Pharmacy Medication Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  if (availableMeds.isNotEmpty) ...[
                    DropdownButtonFormField<LocalMedication>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Select Drug from Pharmacy Inventory',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.local_pharmacy, color: Colors.teal),
                      ),
                      value: selectedPharmacyMed,
                      items: availableMeds.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text('${m.name} (Stock: ${m.currentStock} ${m.unit} | ₦${m.costPerUnit.toStringAsFixed(0)}/${m.unit})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() {
                          selectedPharmacyMed = val;
                          updateMedicationCost();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: medDoseCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Dose / Quantity (${selectedPharmacyMed?.unit ?? "units"})',
                              prefixIcon: const Icon(Icons.numbers, color: Colors.teal),
                            ),
                            onChanged: (_) => updateMedicationCost(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: medCostCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Med Cost (₦) (Auto)',
                              prefixIcon: Icon(Icons.payments, color: Colors.teal),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No medications currently found in Pharmacy Inventory. You can add drugs in the Pharmacy module.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: mortCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Chick Mortality', prefixIcon: Icon(Icons.heart_broken, color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Avg Chick Weight (g)', prefixIcon: Icon(Icons.scale)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Brooder Notes / Observations')),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('SAVE BROODER ENTRY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final totalMedCost = (double.tryParse(medCostCtrl.text.trim()) ?? 0.0) +
                            (isVaccineGiven ? (double.tryParse(vaccineCostCtrl.text.trim()) ?? 0.0) : 0.0);

                        String medGivenSummary = '';
                        if (isVaccineGiven && vaccineNameCtrl.text.trim().isNotEmpty) {
                          medGivenSummary += 'Vaccine: ${vaccineNameCtrl.text.trim()} (₦${vaccineCostCtrl.text.trim()})';
                        }
                        if (selectedPharmacyMed != null) {
                          if (medGivenSummary.isNotEmpty) {
                            medGivenSummary += ' | ';
                          }
                          medGivenSummary += 'Med: ${selectedPharmacyMed!.name} (${medDoseCtrl.text.trim()} ${selectedPharmacyMed!.unit})';
                        }

                        final payload = {
                          'brooding_batch_id': _currentBatch.id,
                          'log_date': DateTime.now().toIso8601String(),
                          'temperature_celsius': tempCtrl.text.trim().isNotEmpty ? double.tryParse(tempCtrl.text.trim()) : null,
                          'heating_status': heatStatus,
                          'formula_id': selectedFormula?.id,
                          'feed_item_id': selectedCommercialFeed?.id,
                          'starter_feed_kg': double.tryParse(feedKgCtrl.text.trim()) ?? 0.0,
                          'feed_cost': double.tryParse(feedCostCtrl.text.trim()) ?? 0.0,
                          'mortality_count': int.tryParse(mortCtrl.text.trim()) ?? 0,
                          'medication_id': selectedPharmacyMed?.id,
                          'medication_dose': double.tryParse(medDoseCtrl.text.trim()) ?? 1.0,
                          'medication_given': medGivenSummary,
                          'medication_cost': totalMedCost,
                          'average_weight_grams': weightCtrl.text.trim().isNotEmpty ? double.tryParse(weightCtrl.text.trim()) : null,
                          'notes': notesCtrl.text.trim(),
                        };
                        await _repo.logBroodingEntry(payload);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          _refreshBrooderData();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGraduationDialog(BuildContext context) {
    final batchNumCtrl = TextEditingController(text: 'FL-${_currentBatch.batchNumber}');
    final houseCtrl = TextEditingController(text: 'Main House Pen 1');
    String selectedType = 'layer';

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Graduate & Transfer to Main Flock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transferring ${_currentBatch.currentCount} chicks to Main Poultry Flock.\nTotal Accumulated Brooder Cost: ₦${_totalAccumulatedCost.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(controller: batchNumCtrl, decoration: const InputDecoration(labelText: 'Target Flock Batch #')),
            const SizedBox(height: 8),
            TextField(controller: houseCtrl, decoration: const InputDecoration(labelText: 'Target House/Pen Name')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(labelText: 'Flock Purpose / Type'),
              items: const [
                DropdownMenuItem(value: 'layer', child: Text('Layers')),
                DropdownMenuItem(value: 'broiler', child: Text('Broilers')),
                DropdownMenuItem(value: 'cockerel', child: Text('Cockerels')),
                DropdownMenuItem(value: 'noiler', child: Text('Noilers')),
              ],
              onChanged: (v) => selectedType = v ?? 'layer',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Confirm Graduation'),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);
              final payload = {
                'batch_number': batchNumCtrl.text.trim(),
                'house_name': houseCtrl.text.trim(),
                'batch_type': selectedType,
              };
              await _repo.graduateBroodingBatchToMainFlock(_currentBatch.id, payload);
              if (dCtx.mounted) {
                Navigator.pop(dCtx);
              }
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Chicks successfully graduated to Main Poultry Flock!'), backgroundColor: Colors.green),
                );
                nav.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
