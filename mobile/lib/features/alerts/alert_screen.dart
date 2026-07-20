import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/local_db.dart';
import '../../core/services/health_report_service.dart';
import 'alert_bloc.dart';
import 'widgets/farm_event_report_sheet.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  void _showHealthReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Generate Health Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Past 7 Days (Weekly)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _generateReport(context, 7);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Past 30 Days (Monthly)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _generateReport(context, 30);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_month),
                title: const Text('Past 90 Days (Quarterly)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _generateReport(context, 90);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _generateReport(BuildContext context, int days) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating General Health Report...')),
    );
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      await HealthReportService.generateReport(
        startDate: startDate,
        endDate: endDate,
        farmName: 'NAMANZO IFMS',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ALERTS & INSIGHTS CONTROL'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'General Health Report',
              onPressed: () => _showHealthReportDialog(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INSIGHTS & EVENTS'),
              Tab(text: 'CRITICAL'),
              Tab(text: 'ACTION REQUIRED'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        body: BlocBuilder<AlertBloc, AlertState>(
          builder: (context, state) {
            if (state is AlertLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AlertLoaded) {
              return TabBarView(
                children: [
                  _InsightsAndEventsView(insights: state.alerts.where((a) => a.severity == 'insight').toList()),
                  _AlertListView(alerts: state.alerts.where((a) => a.severity == 'critical').toList()),
                  _AlertListView(alerts: state.alerts.where((a) => a.severity == 'warning').toList()),
                ],
              );
            }
            return const Center(child: Text('Error loading alerts.'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => const FarmEventReportSheet(),
            ).then((_) {
              if (context.mounted) {
                context.read<AlertBloc>().add(LoadAlerts());
              }
            });
          },
          icon: const Icon(Icons.report),
          label: const Text('Report Event'),
        ),
      ),
    );
  }
}

class _AlertListView extends StatelessWidget {
  final List<LocalAlert> alerts;
  const _AlertListView({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const Center(child: Text('No active alerts in this category.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final isCritical = alert.severity == 'critical';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCritical ? Icons.report_problem : Icons.info_outline,
                      color: isCritical ? AppColors.error : AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.title.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCritical ? AppColors.error : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Loc: ${alert.location ?? "N/A"} | Impact: ${alert.impact ?? "N/A"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(alert.message, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AlertBloc>().add(ResolveAlert(alert.id));
                          final titleLower = alert.title.toLowerCase();
                          if (titleLower.contains('feed')) {
                            Navigator.pushNamed(context, '/inventory');
                          } else if (titleLower.contains('medication') || titleLower.contains('pharmacy')) {
                            Navigator.pushNamed(context, '/pharmacy');
                          } else if (titleLower.contains('animal') || titleLower.contains('mortality') || titleLower.contains('sick')) {
                            Navigator.pushNamed(context, '/animals');
                          } else {
                            Navigator.pushNamed(context, '/tasks');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.onSurface,
                        ),
                        child: const Text('Action Required', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AlertBloc>().add(ResolveAlert(alert.id));
                        },
                        child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
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
}

class _InsightsAndEventsView extends StatelessWidget {
  final List<LocalAlert> insights;
  const _InsightsAndEventsView({required this.insights});

  @override
  Widget build(BuildContext context) {
    final db = sl<LocalDatabase>();

    return FutureBuilder<List<LocalFarmEvent>>(
      future: (db.select(db.localFarmEvents)..orderBy([(t) => drift.OrderingTerm(expression: t.eventDate, mode: drift.OrderingMode.desc)])).get(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (events.isNotEmpty) ...[
              const Text('Reported Events History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
              const SizedBox(height: 10),
              ...events.map((ev) {
                Map<String, dynamic>? meta;
                if (ev.description.startsWith('{')) {
                  try {
                    meta = jsonDecode(ev.description);
                  } catch (_) {}
                }
                
                final descText = meta != null ? meta['description']?.toString() : ev.description;
                final severity = meta != null ? meta['severity']?.toString() : 'insight';
                final actionText = meta != null ? meta['action_required_details']?.toString() : null;

                Color badgeColor = Colors.blue;
                if (severity == 'critical') badgeColor = Colors.red;
                if (severity == 'warning') badgeColor = Colors.orange;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ev.eventType.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                severity == 'warning' ? 'ACTION REQUIRED' : severity!.toUpperCase(),
                                style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(descText ?? '', style: const TextStyle(fontSize: 13)),
                        if (actionText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Action Required: $actionText',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                        if (ev.involvedAnimals != null && ev.involvedAnimals!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Involved Animals: ${ev.involvedAnimals}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(ev.eventDate),
                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
            
            const Text('System Insights & Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            const SizedBox(height: 10),
            if (insights.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No system insights at this time.'),
                ),
              )
            else
              ...insights.map((alert) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                    title: Text(alert.title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(alert.message, style: const TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        context.read<AlertBloc>().add(ResolveAlert(alert.id));
                      },
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
