import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/local_db.dart';
import 'alert_bloc.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FARM BRAIN ALERTS'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'CRITICAL'),
              Tab(text: 'ACTION REQUIRED'),
              Tab(text: 'INSIGHTS'),
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
                  _AlertListView(alerts: state.alerts.where((a) => a.severity == 'critical').toList()),
                  _AlertListView(alerts: state.alerts.where((a) => a.severity == 'warning').toList()),
                  _AlertListView(alerts: state.alerts.where((a) => a.severity == 'insight').toList()),
                ],
              );
            }
            return const Center(child: Text('Error loading alerts.'));
          },
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
                        onPressed: () {},
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
                        onPressed: () {},
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
