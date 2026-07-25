import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/local_db.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/widgets/app_dropdown.dart';
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

  Timer? _refreshTimer;
  StreamSubscription? _advancesSub;
  StreamSubscription? _queriesSub;
  late LocalStaffData _currentStaff;

  @override
  void initState() {
    super.initState();
    _currentStaff = widget.staff;
    _setupRealtimeListeners();
    _loadStaffData(showLoading: true);

    // 3-second background auto-checker for seamless live UI updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _loadStaffData(showLoading: false);
      }
    });
  }

  void _setupRealtimeListeners() {
    try {
      final db = sl<LocalDatabase>();
      
      // Watch Advances/Loans table reactively
      _advancesSub = (db.select(db.localSalaryAdvances)
        ..where((t) => t.staffId.equals(widget.staff.id))
        ..orderBy([(t) => OrderingTerm.desc(t.collectionDate)]))
        .watch()
        .listen((data) {
          if (mounted) {
            setState(() {
              _advances = data;
              _isLoading = false;
            });
          }
        });

      // Watch Staff Queries table reactively
      _queriesSub = (db.select(db.localStaffQueries)
        ..where((t) => t.staffId.equals(widget.staff.id))
        ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .watch()
        .listen((data) {
          if (mounted) {
            setState(() {
              _queries = data;
            });
          }
        });
    } catch (_) {}
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _advancesSub?.cancel();
    _queriesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadStaffData({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    try {
      final db = sl<LocalDatabase>();
      
      // Fetch latest staff record
      final staffRecord = await (db.select(db.localStaff)..where((t) => t.id.equals(widget.staff.id))).getSingleOrNull();
      
      final advances = await (db.select(db.localSalaryAdvances)
        ..where((t) => t.staffId.equals(widget.staff.id))
        ..orderBy([(t) => OrderingTerm.desc(t.collectionDate)]))
        .get();

      final queries = await (db.select(db.localStaffQueries)
        ..where((t) => t.staffId.equals(widget.staff.id))
        ..orderBy([(t) => OrderingTerm.desc(t.issueDate)]))
        .get();

      if (mounted) {
        setState(() {
          if (staffRecord != null) _currentStaff = staffRecord;
          _advances = advances;
          _queries = queries;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted && showLoading) {
        setState(() => _isLoading = false);
      }
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

    final netSalary = (_currentStaff.baseSalary - totalMonthlyAdvanceDeduction - totalActiveQueryDeduction).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentStaff.name.toUpperCase()} PROFILE'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'edit') {
                _showEditProfileDialog(context);
              } else if (val == 'update_status') {
                BlocProvider.of<StaffBloc>(context).add(UpdateStaffMember(
                  _currentStaff.id, 
                  {'is_active': !_currentStaff.isActive}
                ));
              } else if (val == 'delete') {
                showDialog(
                  context: context, 
                  builder: (_) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to remove this staff member permanently?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () {
                          BlocProvider.of<StaffBloc>(context).add(DeleteStaffMember(_currentStaff.id));
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Exit profile
                        }, 
                        child: const Text('Delete')
                      )
                    ]
                  )
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              PopupMenuItem(value: 'update_status', child: Text(_currentStaff.isActive ? 'Deactivate Staff' : 'Activate Staff')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Staff', style: TextStyle(color: Colors.red))),
            ],
          )
        ],
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
                                _currentStaff.name.isNotEmpty ? _currentStaff.name[0].toUpperCase() : 'S',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentStaff.name,
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
                                          _currentStaff.role,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (_currentStaff.isActive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _currentStaff.isActive ? 'ACTIVE' : 'INACTIVE',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _currentStaff.isActive ? Colors.green : Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_currentStaff.phone != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(_currentStaff.phone!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
                                  _currentStaff.startDate != null ? dateFormat.format(_currentStaff.startDate!) : 'Not set',
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
                                    _formatTenure(_currentStaff.startDate),
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
                                Text(currencyFormat.format(_currentStaff.baseSalary), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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

                    // Loans & Salary Advances Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('FINANCIAL RECORDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5, color: AppColors.primary)),
                                    Text('Manage employee loans & salary advances', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showRecordLoanDialog(context),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('New Loan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Material(
                                  color: Colors.orange.shade800,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showRecordSalaryAdvanceDialog(context),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('New Advance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_advances.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No loan records logged for this staff.', style: TextStyle(color: Colors.grey, fontSize: 13))),
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
                          final isOneOff = adv.isOneOffAdvance;
                          final titlePrefix = isOneOff ? 'Salary Advance' : 'Loan';
                          final remaining = (adv.advanceAmount - adv.totalRepaid).clamp(0.0, adv.advanceAmount);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isOneOff ? Colors.orange.shade300 : Colors.teal.shade300),
                            ),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$titlePrefix: ${currencyFormat.format(adv.advanceAmount)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isOneOff ? Colors.orange.shade900 : AppColors.primary)),
                                  Chip(
                                    label: Text(adv.isFullyRepaid ? 'PAID OFF' : (isOneOff ? 'ADVANCE (100%)' : 'ACTIVE LOAN'), style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: adv.isFullyRepaid ? Colors.green : (isOneOff ? Colors.orange.shade800 : AppColors.primary),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (isOneOff)
                                    Text('Deduction: 100% (${currencyFormat.format(adv.advanceAmount)}) at month end', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87))
                                  else ...[
                                    Text('Monthly Deduction: ${currencyFormat.format(adv.monthlyDeduction)} / mo', style: const TextStyle(fontSize: 12)),
                                    Text('Remaining Balance: ${currencyFormat.format(remaining)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                  ],
                                  Text('Collected: ${dateFormat.format(adv.collectionDate)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey.shade200,
                                      color: adv.isFullyRepaid ? Colors.green : (isOneOff ? Colors.orange : AppColors.primary),
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

  void _showRecordLoanDialog(BuildContext context) {
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
                const Text('RECORD MULTI-MONTH LOAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Loan Amount Collected (₦)', prefixIcon: Icon(Icons.payments)),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: monthsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repayment Duration (Months to Pay Back)', 
                    prefixIcon: Icon(Icons.calendar_month),
                    helperText: 'e.g. Enter 4 for 4 months installment repayment'
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
                                const Text('MONTHLY INSTALLMENT DEDUCTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.primary)),
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
                    final picked = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
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
                  decoration: const InputDecoration(labelText: 'Notes / Purpose', prefixIcon: Icon(Icons.note)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (amt <= 0 || months <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid loan amount and duration in months')));
                        return;
                      }
                      context.read<StaffBloc>().add(CreateSalaryAdvance(
                        widget.staff.id,
                        {
                          'advance_amount': amt,
                          'monthly_deduction': monthlyDeduction,
                          'repayment_months': months,
                          'collection_date': collectionDate.toIso8601String(),
                          'is_one_off_advance': false,
                          'notes': notesCtrl.text.isEmpty ? null : notesCtrl.text,
                        },
                      ));
                      Navigator.pop(bCtx);
                      _loadStaffData();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('SAVE LOAN RECORD'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRecordSalaryAdvanceDialog(BuildContext context) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime collectionDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final amt = double.tryParse(amountCtrl.text) ?? 0.0;

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
                const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('RECORD CURRENT MONTH SALARY ADVANCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Advance Amount Requested (₦)', 
                    prefixIcon: Icon(Icons.payments),
                    helperText: 'One-off early salary payout'
                  ),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 12),
                if (amt > 0) ...[
                  Card(
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.shade300)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('100% MONTH-END DEDUCTION NOTICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange)),
                                Text(
                                  '₦${NumberFormat('#,##0.00').format(amt)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade900),
                                ),
                                const Text('This full amount will be deducted 100% from the current month\'s payroll.', style: TextStyle(fontSize: 11, color: Colors.black87)),
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
                    final picked = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
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
                      if (amt <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid salary advance amount')));
                        return;
                      }
                      if (amt > _currentStaff.baseSalary) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Advance cannot exceed base salary of ₦${NumberFormat('#,##0').format(_currentStaff.baseSalary)}')));
                        return;
                      }
                      context.read<StaffBloc>().add(CreateSalaryAdvance(
                        _currentStaff.id,
                        {
                          'advance_amount': amt,
                          'monthly_deduction': amt,
                          'repayment_months': 1,
                          'collection_date': collectionDate.toIso8601String(),
                          'is_one_off_advance': true,
                          'notes': notesCtrl.text.isEmpty ? null : notesCtrl.text,
                        },
                      ));
                      Navigator.pop(bCtx);
                      _loadStaffData();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                    child: const Text('SAVE SALARY ADVANCE'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: _currentStaff.name);
    final phoneCtrl = TextEditingController(text: _currentStaff.phone ?? '');
    final roleCtrl = TextEditingController(text: _currentStaff.role);
    final salaryCtrl = TextEditingController(text: _currentStaff.baseSalary.toString());
    final addressCtrl = TextEditingController(text: _currentStaff.address ?? '');
    final emergencyCtrl = TextEditingController(text: _currentStaff.emergencyContact ?? '');
    
    String? selectedGender = _currentStaff.gender;
    String? selectedType = _currentStaff.employmentType ?? 'Full-time';
    DateTime? selectedDob = _currentStaff.dateOfBirth;
    DateTime? selectedStartDate = _currentStaff.startDate ?? DateTime.now();
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDiagState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Staff Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Profile Picture Edit (Optional, using CircleAvatar for now)
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final source = await showModalBottomSheet<ImageSource>(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(padding: EdgeInsets.all(16), child: Text('Select Image Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                              ListTile(
                                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                                title: const Text('Take a Photo'),
                                onTap: () => Navigator.pop(ctx, ImageSource.camera),
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                                title: const Text('Choose from Gallery'),
                                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                      if (source != null) {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: source);
                        if (image != null) {
                          setDiagState(() => selectedImage = File(image.path));
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: selectedImage != null 
                        ? FileImage(selectedImage!) 
                        : (_currentStaff.profilePic != null && _currentStaff.profilePic!.isNotEmpty ? NetworkImage(_currentStaff.profilePic!) : null) as ImageProvider?,
                      child: selectedImage == null && (_currentStaff.profilePic == null || _currentStaff.profilePic!.isEmpty) 
                        ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey) 
                        : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Info
                const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: 'Full Name', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: AppDropdownFormField<String>(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.people),
                      value: selectedGender,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                      ],
                      onChanged: (v) => selectedGender = v,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: GestureDetector(
                      onTap: () async {
                        int tempMonth = selectedDob?.month ?? DateTime.now().month;
                        int tempDay = selectedDob?.day ?? DateTime.now().day;
                        final date = await showDialog<DateTime>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Select Birthday'),
                            content: StatefulBuilder(
                              builder: (ctx, setDialogState) => Row(
                                children: [
                                  Expanded(
                                    child: AppDropdownFormField<int>(
                                      labelText: 'Month',
                                      value: tempMonth,
                                      items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(DateFormat('MMM').format(DateTime(2000, i + 1))))),
                                      onChanged: (v) => setDialogState(() => tempMonth = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppDropdownFormField<int>(
                                      labelText: 'Day',
                                      value: tempDay,
                                      items: List.generate(31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                                      onChanged: (v) => setDialogState(() => tempDay = v!),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.pop(ctx, DateTime(2000, tempMonth, tempDay)), child: const Text('OK')),
                            ],
                          ),
                        );
                        if (date != null) setDiagState(() => selectedDob = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(selectedDob != null ? DateFormat('MMMM d').format(selectedDob!) : 'Birthday (Day/Month)'),
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                // Employment Info
                const Text('Employment Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(),
                TextField(
                  controller: roleCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: 'Role (e.g. Herder, Manager)', prefixIcon: const Icon(Icons.work), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                AppDropdownFormField<String>(
                  labelText: 'Employment Type',
                  prefixIcon: const Icon(Icons.access_time),
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                    DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                    DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                  ],
                  onChanged: (v) => selectedType = v,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: false), child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!)), 
                      context: context,
                      initialDate: selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setDiagState(() => selectedStartDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(selectedStartDate != null ? DateFormat('MMM dd, yyyy').format(selectedStartDate!) : 'Date of Assumption of Duty'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('* Specifically refers to the Date of Assumption of Duty', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: salaryCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Base Salary (₦)', prefixIcon: const Icon(Icons.payments), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 24),

                // Contact Info
                const Text('Contact & Emergency', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: 'Address', prefixIcon: const Icon(Icons.home), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  textCapitalization: TextCapitalization.sentences, 
                  controller: emergencyCtrl, 
                  decoration: InputDecoration(labelText: 'Emergency Contact Info', prefixIcon: const Icon(Icons.warning), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty || roleCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Role cannot be empty')));
                        return;
                      }
                      
                      final baseSalary = double.tryParse(salaryCtrl.text.trim()) ?? 0.0;
                      
                      context.read<StaffBloc>().add(UpdateStaffMember(
                        _currentStaff.id,
                        {
                          'name': name,
                          'phone': phoneCtrl.text.trim(),
                          'role': roleCtrl.text.trim(),
                          'base_salary': baseSalary,
                          'address': addressCtrl.text.trim(),
                          'emergency_contact': emergencyCtrl.text.trim(),
                          'gender': selectedGender,
                          'employment_type': selectedType,
                          'date_of_birth': selectedDob?.toIso8601String(),
                          'start_date': selectedStartDate?.toIso8601String(),
                          if (selectedImage != null) 'profile_pic': selectedImage!.path,
                        }
                      ));
                      
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updating...')));
                      // Note: Ideally we wait for bloc to complete, but we'll just trigger refresh
                      Future.delayed(const Duration(milliseconds: 500), () => _loadStaffData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
