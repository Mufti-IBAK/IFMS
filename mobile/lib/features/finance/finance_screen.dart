import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'finance_bloc.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ENTERPRISE FINANCIALS'),
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state is FinanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FinanceLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectorMarginChart(state.sectorMargins),
                  const SizedBox(height: 24),
                  Text('CONSOLIDATED LEDGER', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildLedgerList(state.transactions),
                ],
              ),
            );
          }
          return const Center(child: Text('Error loading financial data.'));
        },
      ),
    );
  }

  Widget _buildSectorMarginChart(Map<String, double> margins) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NET PROFIT BY SECTOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ...margins.entries.map((e) => _marginBar(e.key, e.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _marginBar(String sector, double value) {
    final formatter = NumberFormat.compactCurrency(symbol: '₦');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sector, style: const TextStyle(fontSize: 13)),
              Text(formatter.format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.7, // Demo value
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerList(List<dynamic> transactions) {
    final currencyFormatter = NumberFormat.simpleCurrency(name: 'NGN');
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx.transactionType == 'income';
        
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
              child: Icon(
                isIncome ? Icons.add_chart : Icons.shopping_cart_outlined,
                color: isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(tx.description ?? tx.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${tx.category} • ${tx.transactionDate.toString().split(' ')[0]}', style: const TextStyle(fontSize: 12)),
            trailing: Text(
              '${isIncome ? '+' : '-'}${currencyFormatter.format(tx.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
