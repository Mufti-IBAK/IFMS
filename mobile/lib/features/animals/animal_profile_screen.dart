import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import '../breeding/breeding_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/report_service.dart';
import '../finance/finance_repository.dart';
import 'animals_repository.dart';
import 'animals_bloc.dart';
import 'package:ifms_mobile/core/widgets/animal_silhouette.dart';
import '../../core/widgets/error_display.dart';
import 'widgets/medical_report_sheet.dart';

class AnimalProfileScreen extends StatefulWidget {
  final dynamic animal;

  const AnimalProfileScreen({super.key, required this.animal});

  @override
  State<AnimalProfileScreen> createState() => _AnimalProfileScreenState();
}

class _AnimalProfileScreenState extends State<AnimalProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFmt = NumberFormat.currency(symbol: '₦ ', decimalDigits: 2);

  // Futures for child histories
  late Future<List<LocalMilkRecord>> _milkRecordsFuture;
  late Future<List<Map<String, dynamic>>> _feedLogsFuture;
  late Future<List<Map<String, dynamic>>> _medRecordsFuture;
  late Future<List<dynamic>> _breedingEventsFuture;

  double _totalMilkLiters = 0.0;
  double _avgMilkLiters = 0.0;
  bool _hasActiveWithdrawal = false;

  // Resolved attributes
  late String _id;
  late String _tagId;
  late String _species;
  late String _sex;
  DateTime? _dateOfBirth;
  late String _breed;
  late String _status;
  late String _liveStatus;
  late String? _imagePath;
  late String? _color;
  late String? _uniqueMarks;
  late String? _purpose;
  late String? _pedigreeType;
  late String? _vaccinationStatus;
  late String? _dewormingStatus;
  late dynamic _weight;

  @override
  void initState() {
    super.initState();
    // Resolve dynamic properties
    final animal = widget.animal as LocalAnimal;
    _id = animal.id.toString();
    _tagId = animal.tagId.toString();
    _species = animal.species.toString();
    _sex = animal.sex.toString();
    
    _dateOfBirth = animal.dateOfBirth;
    
    _breed = (animal.breed ?? 'Unknown').toString();
    _status = (animal.currentReproductiveStatus).toString();
    _liveStatus = animal.status.toString();
    _imagePath = animal.imagePath;
    _color = animal.color;
    _uniqueMarks = animal.uniqueMarks;
    _purpose = animal.purpose;
    _pedigreeType = animal.pedigreeType;
    _vaccinationStatus = animal.vaccinationStatus;
    _dewormingStatus = animal.dewormingStatus;
    _weight = animal.weight;

    final isCow = _species.toLowerCase() == 'cow' || _species.toLowerCase() == 'bovine';
    final showProduction = isCow && _sex.toLowerCase() == 'female';
    final tabLength = showProduction ? 6 : 5;
    _tabController = TabController(length: tabLength, vsync: this);
    _refreshAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshAllData() {
    final db = sl<LocalDatabase>();

    setState(() {
      // 1. Milk Records
      _milkRecordsFuture = (db.select(db.localMilkRecords)
            ..where((t) => t.animalId.equals(_id))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.recordDate, mode: drift.OrderingMode.desc)]))
          .get()
          .then((records) {
        if (records.isNotEmpty) {
          double total = 0.0;
          for (var r in records) {
            total += r.quantityLiters;
          }
          setState(() {
            _totalMilkLiters = total;
            _avgMilkLiters = total / records.length;
          });
        }
        return records;
      });

      // 2. Feeding logs
      _feedLogsFuture = Future.wait([
        (db.select(db.localFeedConsumptionLogs)
              ..where((t) => t.animalId.equals(_id))
              ..orderBy([(t) => drift.OrderingTerm(expression: t.logDate, mode: drift.OrderingMode.desc)]))
            .get(),
        db.select(db.localFeedItems).get(),
      ]).then((results) {
        final logs = results[0] as List<LocalFeedConsumptionLog>;
        final items = results[1] as List<LocalFeedItem>;
        final itemMap = {for (var i in items) i.id: i};


        


        return logs.map((l) {
          final itemName = itemMap[l.feedItemId]?.name ?? 'Unknown Feed';
          return {
            'date': l.logDate,
            'feed_name': itemName,
            'qty': l.quantityKg,
            'notes': l.notes ?? 'Daily consumption',
          };
        }).toList();
      });

      // 3. Medical Records
      _medRecordsFuture = Future.wait([
        (db.select(db.localAnimalMedicalRecords)
              ..where((t) => t.animalId.equals(_id))
              ..orderBy([(t) => drift.OrderingTerm(expression: t.treatmentDate, mode: drift.OrderingMode.desc)]))
            .get(),
        db.select(db.localMedications).get(),
      ]).then((results) {
        final logs = results[0] as List<LocalAnimalMedicalRecord>;
        final catalog = results[1] as List<LocalMedication>;
        final medMap = {for (var m in catalog) m.id: m};

        _hasActiveWithdrawal = logs.any((r) => r.withdrawalEndDate != null && r.withdrawalEndDate!.isAfter(DateTime.now()));




        return logs.map((l) {
          final med = medMap[l.medicationId];
          return {
            'date': l.treatmentDate,
            'medication_name': med?.name ?? 'Unknown drug',
            'unit': med?.unit ?? 'units',
            'dose': l.administeredDose,
            'condition': l.diagnosedCondition,
            'cost': l.cost,
            'notes': l.notes ?? '',
            'withdrawal': l.withdrawalEndDate,
          };
        }).toList();
      });

      // 4. Breeding Events from Local DB
      _breedingEventsFuture = sl<BreedingRepository>().getBreedingEventsForAnimal(_id).then((events) {
        return events.map((e) => {
          'id': e.id,
          'animal_id': e.animalId,
          'event_type': e.eventType,
          'event_date': e.eventDate.toIso8601String(),
          'sire_id': e.sireId,
          'result': e.result,
          'notes': e.notes,
          'payload': e.payload,
        }).toList();
      });
    });
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? age = _dateOfBirth != null ? DateTime.now().difference(_dateOfBirth!).inDays : null;
    final ageString = age != null ? (age > 365 ? '${(age / 365).toStringAsFixed(1)} Yrs' : '$age Days') : 'Unknown';
    final speciesStr = _species[0].toUpperCase() + _species.substring(1).toLowerCase();
    final isCow = _species.toLowerCase() == 'cow' || _species.toLowerCase() == 'bovine';

    return Scaffold(
      appBar: AppBar(
        title: Text('${speciesStr.toUpperCase()} #$_tagId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services, color: AppColors.error),
            tooltip: 'New Medical Report',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => MedicalReportSheet(animal: widget.animal),
              ).then((_) => _refreshAllData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF Report',
            onPressed: () async {
              final milkList = await _milkRecordsFuture;
              final feedList = await _feedLogsFuture;
              final medList = await _medRecordsFuture;
              final breedList = await _breedingEventsFuture;
              await ReportService.generateAnimalProfileReport(
                animal: widget.animal,
                milkRecords: milkList,
                feedLogs: feedList,
                medRecords: medList,
                breedingEvents: breedList,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditAnimalSheet(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.secondary,
          tabs: [
            const Tab(icon: Icon(Icons.info_outline), text: 'Info'),
            if (isCow && _sex.toLowerCase() == 'female')
              const Tab(icon: Icon(Icons.water_drop_outlined), text: 'Production'),
            const Tab(icon: Icon(Icons.lunch_dining_outlined), text: 'Feed'),
            const Tab(icon: Icon(Icons.medical_services_outlined), text: 'Health'),
            const Tab(icon: Icon(Icons.favorite_border), text: 'Breeding'),
            const Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Schedules'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(ageString, speciesStr),
          if (isCow && _sex.toLowerCase() == 'female')
            _buildProductionTab(),
          _buildFeedTab(),
          _buildHealthTab(),
          _buildBreedingTab(),
          _buildSchedulesTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab(String ageString, String speciesStr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo & Quick Stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imagePath == null
                  ? AnimalSilhouette(
                      species: _species,
                      sex: _sex,
                      size: 90,
                    )
                  : Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _sex.toLowerCase() == 'female' ? Colors.pink.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: _imagePath!.startsWith('http')
                              ? NetworkImage(_imagePath!) as ImageProvider
                              : _imagePath!.startsWith('/uploads')
                                  ? NetworkImage('${ApiClient.baseUrl.replaceAll('/api/v1', '')}$_imagePath')
                                  : FileImage(File(_imagePath!)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                    ),

              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tag ID: $_tagId',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      '$speciesStr • $_breed',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _liveStatus == 'active' ? Colors.green.shade50 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _liveStatus.toUpperCase(),
                        style: TextStyle(
                          color: _liveStatus == 'active' ? Colors.green : Colors.grey.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_hasActiveWithdrawal) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACTIVE WITHDRAWAL WARNING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orange)),
                        Text('This animal is currently undergoing drug withdrawal. Do not sell its milk or meat.', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          FutureBuilder<Map<String, dynamic>>(
            future: sl<FinanceRepository>().getAnimalFinancialSummary(_id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final data = snapshot.data ?? {};
              final netProfit = double.tryParse(data['net_profit']?.toString() ?? '0.0') ?? 0.0;
              final totalCosts = double.tryParse(data['total_costs']?.toString() ?? '0.0') ?? 0.0;
              final directRev = double.tryParse(data['direct_revenue']?.toString() ?? '0.0') ?? 0.0;
              
              final isProfitable = netProfit >= 0;
              final cardColor = isProfitable ? Colors.green.shade50 : Colors.red.shade50;
              final borderColor = isProfitable ? Colors.green.shade200 : Colors.red.shade200;
              final textColor = isProfitable ? Colors.green.shade900 : Colors.red.shade900;

              return Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderColor, width: 0.5),
                ),
                child: InkWell(
                  onTap: () => _showFinancialCostCenterBottomSheet(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isProfitable ? Colors.green : Colors.red,
                              child: const Icon(Icons.payments_outlined, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FINANCIAL INSIGHTS (NET PROFIT)', 
                                    style: TextStyle(fontSize: 10, color: isProfitable ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _currencyFmt.format(netProfit),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: isProfitable ? Colors.green : Colors.red),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Revenue: ${_currencyFmt.format(directRev)}',
                              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Costs: ${_currencyFmt.format(totalCosts)}',
                              style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view complete cost center ledger & depreciation',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
          const SizedBox(height: 20),

          // Core Specs Grid
          const Text('Animal Profile Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
          const Divider(),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            children: [
              _infoTile('Sex / Gender', _sex.toUpperCase(), Icons.transgender, Colors.blue),
              _infoTile('Age', ageString, Icons.hourglass_empty, Colors.teal),
              _infoTile('Weight', '${_weight ?? "N/A"} kg', Icons.scale, Colors.purple),
              _infoTile('Purpose', _purpose?.toUpperCase() ?? 'GENERAL', Icons.workspace_premium_outlined, Colors.amber),
              _infoTile('Reproductive Status', _status.toUpperCase(), Icons.favorite_border, Colors.pink),
              _infoTile('Color', _color ?? 'N/A', Icons.color_lens_outlined, Colors.indigo),
              _infoTile('Pedigree Type', _pedigreeType ?? 'Commercial', Icons.history_edu, Colors.blueGrey),
              _infoTile('Unique Marks', _uniqueMarks ?? 'None', Icons.notes_outlined, Colors.grey),
            ],
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  void _showFinancialCostCenterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        final financeRepo = sl<FinanceRepository>();
        return FutureBuilder<Map<String, dynamic>>(
          future: financeRepo.getAnimalFinancialSummary(_id),
          builder: (builderCtx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return SizedBox(
                height: 350,
                child: ErrorDisplay(
                  error: snapshot.error ?? 'No data available',
                  onRetry: () {
                    // Force refresh by rebuilding the bottom sheet
                    (sheetCtx as Element).markNeedsBuild();
                  },
                ),
              );
            }

            final data = snapshot.data!;
            final directRev = double.tryParse(data['direct_revenue']?.toString() ?? '0.0') ?? 0.0;
            final feedCost = double.tryParse(data['feed_cost']?.toString() ?? '0.0') ?? 0.0;
            final healthCost = double.tryParse(data['health_cost']?.toString() ?? '0.0') ?? 0.0;
            final laborCost = double.tryParse(data['labor_cost']?.toString() ?? '0.0') ?? 0.0;
            final overhead = double.tryParse(data['allocated_overhead']?.toString() ?? '0.0') ?? 0.0;
            final totalCosts = double.tryParse(data['total_costs']?.toString() ?? '0.0') ?? 0.0;
            final netProfit = double.tryParse(data['net_profit']?.toString() ?? '0.0') ?? 0.0;

            final depr = data['depreciation'] as Map? ?? {};
            final bookVal = double.tryParse(depr['current_book_value']?.toString() ?? '0.0') ?? 0.0;
            final salvage = double.tryParse(depr['salvage_value']?.toString() ?? '0.0') ?? 0.0;
            final cumDepr = double.tryParse(depr['cumulative_depreciation']?.toString() ?? '0.0') ?? 0.0;
            final annualDepr = double.tryParse(depr['annual_depreciation']?.toString() ?? '0.0') ?? 0.0;
            final acquisition = double.tryParse(data['acquisition_cost']?.toString() ?? '0.0') ?? 0.0;
            final age = double.tryParse(depr['age_years']?.toString() ?? '0.0') ?? 0.0;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              builder: (scrollCtx, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_outlined, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'COST CENTER: TAG $_tagId',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Profitability margin card
                      Card(
                        color: netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: netProfit >= 0 ? Colors.green.shade200 : Colors.red.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('NET PROFIT MARGIN', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currencyFmt.format(netProfit),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: netProfit >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: netProfit >= 0 ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  netProfit >= 0 ? 'PROFITABLE' : 'UNECONOMIC',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Income & Expense Breakdown
                      const Text('LEDGER SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Divider(),
                      _rowVal('Direct Revenue', directRev, isIncome: true),
                      _rowVal('Direct Feed Cost', -feedCost),
                      _rowVal('Direct Treatment Cost', -healthCost),
                      _rowVal('Allocated Labor overhead', -laborCost),
                      _rowVal('Allocated General overhead', -overhead),
                      const Divider(),
                      _rowVal('Total Costs Outlay', -totalCosts, isBold: true),
                      const SizedBox(height: 20),

                      // Asset Valuation & Depreciation
                      const Text('ASSET DEPRECIATION LEDGER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Divider(),
                      _rowTextVal('Acquisition Price', _currencyFmt.format(acquisition)),
                      _rowTextVal('Asset Age', '${age.toStringAsFixed(1)} years'),
                      _rowTextVal('Depreciation Rate', '${_currencyFmt.format(annualDepr)}/yr'),
                      _rowTextVal('Cumulative Depreciation', _currencyFmt.format(cumDepr)),
                      _rowTextVal('Salvage Value (Floor)', _currencyFmt.format(salvage)),
                      const Divider(),
                      _rowTextVal('Current Book Value', _currencyFmt.format(bookVal), isBold: true),
                      const SizedBox(height: 20),
                      
                      // Transactions
                      const Text('TRANSACTION HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Divider(),
                      if (data['transactions'] == null || (data['transactions'] as List).isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No individual transactions logged.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (data['transactions'] as List).length,
                          itemBuilder: (ctx, index) {
                            final t = data['transactions'][index];
                            final isIncome = t['type'] == 'income';
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(t['category'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(
                                '${DateFormat('MMM dd, yyyy').format(DateTime.parse(t['date']))} • ${t['description'] ?? ""}',
                                style: const TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                _currencyFmt.format(t['amount'] ?? 0.0),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _rowVal(String label, double val, {bool isIncome = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            _currencyFmt.format(val),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : (val < 0 ? Colors.red : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowTextVal(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            val,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesTab() {
    final db = sl<LocalDatabase>();
    final tasksFuture = (db.select(db.localTasks)
          ..where((t) => t.id.like('rem_${_id}_%'))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.dueDate, mode: drift.OrderingMode.asc)]))
        .get();

    return FutureBuilder<List<LocalTask>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vaccination & Deworming Overview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
              ),
              const Divider(),
              const SizedBox(height: 12),
              _buildVaccineStatusWidget(),
              const SizedBox(height: 16),
              _buildDewormingStatusWidget(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showScheduleActionSheet('vaccination'),
                      icon: const Icon(Icons.vaccines, size: 18),
                      label: const Text('Vaccination'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showScheduleActionSheet('deworming'),
                      icon: const Icon(Icons.medication_liquid, size: 18),
                      label: const Text('Dewormer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Schedule Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  ),
                  TextButton.icon(
                    onPressed: () => _showEditAnimalSheet(),
                    icon: const Icon(Icons.edit_calendar, size: 16),
                    label: const Text('Manage', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_note, color: Colors.grey.shade400, size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'No upcoming reminders scheduled.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && task.status != 'completed';
                    
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isOverdue 
                              ? Colors.red.withValues(alpha: 0.3) 
                              : task.status == 'completed' 
                                  ? Colors.green.withValues(alpha: 0.3) 
                                  : Colors.grey.shade200,
                          width: 0.8,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOverdue 
                              ? Colors.red.shade50 
                              : task.status == 'completed' 
                                  ? Colors.green.shade50 
                                  : Colors.blue.shade50,
                          child: Icon(
                            task.status == 'completed' 
                                ? Icons.check_circle_outline 
                                : Icons.alarm, 
                            color: isOverdue 
                                ? Colors.red 
                                : task.status == 'completed' 
                                    ? Colors.green 
                                    : Colors.blue,
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            decoration: task.status == 'completed' ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          '${task.description ?? ""}\nDue: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : "No date"}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        isThreeLine: true,
                        trailing: Checkbox(
                          value: task.status == 'completed',
                          onChanged: (val) async {
                            final newStatus = val == true ? 'completed' : 'pending';
                            await (db.update(db.localTasks)..where((t) => t.id.equals(task.id))).write(
                              LocalTasksCompanion(status: drift.Value(newStatus)),
                            );
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductionTab() {
    return FutureBuilder<List<LocalMilkRecord>>(
      future: _milkRecordsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data!;
        if (records.isEmpty) {
          return const Center(child: Text('No milk records logged for this animal.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // KPI Summary Header
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text('Total Production', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('${_totalMilkLiters.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text('Average Production', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('${_avgMilkLiters.toStringAsFixed(1)} L/Session', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('MILKING JOURNAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (ctx, idx) {
                final r = records[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.water_drop, color: Colors.white, size: 16),
                    ),
                    title: Text('${r.quantityLiters.toStringAsFixed(1)} Liters (${r.milkingSession.toUpperCase()})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('yyyy-MM-dd').format(r.recordDate)),
                        if (r.fatPercentage != null || r.proteinPercentage != null)
                          Text('Fat: ${r.fatPercentage ?? "-"}% | Protein: ${r.proteinPercentage ?? "-"}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ]
                    ),
                    trailing: r.isWithdrawn
                        ? const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _feedLogsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data!;
        if (logs.isEmpty) {
          return const Center(child: Text('No feeding records logged.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (ctx, idx) {
            final l = logs[idx];
            final date = l['date'] as DateTime;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.lunch_dining, color: AppColors.primary, size: 16),
                ),
                title: Text('${l['qty']} kg of ${l['feed_name']}'),
                subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(date)} | ${l['notes']}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHealthTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _medRecordsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data!;
        if (logs.isEmpty) {
          return const Center(child: Text('No medical treatment logs recorded.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (ctx, idx) {
            final l = logs[idx];
            final date = l['date'] as DateTime;
            final withdrawal = l['withdrawal'] as DateTime?;
            final hasWithdrawal = withdrawal != null && withdrawal.isAfter(DateTime.now());

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
                          child: Text(
                            'Condition: ${l['condition']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Text(
                          _currencyFmt.format(l['cost']),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Drug: ${l['medication_name']} (${l['dose']} ${l['unit']})'),
                    const SizedBox(height: 4),
                    Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(date)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    if (l['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Remarks: ${l['notes']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                    if (withdrawal != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasWithdrawal ? Colors.orange.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: hasWithdrawal ? Colors.orange : Colors.green, width: 0.5),
                        ),
                        child: Text(
                          hasWithdrawal
                              ? 'Active Withdrawal Ends: ${DateFormat('yyyy-MM-dd').format(withdrawal)}'
                              : 'Withdrawal Ended: ${DateFormat('yyyy-MM-dd').format(withdrawal)}',
                          style: TextStyle(
                            color: hasWithdrawal ? Colors.orange.shade800 : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBreedingTab() {
    return FutureBuilder<List<dynamic>>(
      future: _breedingEventsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        
        int parity = 0;
        DateTime? lastParturition;
        DateTime? lastMating;
        bool hasDystocia = false;
        
        for (var e in events) {
          final type = e['event_type'].toString();
          final date = DateTime.parse(e['event_date'].toString());
          final payloadStr = e['payload']?.toString();
          Map<String, dynamic>? payload;
          if (payloadStr != null && payloadStr.isNotEmpty) {
            try {
              payload = jsonDecode(payloadStr);
            } catch (_) {}
          }
          
          if (type == 'birth') {
            final count = payload != null && payload['offspringCount'] != null ? int.parse(payload['offspringCount'].toString()) : 1;
            parity += count;
            if (lastParturition == null || date.isAfter(lastParturition)) {
              lastParturition = date;
            }
            if (payload != null) {
              final motherStatus = payload['motherStatus']?.toString().toLowerCase();
              if (motherStatus == 'dystocia' || motherStatus == 'assisted') {
                hasDystocia = true;
              }
            }
          }
          
          if (type == 'natural_mating' || type == 'ai') {
            if (lastMating == null || date.isAfter(lastMating)) {
              lastMating = date;
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Metrics Dashboard
            if (_sex.toLowerCase() == 'female') ...[
              const Text(
                'BREEDING METRICS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _infoTile('Parity/Total', parity.toString(), Icons.child_care, Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _infoTile('Last Birth', lastParturition != null ? DateFormat('yyyy-MM-dd').format(lastParturition) : 'None', Icons.calendar_month, Colors.blue)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _infoTile('Last Mating', lastMating != null ? DateFormat('yyyy-MM-dd').format(lastMating) : 'None', Icons.favorite, Colors.red)),
                  const SizedBox(width: 8),
                  Expanded(child: _infoTile('Dystocia', hasDystocia ? 'Yes' : 'No', Icons.warning_amber_rounded, hasDystocia ? Colors.orange : Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BREEDING HISTORY',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddBreedingDialog(context),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('Log Breeding', style: TextStyle(fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.grey, size: 36),
                      SizedBox(height: 8),
                      Text('No breeding events recorded.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: List.generate(events.length, (idx) {
                  final e = events[idx];
                  final eventType = e['event_type'].toString().replaceAll('_', ' ').toUpperCase();
                  final eventDate = DateTime.parse(e['event_date'].toString());
                  final result = e['result']?.toString() ?? '';
                  final notes = e['notes']?.toString() ?? '';

                  Map<String, dynamic>? payload;
                  final payloadStr = e['payload']?.toString();
                  if (payloadStr != null && payloadStr.isNotEmpty) {
                    try {
                      payload = jsonDecode(payloadStr);
                    } catch (_) {}
                  }

                  IconData icon = Icons.event;
                  Color iconColor = AppColors.primary;
                  if (eventType.contains('BIRTH')) {
                    icon = Icons.child_care;
                    iconColor = Colors.green;
                  } else if (eventType.contains('MATING') || eventType.contains('AI')) {
                    icon = Icons.favorite;
                    iconColor = Colors.pink;
                  } else if (eventType.contains('PREGNANCY')) {
                    icon = Icons.search;
                    iconColor = Colors.blue;
                  }

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Timeline track
                        SizedBox(
                          width: 32,
                          child: Column(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: iconColor, width: 1.5),
                                ),
                                child: Icon(icon, size: 14, color: iconColor),
                              ),
                              if (idx < events.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 1.5,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right details card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(eventType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: iconColor)),
                                        Text(DateFormat('yyyy-MM-dd').format(eventDate), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                    if (eventType == 'BIRTH' && payload != null) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Chip(label: Text('Qty: ${payload['offspringCount']}', style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                                          Chip(label: Text('Gender: ${payload['offspringGender']?.toString().toUpperCase()}', style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                                          Chip(label: Text('Health: ${payload['healthStatus']?.toString().toUpperCase()}', style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                                          Chip(label: Text('Mother: ${payload['motherStatus']?.toString().toUpperCase()}', style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                                        ],
                                      ),
                                    ],
                                    if (result.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text('Result: $result', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
                                    ],
                                    if (notes.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text('Notes: $notes', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

          ],
        );
      },
    );
  }

  Widget _buildVaccineStatusWidget() {
    final vacRaw = _vaccinationStatus ?? '';
    List<String> given = [];
    String? nextVac;
    String? nextDateStr;

    if (vacRaw.startsWith('{')) {
      try {
        final Map<String, dynamic> data = jsonDecode(vacRaw);
        if (data['given'] is List) {
          given = (data['given'] as List).map((e) => e.toString()).toList();
        }
        nextVac = data['next_vaccine'];
        if (data['next_date'] != null) {
          nextDateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(data['next_date'].toString()));
        }
      } catch (_) {}
    } else if (vacRaw.isNotEmpty) {
      given.add(vacRaw);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('VACCINATION LOG & SCHEDULE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            given.isEmpty ? 'No vaccinations recorded yet.' : 'Administered: ${given.join(", ")}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          if (nextVac != null && nextDateStr != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.alarm, color: Colors.teal, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Next Scheduled: $nextVac on $nextDateStr',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDewormingStatusWidget() {
    final dewormRaw = _dewormingStatus ?? '';
    String? lastDateStr;
    String? nextDateStr;
    String drug = 'None';
    bool isOverdue = false;

    if (dewormRaw.startsWith('{')) {
      try {
        final Map<String, dynamic> data = jsonDecode(dewormRaw);
        drug = data['drug'] ?? 'None';
        if (data['last_date'] != null) {
          lastDateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(data['last_date'].toString()));
        }
        if (data['next_date'] != null) {
          final next = DateTime.parse(data['next_date'].toString());
          nextDateStr = DateFormat('yyyy-MM-dd').format(next);
          isOverdue = next.isBefore(DateTime.now());
        }
      } catch (_) {}
    } else if (dewormRaw.isNotEmpty) {
      drug = dewormRaw;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOverdue ? Colors.red.shade200 : Colors.orange.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: isOverdue ? Colors.red : Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'DEWORMING STATUS & SCHEDULE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isOverdue ? Colors.red : Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Drug Used: $drug',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          if (lastDateStr != null) ...[
            const SizedBox(height: 4),
            Text('Last Dewormed: $lastDateStr', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
          if (nextDateStr != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.alarm_on, color: isOverdue ? Colors.red : Colors.teal, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Next Deworming: $nextDateStr ${isOverdue ? "(OVERDUE)" : ""}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }


  void _showScheduleActionSheet(String actionType) {
    final drugCtrl = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setStateSheet) {
          final isVaccine = actionType == 'vaccination';
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule Upcoming ${isVaccine ? 'Vaccination' : 'Dewormer'}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: drugCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: isVaccine ? 'Vaccine Name / Disease' : 'Deworming Drug',
                      hintText: isVaccine ? 'e.g., FMD Vaccine' : 'e.g., Ivermectin',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'No Date Selected'
                              : 'Due: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Pick Date'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (picked != null) {
                            setStateSheet(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVaccine ? AppColors.primary : Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (drugCtrl.text.isEmpty || selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a drug name and select a date.')),
                          );
                          return;
                        }

                        // Retrieve existing and merge
                        if (isVaccine) {
                          final vacRaw = _vaccinationStatus ?? '';
                          List<String> given = [];
                          if (vacRaw.startsWith('{')) {
                            try {
                              final Map<String, dynamic> data = jsonDecode(vacRaw);
                              if (data['given'] is List) {
                                given = (data['given'] as List).map((e) => e.toString()).toList();
                              }
                            } catch (_) {}
                          } else if (vacRaw.isNotEmpty) {
                            given.add(vacRaw);
                          }

                          context.read<AnimalsBloc>().add(UpdateAnimal(
                            _id,
                            {
                              'vaccination_status': jsonEncode({
                                'given': given,
                                'next_vaccine': drugCtrl.text.trim(),
                                'next_date': selectedDate!.toIso8601String(),
                              }),
                            },
                          ));
                        } else {
                          // Dewormer
                          final dewormRaw = _dewormingStatus ?? '';
                          DateTime? lastDeworm;
                          if (dewormRaw.startsWith('{')) {
                            try {
                              final Map<String, dynamic> data = jsonDecode(dewormRaw);
                              if (data['last_date'] != null) {
                                lastDeworm = DateTime.tryParse(data['last_date'].toString());
                              }
                            } catch (_) {}
                          }
                          
                          context.read<AnimalsBloc>().add(UpdateAnimal(
                            _id,
                            {
                              'deworming_status': jsonEncode({
                                'drug': drugCtrl.text.trim(),
                                'last_date': lastDeworm?.toIso8601String(),
                                'next_date': selectedDate!.toIso8601String(),
                              }),
                            },
                          ));
                        }

                        Navigator.pop(context);
                      },
                      child: const Text('Save Schedule'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditAnimalSheet() {
    final db = sl<LocalDatabase>();
    final tagController = TextEditingController(text: _tagId);
    final breedController = TextEditingController(text: _breed == 'Unknown' ? '' : _breed);
    final weightController = TextEditingController(text: _weight?.toString() ?? '');
    final colorController = TextEditingController(text: _color ?? '');
    final marksController = TextEditingController(text: _uniqueMarks ?? '');
    
    final List<String> selectedVaccines = [];
    String? nextVaccineToSchedule;
    DateTime? nextVaccineDate;
    
    DateTime? lastDewormDate;
    DateTime? nextDewormDate;
    final dewormingDrugController = TextEditingController();

    // Parse existing vaccination and deworming data
    final vacRaw = _vaccinationStatus ?? '';
    if (vacRaw.startsWith('{')) {
      try {
        final Map<String, dynamic> data = jsonDecode(vacRaw);
        if (data['given'] is List) {
          selectedVaccines.addAll((data['given'] as List).map((e) => e.toString()));
        }
        nextVaccineToSchedule = data['next_vaccine'];
        if (data['next_date'] != null) {
          nextVaccineDate = DateTime.tryParse(data['next_date'].toString());
        }
      } catch (_) {}
    } else if (vacRaw.isNotEmpty) {
      selectedVaccines.add(vacRaw);
    }

    final dewormRaw = _dewormingStatus ?? '';
    if (dewormRaw.startsWith('{')) {
      try {
        final Map<String, dynamic> data = jsonDecode(dewormRaw);
        if (data['last_date'] != null) {
          lastDewormDate = DateTime.tryParse(data['last_date'].toString());
        }
        if (data['next_date'] != null) {
          nextDewormDate = DateTime.tryParse(data['next_date'].toString());
        }
        dewormingDrugController.text = data['drug'] ?? '';
      } catch (_) {}
    } else if (dewormRaw.isNotEmpty) {
      dewormingDrugController.text = dewormRaw;
    }
    
    DateTime? selectedDob = _dateOfBirth;
    bool dobUnknown = _dateOfBirth == null;
    final estimatedAgeController = TextEditingController(text: '1');
    String estimatedAgeUnit = 'Years';

    String selectedSpecies = _species.toLowerCase();
    if (selectedSpecies == 'cow' || selectedSpecies == 'cattle') selectedSpecies = 'bovine';
    if (selectedSpecies == 'goat') selectedSpecies = 'caprine';
    if (selectedSpecies == 'sheep') selectedSpecies = 'ovine';
    if (selectedSpecies == 'pig') selectedSpecies = 'porcine';
    if (selectedSpecies == 'chicken' || selectedSpecies == 'poultry') selectedSpecies = 'avian';
    const validSpecies = ['bovine', 'caprine', 'ovine', 'porcine', 'avian'];
    if (!validSpecies.contains(selectedSpecies)) selectedSpecies = 'bovine';

    String selectedSex = _sex.toLowerCase();
    if (selectedSex != 'female' && selectedSex != 'male') selectedSex = 'female';

    String selectedPedigree = _pedigreeType?.toLowerCase() ?? 'pure';
    const validPedigrees = ['pure', 'cross', 'grading', 'commercial'];
    if (!validPedigrees.contains(selectedPedigree)) selectedPedigree = 'pure';

    String selectedPurpose = _purpose?.toLowerCase() ?? 'milk';
    const validPurposes = ['breeding', 'milk', 'meat', 'others'];
    if (!validPurposes.contains(selectedPurpose)) selectedPurpose = 'milk';

    String selectedReproductive = _status.toLowerCase();
    const validRepro = ['open', 'pregnant', 'lactating', 'dry', 'in_heat'];
    if (!validRepro.contains(selectedReproductive)) selectedReproductive = 'open';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setStateSheet) {
          final media = MediaQuery.of(context);
          final isFemale = selectedSex == 'female';

          Widget buildInputField({
            required String label,
            required Widget child,
          }) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outline),
                  ),
                  const SizedBox(height: 6),
                  child,
                ],
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: media.viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Edit Animal Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(textCapitalization: TextCapitalization.sentences, controller: tagController,
                    decoration: const InputDecoration(labelText: 'Tag ID / Identifier *', prefixIcon: Icon(Icons.tag)),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedSpecies,
                          decoration: const InputDecoration(labelText: 'Species *'),
                          items: const [
                            DropdownMenuItem(value: 'bovine', child: Text('Cattle (Bovine)')),
                            DropdownMenuItem(value: 'caprine', child: Text('Goats (Caprine)')),
                            DropdownMenuItem(value: 'ovine', child: Text('Sheep (Ovine)')),
                            DropdownMenuItem(value: 'porcine', child: Text('Pigs (Porcine)')),
                            DropdownMenuItem(value: 'avian', child: Text('Poultry (Avian)')),
                          ],
                          onChanged: (val) => setStateSheet(() => selectedSpecies = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedSex,
                          decoration: const InputDecoration(labelText: 'Sex *'),
                          items: const [
                            DropdownMenuItem(value: 'female', child: Text('Female')),
                            DropdownMenuItem(value: 'male', child: Text('Male')),
                          ],
                          onChanged: (val) => setStateSheet(() => selectedSex = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(textCapitalization: TextCapitalization.sentences, controller: breedController,
                          decoration: const InputDecoration(labelText: 'Breed', hintText: 'e.g. Friesian'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(textCapitalization: TextCapitalization.sentences, controller: weightController,
                          decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: 'e.g. 350'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(textCapitalization: TextCapitalization.sentences, controller: colorController,
                          decoration: const InputDecoration(labelText: 'Color / Coat pattern'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(textCapitalization: TextCapitalization.sentences, controller: marksController,
                          decoration: const InputDecoration(labelText: 'Unique Marks'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildInputField(
                    label: 'Date of Birth *',
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDob ?? DateTime.now().subtract(const Duration(days: 365)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setStateSheet(() {
                            selectedDob = picked;
                            dobUnknown = false;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dobUnknown
                                  ? 'Not Known'
                                  : (selectedDob == null
                                      ? 'Choose Date'
                                      : selectedDob!.toLocal().toString().split(' ')[0]),
                              style: TextStyle(
                                color: (selectedDob == null && !dobUnknown) ? AppColors.outline : AppColors.onSurface,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: dobUnknown,
                          onChanged: (val) {
                            setStateSheet(() {
                              dobUnknown = val ?? false;
                              if (dobUnknown) {
                                selectedDob = null;
                              } else {
                                selectedDob = DateTime.now().subtract(const Duration(days: 365));
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Date of birth unknown / unrecorded', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  if (dobUnknown) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: buildInputField(
                            label: 'Estimated Age *',
                            child: TextField(
                              controller: estimatedAgeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'e.g. 2',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: buildInputField(
                            label: 'Age Unit *',
                            child: DropdownButtonFormField<String>(
                              value: estimatedAgeUnit,
                              items: const [
                                DropdownMenuItem(value: 'Years', child: Text('Years')),
                                DropdownMenuItem(value: 'Months', child: Text('Months')),
                                DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                                DropdownMenuItem(value: 'Days', child: Text('Days')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setStateSheet(() {
                                    estimatedAgeUnit = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedPedigree,
                          decoration: const InputDecoration(labelText: 'Pedigree Type'),
                          items: const [
                            DropdownMenuItem(value: 'pure', child: Text('Purebreed')),
                            DropdownMenuItem(value: 'cross', child: Text('Crossbreed')),
                            DropdownMenuItem(value: 'grading', child: Text('Grading Up')),
                            DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                          ],
                          onChanged: (val) => setStateSheet(() => selectedPedigree = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedPurpose,
                          decoration: const InputDecoration(labelText: 'Purpose'),
                          items: const [
                            DropdownMenuItem(value: 'breeding', child: Text('Breeding')),
                            DropdownMenuItem(value: 'milk', child: Text('Dairy (Milk)')),
                            DropdownMenuItem(value: 'meat', child: Text('Beef (Meat)')),
                            DropdownMenuItem(value: 'others', child: Text('Others')),
                          ],
                          onChanged: (val) => setStateSheet(() => selectedPurpose = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (isFemale)
                    buildInputField(
                      label: 'Reproductive Status',
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('Open'),
                            selected: selectedReproductive == 'open',
                            onSelected: (selected) {
                              if (selected) setStateSheet(() => selectedReproductive = 'open');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Pregnant'),
                            selected: selectedReproductive == 'pregnant',
                            onSelected: (selected) {
                              if (selected) setStateSheet(() => selectedReproductive = 'pregnant');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Lactating'),
                            selected: selectedReproductive == 'lactating',
                            onSelected: (selected) {
                              if (selected) setStateSheet(() => selectedReproductive = 'lactating');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Dry'),
                            selected: selectedReproductive == 'dry',
                            onSelected: (selected) {
                              if (selected) setStateSheet(() => selectedReproductive = 'dry');
                            },
                          ),
                        ],
                      ),
                    ),

                  // Removed Vaccination and Deworming UI as it is now in the Schedules tab
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime finalDob;
                            if (dobUnknown) {
                              final val = double.tryParse(estimatedAgeController.text) ?? 1.0;
                              if (estimatedAgeUnit == 'Years') {
                                finalDob = DateTime.now().subtract(Duration(days: (val * 365.25).round()));
                              } else if (estimatedAgeUnit == 'Months') {
                                finalDob = DateTime.now().subtract(Duration(days: (val * 30.4).round()));
                              } else if (estimatedAgeUnit == 'Weeks') {
                                finalDob = DateTime.now().subtract(Duration(days: (val * 7).round()));
                              } else {
                                finalDob = DateTime.now().subtract(Duration(days: val.round()));
                              }
                            } else {
                              if (selectedDob == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Date of birth is required!')),
                                );
                                return;
                              }
                              finalDob = selectedDob!;
                            }
                            final dobStr = finalDob.toIso8601String().split('T')[0];
                            final vacJson = jsonEncode({
                              'given': selectedVaccines,
                              'next_vaccine': nextVaccineToSchedule,
                              'next_date': nextVaccineDate?.toIso8601String(),
                            });
                            final dewormJson = jsonEncode({
                              'last_date': lastDewormDate?.toIso8601String(),
                              'next_date': nextDewormDate?.toIso8601String(),
                              'drug': dewormingDrugController.text.trim(),
                            });

                            // Removed inline schedule task creation; now handled by _showScheduleActionSheet

                            // Update repository
                            await sl<AnimalsRepository>().updateAnimal(_id, {
                              'tag_id': tagController.text.trim(),
                              'species': selectedSpecies,
                              'sex': selectedSex,
                              'breed': breedController.text.trim().isNotEmpty ? breedController.text.trim() : null,
                              'date_of_birth': dobStr,
                              'weight': weightController.text.isNotEmpty ? double.tryParse(weightController.text) : null,
                              'color': colorController.text.trim().isNotEmpty ? colorController.text.trim() : null,
                              'unique_marks': marksController.text.trim().isNotEmpty ? marksController.text.trim() : null,
                              'pedigree_type': selectedPedigree,
                              'purpose': selectedPurpose,
                              'current_reproductive_status': isFemale ? selectedReproductive : 'open',
                              'vaccination_status': vacJson,
                              'deworming_status': dewormJson,
                            });

                            // Fetch updated local model to trigger state refresh
                            final updated = await (db.select(db.localAnimals)..where((t) => t.id.equals(_id))).getSingle();
                            setState(() {
                              _tagId = updated.tagId;
                              _species = updated.species;
                              _sex = updated.sex;
                              _dateOfBirth = updated.dateOfBirth;
                              _breed = updated.breed ?? 'Unknown';
                              _status = updated.currentReproductiveStatus;
                              _liveStatus = updated.status;
                              _imagePath = updated.imagePath;
                              _color = updated.color;
                              _uniqueMarks = updated.uniqueMarks;
                              _purpose = updated.purpose;
                              _pedigreeType = updated.pedigreeType;
                              _vaccinationStatus = updated.vaccinationStatus;
                              _dewormingStatus = updated.dewormingStatus;
                              _weight = updated.weight;
                            });

                            if (bottomSheetContext.mounted) {
                              Navigator.pop(bottomSheetContext);
                            }
                            _refreshAllData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save'),
                        ),
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

  void _showAddBreedingDialog(BuildContext context) {
    final notesCtrl = TextEditingController();
    
    // Custom controllers and variables
    final List<String> heatSigns = [];
    final sireIdCtrl = TextEditingController();
    final sireBreedCtrl = TextEditingController();
    final semenBatchCtrl = TextEditingController();
    String breedingClass = 'crossed';
    final technicianCtrl = TextEditingController();
    String syncProtocol = 'ovsynch';
    final hormonesCtrl = TextEditingController(text: 'GnRH + PGF2a');
    DateTime? expectedHeatDate;
    String checkMethod = 'palpation';
    String checkResult = 'pregnant';
    DateTime? expectedCalvingDate;
    String calvingEase = 'normal';
    final offspringTagCtrl = TextEditingController();
    String offspringSex = 'female';

    String selectedType = 'heat';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Log Breeding Event'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Event Type *'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'heat', child: Text('Heat Detected')),
                        DropdownMenuItem(value: 'mating', child: Text('Natural Mating')),
                        DropdownMenuItem(value: 'ai_insemination', child: Text('Artificial Insemination (AI)')),
                        DropdownMenuItem(value: 'ostrus_synchronization', child: Text('Estrus Synchronization')),
                        DropdownMenuItem(value: 'pregnancy_check', child: Text('Pregnancy Check')),
                        DropdownMenuItem(value: 'confirmed_pregnant', child: Text('Confirmed Pregnant')),
                        DropdownMenuItem(value: 'abortion', child: Text('Abortion')),
                        DropdownMenuItem(value: 'calving', child: Text('Calving / Birth')),
                      ],
                      onChanged: (v) => setStateDialog(() => selectedType = v!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setStateDialog(() => selectedDate = picked);
                            }
                          },
                          child: const Text('Choose Date'),
                        ),
                      ],
                    ),
                    
                    // Heat signs
                    if (selectedType == 'heat') ...[
                      const SizedBox(height: 8),
                      const Text('Observed Heat Signs:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...['Standing heat (receptive)', 'Mucus discharge', 'Restlessness', 'Mounted by others'].map((sign) {
                        final isChecked = heatSigns.contains(sign);
                        return CheckboxListTile(
                          title: Text(sign, style: const TextStyle(fontSize: 12)),
                          value: isChecked,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val == true) {
                                  heatSigns.add(sign);
                              } else {
                                  heatSigns.remove(sign);
                              }
                            });
                          },
                        );
                      }),
                    ],
                    // Mating
                    if (selectedType == 'mating') ...[
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: sireIdCtrl,
                        decoration: const InputDecoration(labelText: 'Sire Tag ID / Name *'),
                      ),
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: sireBreedCtrl,
                        decoration: const InputDecoration(labelText: 'Sire Breed *', hintText: 'e.g. Friesian or Boran'),
                      ),
                    ],
                    // AI Insemination
                    if (selectedType == 'ai_insemination') ...[
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: semenBatchCtrl,
                        decoration: const InputDecoration(labelText: 'Semen Straw / Batch ID *'),
                      ),
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: sireBreedCtrl,
                        decoration: const InputDecoration(labelText: 'Semen Breed *', hintText: 'e.g. Holstein'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: breedingClass,
                        decoration: const InputDecoration(labelText: 'Breeding Class'),
                        items: const [
                          DropdownMenuItem(value: 'crossed', child: Text('Crossbred / Crossed')),
                          DropdownMenuItem(value: 'purebred', child: Text('Purebred')),
                        ],
                        onChanged: (val) => setStateDialog(() => breedingClass = val!),
                      ),
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: technicianCtrl,
                        decoration: const InputDecoration(labelText: 'Technician Name'),
                      ),
                    ],
                    // Estrus Synchronization
                    if (selectedType == 'ostrus_synchronization' || selectedType == 'estrus_synchronization') ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: syncProtocol,
                        decoration: const InputDecoration(labelText: 'Sync Protocol *'),
                        items: const [
                          DropdownMenuItem(value: 'ovsynch', child: Text('Ovsynch (GnRH-PGF-GnRH)')),
                          DropdownMenuItem(value: 'cosynch', child: Text('Cosynch')),
                          DropdownMenuItem(value: 'presynch', child: Text('Presynch')),
                          DropdownMenuItem(value: 'cidr', child: Text('CIDR Insert + Injection')),
                          DropdownMenuItem(value: 'other', child: Text('Other Hormonal Protocol')),
                        ],
                        onChanged: (val) => setStateDialog(() => syncProtocol = val!),
                      ),
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: hormonesCtrl,
                        decoration: const InputDecoration(labelText: 'Hormones/Drugs Used', hintText: 'e.g. GnRH + PGF2a'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              expectedHeatDate == null
                                  ? 'Expected Heat Date: Not Selected'
                                  : 'Expected Heat: ${DateFormat('yyyy-MM-dd').format(expectedHeatDate!)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 3)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setStateDialog(() => expectedHeatDate = picked);
                              }
                            },
                            child: const Text('Choose Date', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                    // Pregnancy Check
                    if (selectedType == 'pregnancy_check') ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: checkMethod,
                        decoration: const InputDecoration(labelText: 'Check Method'),
                        items: const [
                          DropdownMenuItem(value: 'palpation', child: Text('Rectal Palpation')),
                          DropdownMenuItem(value: 'ultrasound', child: Text('Ultrasound Scan')),
                          DropdownMenuItem(value: 'blood_test', child: Text('Blood Progesterone Test')),
                        ],
                        onChanged: (val) => setStateDialog(() => checkMethod = val!),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: checkResult,
                        decoration: const InputDecoration(labelText: 'Result *'),
                        items: const [
                          DropdownMenuItem(value: 'pregnant', child: Text('Pregnant (Positive)')),
                          DropdownMenuItem(value: 'open', child: Text('Open (Negative / Non-Preg)')),
                        ],
                        onChanged: (val) => setStateDialog(() => checkResult = val!),
                      ),
                      if (checkResult == 'pregnant') ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                expectedCalvingDate == null
                                    ? 'Expected Calving: Not Selected'
                                    : 'Expected Calving: ${DateFormat('yyyy-MM-dd').format(expectedCalvingDate!)}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(const Duration(days: 280)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 300)),
                                );
                                if (picked != null) {
                                  setStateDialog(() => expectedCalvingDate = picked);
                                }
                              },
                              child: const Text('Choose Date', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ],
                    // Calving
                    if (selectedType == 'calving') ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: calvingEase,
                        decoration: const InputDecoration(labelText: 'Calving Ease'),
                        items: const [
                          DropdownMenuItem(value: 'normal', child: Text('Normal (Unassisted)')),
                          DropdownMenuItem(value: 'assisted', child: Text('Assisted (Mild traction)')),
                          DropdownMenuItem(value: 'dystocia', child: Text('Dystocia (Difficult)')),
                          DropdownMenuItem(value: 'c_section', child: Text('C-Section (Surgical)')),
                        ],
                        onChanged: (val) => setStateDialog(() => calvingEase = val!),
                      ),
                      const SizedBox(height: 8),
                      TextField(textCapitalization: TextCapitalization.sentences, controller: offspringTagCtrl,
                        decoration: const InputDecoration(labelText: 'Offspring Tag ID (If registered)'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: offspringSex,
                        decoration: const InputDecoration(labelText: 'Offspring Sex'),
                        items: const [
                          DropdownMenuItem(value: 'female', child: Text('Heifer (Female)')),
                          DropdownMenuItem(value: 'male', child: Text('Bull (Male)')),
                          DropdownMenuItem(value: 'twins_f_f', child: Text('Twins (Female/Female)')),
                          DropdownMenuItem(value: 'twins_m_m', child: Text('Twins (Male/Male)')),
                          DropdownMenuItem(value: 'twins_f_m', child: Text('Twins (Mixed)')),
                        ],
                        onChanged: (val) => setStateDialog(() => offspringSex = val!),
                      ),
                    ],

                    const SizedBox(height: 8),
                    TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl,
                      decoration: const InputDecoration(labelText: 'Additional Remarks'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final dialogNav = Navigator.of(dialogCtx);
                    final apiClient = sl<ApiClient>();
                    final db = sl<LocalDatabase>();

                    // Pack structured outputs into result and notes
                    String resultValue = 'Logged';
                    String notesValue = notesCtrl.text.trim();

                    if (selectedType == 'heat') {
                      resultValue = 'Heat Detected';
                      notesValue = 'Observed Signs: ${heatSigns.isEmpty ? "General Signs" : heatSigns.join(", ")}. $notesValue'.trim();
                    } else if (selectedType == 'mating') {
                      resultValue = 'Mating with Sire #${sireIdCtrl.text}';
                      notesValue = 'Sire Breed: ${sireBreedCtrl.text}. $notesValue'.trim();
                    } else if (selectedType == 'ai_insemination') {
                      resultValue = 'AI (${breedingClass.toUpperCase()})';
                      notesValue = 'Semen Batch: ${semenBatchCtrl.text} | Semen Breed: ${sireBreedCtrl.text} | Tech: ${technicianCtrl.text}. $notesValue'.trim();
                    } else if (selectedType == 'ostrus_synchronization') {
                      resultValue = 'Sync Protocol: ${syncProtocol.toUpperCase()}';
                      notesValue = 'Drugs: ${hormonesCtrl.text} | Expected Heat: ${expectedHeatDate != null ? DateFormat('yyyy-MM-dd').format(expectedHeatDate!) : "N/A"}. $notesValue'.trim();
                    } else if (selectedType == 'pregnancy_check') {
                      resultValue = checkResult == 'pregnant' ? 'PREGNANT' : 'OPEN';
                      notesValue = 'Method: ${checkMethod.toUpperCase()} | Expected Calving: ${expectedCalvingDate != null ? DateFormat('yyyy-MM-dd').format(expectedCalvingDate!) : "N/A"}. $notesValue'.trim();
                    } else if (selectedType == 'confirmed_pregnant') {
                      resultValue = 'CONFIRMED PREGNANT';
                    } else if (selectedType == 'abortion') {
                      resultValue = 'ABORTION';
                    } else if (selectedType == 'calving') {
                      resultValue = 'Calved: Sex $offspringSex';
                      notesValue = 'Ease: ${calvingEase.toUpperCase()} | Offspring Tag: ${offspringTagCtrl.text.isEmpty ? "Unregistered" : offspringTagCtrl.text}. $notesValue'.trim();
                    }

                    final eventId = const Uuid().v4();
                    final payload = {
                      'id': eventId,
                      'animal_id': _id,
                      'event_type': selectedType,
                      'event_date': selectedDate.toIso8601String().substring(0, 10),
                      'result': resultValue,
                      'notes': notesValue.isEmpty ? null : notesValue,
                    };

                    try {
                      await apiClient.dio.post('/breeding_events', data: payload);
                      await db.into(db.localBreedingEvents).insert(LocalBreedingEventsCompanion.insert(
                        id: eventId,
                        animalId: _id,
                        eventType: selectedType,
                        eventDate: selectedDate,
                        result: drift.Value(resultValue),
                        notes: drift.Value(notesValue.isEmpty ? null : notesValue),
                      ));
                      if (!context.mounted) return;
                      dialogNav.pop();
                      _refreshAllData();
                    } catch (e) {
                      if (e is DioException && ApiClient.isNetworkError(e)) {
                        await db.into(db.localBreedingEvents).insert(LocalBreedingEventsCompanion.insert(
                          id: eventId,
                          animalId: _id,
                          eventType: selectedType,
                          eventDate: selectedDate,
                          result: drift.Value(resultValue),
                          notes: drift.Value(notesValue.isEmpty ? null : notesValue),
                        ));
                        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
                          endpoint: '/breeding_events',
                          method: 'POST',
                          body: jsonEncode(payload),
                          queuedAt: DateTime.now(),
                        ));
                        if (!context.mounted) return;
                        dialogNav.pop();
                        _refreshAllData();
                        return;
                      }
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save breeding event: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Save Event'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
