import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/sync/sync_manager.dart';
import 'package:ifms_mobile/core/widgets/custom_charts.dart';
import 'hatchery_bloc.dart';
import 'hatchery_repository.dart';

class HatcheryScreen extends StatefulWidget {
  const HatcheryScreen({super.key});

  @override
  State<HatcheryScreen> createState() => _HatcheryScreenState();
}

class _HatcheryScreenState extends State<HatcheryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFMS HATCHERY COHORTS'),
        actions: [
          IconButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Synchronizing hatchery logs...')),
              );
              await sl<SyncManager>().triggerSync();
              if (context.mounted) {
                BlocProvider.of<HatcheryBloc>(context).add(LoadHatcheryBatches());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hatchery sync complete!')),
                );
              }
            },
            icon: const Icon(Icons.sync, color: AppColors.info),
          ),
        ],
      ),
      body: BlocConsumer<HatcheryBloc, HatcheryState>(
        listener: (context, state) {
          if (state is HatcheryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is HatcheryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HatcheryLoaded) {
            return _buildHatcheryDashboard(state.batches);
          }
          // Default fallback if we haven't loaded anything yet or we had an error but still want to show UI.
          // Wait, if it's an error, we should probably fall back to loaded state or an empty list if there's no data.
          // The repository handles offline cache, so we usually get a Loaded state anyway.
          return const Center(child: Text('Press sync or load data.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBatchDialog(context),
        label: const Text('New Batch'),
        icon: const Icon(Icons.egg),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHatcheryDashboard(List<dynamic> batches) {
    final incubating = batches.where((b) => b['status'] == 'incubating').toList();
    final completed = batches.where((b) => b['status'] == 'completed').toList();

    int totalEggs = 0;
    for (var b in batches) {
      totalEggs += int.tryParse(b['egg_count'].toString()) ?? 0;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  'Incubating',
                  incubating.length.toString(),
                  Icons.hourglass_empty,
                  Colors.blue.shade50,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  'Hatched',
                  completed.length.toString(),
                  Icons.done_all,
                  Colors.green.shade50,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  'Eggs Set',
                  totalEggs.toString(),
                  Icons.egg,
                  Colors.amber.shade50,
                  Colors.amber.shade800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: batches.isEmpty
              ? const Center(child: Text('No hatchery batches recorded.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    final batch = batches[index];
                    final metadata = _parseBreedMetadata(batch['breed']);
                    final breed = metadata['breed'] ?? 'Unknown Breed';
                    final species = metadata['species'] ?? 'Chicken';
                    final incubationDays = metadata['incubation_days'] ?? (speciesIncubationDays[species] ?? 21);

                    final eggSource = batch['egg_source'] ?? 'General';
                    final eggCount = int.tryParse(batch['egg_count'].toString()) ?? 0;
                    final setDate = batch['set_date'] ?? '';
                    final expectedHatch = batch['expected_hatch_date'] ?? '';
                    final status = batch['status'] ?? 'incubating';
                    final fertile = batch['fertile_eggs'];
                    final hatched = batch['hatched_chicks'];

                    final isIncubating = status == 'incubating';

                    // Compute progress based on selected species incubation duration
                    double progress = 0.0;
                    int daysRemaining = incubationDays;
                    if (setDate.isNotEmpty) {
                      final setDt = DateTime.tryParse(setDate);
                      if (setDt != null) {
                        final diff = DateTime.now().difference(setDt).inDays;
                        progress = (diff / incubationDays).clamp(0.0, 1.0);
                        daysRemaining = (incubationDays - diff).clamp(0, incubationDays);
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showBatchDetailsSheet(context, batch),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                                        breed,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        'Source: $eggSource  •  Species: $species',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isIncubating ? Colors.orange.shade50 : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isIncubating ? 'Day ${incubationDays - daysRemaining} / $incubationDays' : 'Completed',
                                      style: TextStyle(
                                        color: isIncubating ? Colors.orange : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Eggs: $eggCount set',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (!isIncubating && hatched != null)
                                    Text(
                                      'Hatched: $hatched (${(hatched / (fertile ?? eggCount) * 100).toStringAsFixed(0)}% Hatch rate)',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                    )
                                  else if (isIncubating)
                                    Text(
                                      'Hatch: $expectedHatch',
                                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: isIncubating ? progress : 1.0,
                                  backgroundColor: Colors.grey.shade200,
                                  color: isIncubating ? Colors.orange : Colors.green,
                                  minHeight: 6,
                                ),
                              ),
                            ],
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

  Widget _buildKpiCard(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _showCreateBatchDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String eggSource = '';
    int eggCount = 0;
    String breed = '';
    String species = 'Chicken';
    int incubationDays = 21;
    DateTime collectionDate = DateTime.now();
    DateTime placementDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final expectedHatchDate = placementDate.add(Duration(days: incubationDays + 2));
            final switchDate = placementDate.add(Duration(days: incubationDays - 5));
            final collectionProposedDate = placementDate.add(Duration(days: incubationDays + 7));

            String formatDate(DateTime dt) => dt.toIso8601String().split('T')[0];

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.egg, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Start Incubation Batch'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: species,
                        decoration: const InputDecoration(labelText: 'Species of Bird Egg *'),
                        items: speciesIncubationDays.keys.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              species = val;
                              incubationDays = speciesIncubationDays[val] ?? 21;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey(incubationDays),
                        initialValue: incubationDays.toString(),
                        decoration: const InputDecoration(labelText: 'Incubation Time (Days) *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null ? 'Enter valid days' : null,
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null) {
                            setState(() {
                              incubationDays = parsed;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'Egg Source / Pen Name *'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter source' : null,
                        onSaved: (v) => eggSource = v!,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'Egg Count *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null ? 'Enter number' : null,
                        onSaved: (v) => eggCount = int.parse(v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'Breed / Variety (e.g. Noiler)'),
                        onSaved: (v) => breed = v?.isNotEmpty == true ? v! : 'General',
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                dense: true,
                                title: Text('Date of Collection: ${formatDate(collectionDate)}'),
                                trailing: const Icon(Icons.calendar_today, size: 16),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: collectionDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      collectionDate = picked;
                                    });
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                dense: true,
                                title: Text('Date of Placement: ${formatDate(placementDate)}'),
                                trailing: const Icon(Icons.calendar_today, size: 16),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: placementDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 30)),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      placementDate = picked;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ESTIMATED TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green)),
                              const SizedBox(height: 6),
                              _buildDateRow('Expected Hatching', formatDate(expectedHatchDate)),
                              _buildDateRow('Transfer to Hatcher', formatDate(switchDate)),
                              _buildDateRow('Chick Collection', formatDate(collectionProposedDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      final breedMetadata = jsonEncode({
                        'breed': breed,
                        'species': species,
                        'incubation_days': incubationDays,
                        'collection_date': formatDate(collectionDate),
                        'switch_date': formatDate(switchDate),
                        'chick_collection_date': formatDate(collectionProposedDate),
                      });

                      BlocProvider.of<HatcheryBloc>(context).add(CreateHatcheryBatch({
                        'egg_source': eggSource,
                        'egg_count': eggCount,
                        'breed': breedMetadata,
                        'initial_egg_cost': 0.0,
                        'set_date': formatDate(placementDate),
                        'expected_hatch_date': formatDate(expectedHatchDate),
                      }));
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Start Batch'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBatchDetailsSheet(BuildContext context, dynamic batch) async {
    final batchId = batch['id'];
    final kpis = await sl<HatcheryRepository>().getKpis(batchId);
    final events = await sl<HatcheryRepository>().getEvents(batchId);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                final status = kpis['status'] ?? batch['status'];
                final isIncubating = status == 'incubating';
                final metadata = _parseBreedMetadata(batch['breed']);
                final breedName = metadata['breed'] ?? 'Unknown Breed';
                final species = metadata['species'] ?? 'Chicken';
                final collectionDate = metadata['collection_date'] ?? 'N/A';
                final switchDate = metadata['switch_date'] ?? 'N/A';
                final chickCollectionDate = metadata['chick_collection_date'] ?? 'N/A';
                final expectedHatch = batch['expected_hatch_date'] ?? 'N/A';

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                breedName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text('Species: $species', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                              Text('Set Date: ${batch['set_date']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isIncubating ? Colors.orange.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: isIncubating ? Colors.orange : Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('INCUBATION KEY DATES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                              const SizedBox(height: 8),
                              _buildDateRow('Egg Collection Date', collectionDate),
                              _buildDateRow('Placement in Incubator', batch['set_date'] ?? 'N/A'),
                              _buildDateRow('Switch to Hatchery', switchDate),
                              _buildDateRow('Expected Hatching Date', expectedHatch),
                              _buildDateRow('Proposed Chick Collection', chickCollectionDate),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('KPIs & METRICS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDetailsKpiCard('Fertility Rate', '${(kpis['fertility_rate_percent'] ?? 0).toStringAsFixed(1)}%')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildDetailsKpiCard('Hatchability', '${(kpis['hatchability_rate_percent'] ?? 0).toStringAsFixed(1)}%')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildDetailsKpiCard('Cost / Chick', '₦${(kpis['cost_per_chick'] ?? 0).toStringAsFixed(1)}')),
                        ],
                      ),
                      if (kpis['fertility_rate_percent'] != null && double.parse(kpis['fertility_rate_percent'].toString()) > 0) ...[
                        const SizedBox(height: 16),
                        CustomDonutChart(
                          values: [
                            double.parse(kpis['fertility_rate_percent'].toString()),
                            (100 - double.parse(kpis['fertility_rate_percent'].toString())).clamp(0.0, 100.0),
                          ],
                          labels: const ['Fertile Eggs', 'Infertile/Other'],
                          colors: const [Colors.deepPurple, Colors.grey],
                          centerValue: '${double.parse(kpis['fertility_rate_percent'].toString()).toStringAsFixed(1)}%',
                          centerTitle: 'Fertile',
                          radius: 50,
                          thickness: 10,
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Divider(),
                      Row(

                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('CHRONOLOGICAL EVENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                          if (isIncubating)
                            TextButton.icon(
                              onPressed: () {
                                _showAddEventSheet(context, batchId, batch['egg_count'], (newEvent) {
                                  setSheetState(() {
                                    events.insert(0, newEvent);
                                    if (newEvent['event_type'] == 'candling') {
                                      kpis['fertility_rate_percent'] = (newEvent['value_json']['fertile_eggs'] / batch['egg_count']) * 100;
                                    } else if (newEvent['event_type'] == 'hatch_complete') {
                                      kpis['status'] = 'completed';
                                      kpis['hatched_chicks'] = newEvent['value_json']['hatched_chicks'];
                                      if (batch['fertile_eggs'] != null) {
                                        kpis['hatchability_rate_percent'] = (kpis['hatched_chicks'] / batch['fertile_eggs']) * 100;
                                      } else {
                                        kpis['hatchability_rate_percent'] = (kpis['hatched_chicks'] / batch['egg_count']) * 100;
                                      }
                                    }
                                  });
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline, size: 16),
                              label: const Text('Add Event'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (events.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('No events logged for this batch.', style: TextStyle(fontSize: 12, color: Colors.grey))),
                        )
                      else
                        ...events.map((e) {
                          final type = e['event_type'] ?? 'inspection';
                          final date = e['event_date'] ?? '';
                          final value = e['value_json'] ?? {};

                          IconData icon;
                          Color color;
                          String valueText = '';

                          if (type == 'candling') {
                            icon = Icons.lightbulb_outline;
                            color = Colors.amber;
                            valueText = '${value['fertile_eggs']} fertile eggs detected';
                          } else if (type == 'hatch_complete') {
                            icon = Icons.child_care;
                            color = Colors.green;
                            valueText = '${value['hatched_chicks']} chicks hatched successfully';
                          } else if (type == 'temperature_check') {
                            icon = Icons.thermostat;
                            color = Colors.redAccent;
                            valueText = '${value['temperature']}°C';
                          } else if (type == 'humidity_check') {
                            icon = Icons.water_drop;
                            color = Colors.blueAccent;
                            valueText = '${value['humidity']}% Humidity';
                          } else {
                            icon = Icons.sync_problem;
                            color = Colors.grey;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              dense: true,
                              leading: Icon(icon, color: color, size: 20),
                              title: Text(type.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                              subtitle: Text(valueText, style: const TextStyle(fontSize: 11)),
                              trailing: Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          );
                        }),
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

  Widget _buildDetailsKpiCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  void _showAddEventSheet(BuildContext context, String batchId, int eggCount, Function(Map<String, dynamic>) onAdded) {
    final formKey = GlobalKey<FormState>();
    String eventType = 'temperature_check';
    double tempVal = 37.5;
    double humVal = 60.0;
    int fertileEggs = eggCount;
    int hatchedChicks = eggCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Log Incubation Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: eventType,
                      decoration: const InputDecoration(labelText: 'Event Type'),
                      items: const [
                        DropdownMenuItem(value: 'temperature_check', child: Text('Temperature Check')),
                        DropdownMenuItem(value: 'humidity_check', child: Text('Humidity Check')),
                        DropdownMenuItem(value: 'candling', child: Text('Candling (Fertility Check)')),
                        DropdownMenuItem(value: 'turning', child: Text('Turning Eggs')),
                        DropdownMenuItem(value: 'hatch_complete', child: Text('Hatching Completed')),
                      ],
                      onChanged: (v) {
                        setSheetState(() => eventType = v!);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (eventType == 'temperature_check')
                      TextFormField(textCapitalization: TextCapitalization.sentences, initialValue: '37.5',
                        decoration: const InputDecoration(labelText: 'Temperature (°C)'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid temperature' : null,
                        onSaved: (v) => tempVal = double.parse(v!),
                      )
                    else if (eventType == 'humidity_check')
                      TextFormField(textCapitalization: TextCapitalization.sentences, initialValue: '60',
                        decoration: const InputDecoration(labelText: 'Humidity (%)'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid humidity' : null,
                        onSaved: (v) => humVal = double.parse(v!),
                      )
                    else if (eventType == 'candling')
                      TextFormField(textCapitalization: TextCapitalization.sentences, initialValue: eggCount.toString(),
                        decoration: const InputDecoration(labelText: 'Fertile Eggs Count'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final parsed = int.tryParse(v ?? '');
                          if (parsed == null || parsed < 0 || parsed > eggCount) {
                            return 'Must be between 0 and $eggCount';
                          }
                          return null;
                        },
                        onSaved: (v) => fertileEggs = int.parse(v!),
                      )
                    else if (eventType == 'hatch_complete')
                      TextFormField(textCapitalization: TextCapitalization.sentences, initialValue: eggCount.toString(),
                        decoration: const InputDecoration(labelText: 'Hatched Chicks Count'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final parsed = int.tryParse(v ?? '');
                          if (parsed == null || parsed < 0 || parsed > eggCount) {
                            return 'Must be between 0 and $eggCount';
                          }
                          return null;
                        },
                        onSaved: (v) => hatchedChicks = int.parse(v!),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();

                              final eventDateStr = DateTime.now().toIso8601String().split('T')[0];
                              Map<String, dynamic> valMap = {};

                              if (eventType == 'temperature_check') {
                                valMap = {'temperature': tempVal};
                              } else if (eventType == 'humidity_check') {
                                valMap = {'humidity': humVal};
                              } else if (eventType == 'candling') {
                                valMap = {'fertile_eggs': fertileEggs};
                              } else if (eventType == 'hatch_complete') {
                                valMap = {'hatched_chicks': hatchedChicks};
                              }

                              final eventPayload = {
                                'event_type': eventType,
                                'event_date': eventDateStr,
                                'value_json': valMap,
                              };

                              BlocProvider.of<HatcheryBloc>(context).add(AddHatcheryEvent(batchId, eventPayload));
                              onAdded(eventPayload);
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: const Text('Save Log'),
                        ),
                      ],
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

  final Map<String, int> speciesIncubationDays = {
    'Chicken': 21,
    'Duck': 28,
    'Turkey': 28,
    'Guinea Fowl': 28,
    'Quail': 17,
    'Geese': 30,
    'Other': 21,
  };

  Map<String, dynamic> _parseBreedMetadata(String? breedField) {
    if (breedField == null) return {'breed': 'General', 'species': 'Chicken', 'collection_date': '', 'switch_date': '', 'chick_collection_date': ''};
    if (breedField.startsWith('{')) {
      try {
        final Map<String, dynamic> data = jsonDecode(breedField);
        return data;
      } catch (_) {}
    }
    return {
      'breed': breedField,
      'species': 'Chicken',
      'collection_date': '',
      'switch_date': '',
      'chick_collection_date': '',
    };
  }

  Widget _buildDateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
