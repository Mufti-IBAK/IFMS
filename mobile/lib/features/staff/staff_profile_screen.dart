import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/local_db.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import 'staff_bloc.dart';

class StaffProfileScreen extends StatefulWidget {
  final LocalStaffData staff;

  const StaffProfileScreen({Key? key, required this.staff}) : super(key: key);

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  List<LocalSalaryAdvance> _advances = [];
  List<LocalStaffQuery> _queries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    setState(() => _isLoading = true);
    try {
      final db = sl<LocalDatabase>();
      final advances = await (db.select(db.localSalaryAdvances)
        ..where((t) => t.staffId.equals(widget.staff.id))
        ..orderBy([(t) => OrderingTerm.desc(t.collectionDate)]))
        .get();

      final queries = await (db.select(db.localStaffQueries)
        ..where((t) => t.staffId.equals(widget.staff.id))
        ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .get();

      setState(() {
        _advances = advances;
        _queries = queries;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _formatTenure(DateTime? startDate) {
    if (startDate == null) return 'N/A';
    final now = DateTime.now();
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    return '${years}yr ${months}mo ${days}d';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    double totalMonthlyAdvanceDeduction = 0.0;
    for (var adv in _advances) {
      if (!adv.isFullyRepaid) {
        totalMonthlyAdvanceDeduction += adv.monthlyDeduction;
      }
    }

    double totalActiveQueryDeduction = 0.0;
    for (var q in _queries) {
      if (!q.isResolved) {
        totalActiveQueryDeduction += q.deductionAmount;
      }
    }

    final netSalary = (widget.staff.baseSalary - totalMonthlyAdvanceDeduction - totalActiveQueryDeduction).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.staff.name.toUpperCase()} PROFILE'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadStaffData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Profile Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                widget.staff.name.isNotEmpty ? widget.staff.name[0].toUpperCase() : 'S',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.staff.name,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          widget.staff.role,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (widget.staff.isActive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          widget.staff.isActive ? 'ACTIVE' : 'INACTIVE',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.staff.isActive ? Colors.green : Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (widget.staff.phone != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(widget.staff.phone!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Employment & Tenure Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EMPLOYMENT METRICS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Date Started:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                Text(
                                  widget.staff.startDate != null ? dateFormat.format(widget.staff.startDate!) : 'Not set',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Service Tenure (Realtime):', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text(
                                    _formatTenure(widget.staff.startDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Salary Breakdown Card
                    Card(
                      color: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('SALARY & PAYROLL BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Base Salary:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text(currencyFormat.format(widget.staff.baseSalary), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Active Advance Deduction:', style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
                                Text('- ${currencyFormat.format(totalMonthlyAdvanceDeduction)}', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            if (totalActiveQueryDeduction > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Unresolved Query Deduction:', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                  Text('- ${currencyFormat.format(totalActiveQueryDeduction)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                            const Divider(color: Colors.white38, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Net Take-Home Pay:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(
                                  currencyFormat.format(netSalary),
                                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Salary Advances Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SALARY ADVANCES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                        ElevatedButton.icon(
                          onPressed: () => _showRecordAdvanceDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('RECORD ADVANCE', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_advances.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No salary advance records logged for this staff.', style: TextStyle(color: Colors.grey, fontSize: 13))),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _advances.length,
                        itemBuilder: (ctx, idx) {
                          final adv = _advances[idx];
                          final progress = (adv.advanceAmount > 0) ? (adv.totalRepaid / adv.advanceAmount).clamp(0.0, 1.0) : 1.0;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Advance: ${currencyFormat.format(adv.advanceAmount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Chip(
                                    label: Text(adv.isFullyRepaid ? 'PAID OFF' : 'ACTIVE', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: adv.isFullyRepaid ? Colors.green : Colors.orange,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Deduction: ${currencyFormat.format(adv.monthlyDeduction)} / month', style: const TextStyle(fontSize: 12)),
                                  Text('Collected: ${dateFormat.format(adv.collectionDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey.shade200,
                                      color: adv.isFullyRepaid ? Colors.green : Colors.orange,
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Repaid: ${currencyFormat.format(adv.totalRepaid)} of ${currencyFormat.format(adv.advanceAmount)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),

                    // Disciplinary Queries Section
                    const Text('QUERIES & DISCIPLINARY RECORDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    if (_queries.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No disciplinary queries recorded.', style: TextStyle(color: Colors.grey, fontSize: 13))),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _queries.length,
                        itemBuilder: (ctx, idx) {
                          final q = _queries[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(q.isResolved ? Icons.check_circle : Icons.warning_amber_rounded, color: q.isResolved ? Colors.green : Colors.red),
                              title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('Deduction: ${currencyFormat.format(q.deductionAmount)} | Issued: ${dateFormat.format(q.issueDate)}', style: const TextStyle(fontSize: 12)),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showRecordAdvanceDialog(BuildContext context) {
    final amountCtrl = TextEditingController();
    final monthsCtrl = TextEditingController(text: '4');
    final notesCtrl = TextEditingController();
    DateTime collectionDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final amt = double.tryParse(amountCtrl.text) ?? 0.0;
          final months = int.tryParse(monthsCtrl.text) ?? 1;
          final monthlyDeduction = (amt > 0 && months > 0) ? (amt / months) : 0.0;

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RECORD SALARY ADVANCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Advance Amount Collected (₦)', prefixIcon: Icon(Icons.payments)),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: monthsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repayment Duration (Months to Pay Back)', 
                    prefixIcon: Icon(Icons.calendar_month),
                    helperText: 'e.g. Enter 4 for 4 months repayment'
                  ),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 12),
                if (amt > 0 && months > 0) ...[
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.calculate, color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AUTO-DEDUCTION CALCULATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.primary)),
                                Text(
                                  '₦${NumberFormat('#,##0.00').format(monthlyDeduction)} / month',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                ),
                                Text('Deducted automatically over $months months', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Collection Date: ${DateFormat('dd MMM yyyy').format(collectionDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: collectionDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setModalState(() => collectionDate = picked);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes / Reason', prefixIcon: Icon(Icons.note)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (amt <= 0 || months <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid advance amount and duration in months')));
                        return;
                      }
                      context.read<StaffBloc>().add(CreateSalaryAdvance(
                        widget.staff.id,
                        {
                          'advance_amount': amt,
                          'monthly_deduction': monthlyDeduction,
                          'repayment_months': months,
                          'collection_date': collectionDate.toIso8601String(),
                          'notes': notesCtrl.text.isEmpty ? null : notesCtrl.text,
                        },
                      ));
                      Navigator.pop(bCtx);
                      _loadStaffData();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('SAVE ADVANCE RECORD'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
