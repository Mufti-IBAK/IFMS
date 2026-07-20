import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/payroll_pdf_service.dart';
import '../../core/widgets/app_dropdown.dart';
import 'staff_bloc.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFmt = NumberFormat.currency(symbol: '₦ ', decimalDigits: 2);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('LABOR & OPERATIONS MANAGEMENT'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Directory'),
            Tab(text: 'Queries'),
            Tab(text: 'Budget'),
          ],
        ),
      ),
      body: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StaffLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDirectoryTab(state),
                _buildQueriesTab(state),
                _buildBudgetTab(state),
              ],
            );
          } else if (state is StaffError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data found.'));
        },
      ),
      floatingActionButton: _tabController.index == 2 ? null : FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddStaffDialog(context);
          } else if (_tabController.index == 1) {
            _showIssueQueryDialog(context);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(_tabController.index == 0 ? Icons.person_add : Icons.report_problem),
        label: Text(_tabController.index == 0 ? 'Register Staff' : 'Issue Query'),
      ),
    );
  }

  Widget _buildDirectoryTab(StaffLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.staff.length,
      itemBuilder: (context, index) {
        final worker = state.staff[index];
        final isMap = worker is Map;
        final name = isMap ? worker['name'] : worker.name;
        final role = isMap ? worker['role'] : worker.role;
        final salary = isMap ? worker['base_salary'] : worker.baseSalary;
        final rating = isMap ? worker['performance_rating'] : worker.performanceRating;
        final payout = isMap ? (worker['final_payout'] ?? salary) : salary;
        final profilePic = isMap ? worker['profile_pic'] : (worker as dynamic).profilePic;
        final startDate = isMap ? (worker['start_date'] != null ? DateTime.tryParse(worker['start_date'].toString()) : null) : (worker as dynamic).startDate;
        
        final tenureText = startDate != null ? _formatTenure(startDate) : 'N/A';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: profilePic != null && profilePic.isNotEmpty ? FileImage(File(profilePic)) : null,
              child: profilePic == null || profilePic.isEmpty ? Text(name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)) : null,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role),
                Text('Tenure: $tenureText', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < rating ? Colors.amber : Colors.grey.shade300,
                  )),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_currencyFmt.format(payout), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Text('Est. Payout', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            onTap: () => _showEditStaffSheet(context, worker),
          ),
        );
      },
    );
  }

  Widget _buildQueriesTab(StaffLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.queries.length,
      itemBuilder: (context, index) {
        final query = state.queries[index];
        dynamic staff;
        for (var s in state.staff) {
          if ((s is Map ? s['id'] : s.id) == query.staffId) {
            staff = s;
            break;
          }
        }
        final staffName = staff != null ? (staff is Map ? staff['name'] : staff.name) : 'Unknown';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(query.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Issued to: $staffName\n${DateFormat('MMM dd, yyyy').format(query.issueDate)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('- ${_currencyFmt.format(query.deductionAmount)}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                Text(query.isResolved ? 'RESOLVED' : 'UNRESOLVED', 
                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: query.isResolved ? Colors.green : AppColors.error)),
              ],
            ),
            onTap: query.isResolved ? null : () => _showResolveQueryDialog(context, query.id),
          ),
        );
      },
    );
  }

  Widget _buildBudgetTab(StaffLoaded state) {
    final b = state.budget;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildKpiCard('TOTAL BASE SALARY', _currencyFmt.format(b['total_base_salary'] ?? 0.0), Icons.payments, Colors.blue),
          const SizedBox(height: 12),
          _buildKpiCard('ACTIVE DEDUCTIONS', '- ${_currencyFmt.format(b['total_active_deductions'] ?? 0.0)}', Icons.warning_amber, AppColors.error),
          const SizedBox(height: 12),
          _buildKpiCard('NET SALARY BUDGET', _currencyFmt.format(b['net_salary_budget'] ?? 0.0), Icons.account_balance_wallet, AppColors.primary),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STAFF SUMMARY', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  _summaryRow('Active Staff Members', '${b['staff_count'] ?? 0}'),
                  _summaryRow('Unresolved Queries', '${b['active_queries_count'] ?? 0}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showRunPayrollDialog(context, state),
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Run Payroll'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showRunPayrollDialog(BuildContext context, StaffLoaded state) {
    final b = state.budget;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Run Payroll', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Are you sure you want to run payroll for the current month? This will process salary deductions and log financial transactions.'),
            const SizedBox(height: 16),
            _summaryRow('Active Staff to Pay', '${b['staff_count'] ?? 0}'),
            _summaryRow('Total Base Salary', _currencyFmt.format(b['total_base_salary'] ?? 0.0)),
            _summaryRow('Total Deductions', _currencyFmt.format(b['total_active_deductions'] ?? 0.0)),
            const Divider(),
            _summaryRow('Total Net Payable', _currencyFmt.format(b['net_salary_budget'] ?? 0.0)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<StaffBloc>().add(ProcessPayroll(DateTime.now()));
                      Navigator.pop(ctx);
                      
                      // Generate and preview the PDF
                      PayrollPdfService.generatePayrollPdf(
                        staff: state.staff,
                        budget: state.budget,
                        farmName: 'Mufti-IBAK/IFMS',
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payroll processing started')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Run Payroll'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final emergencyCtrl = TextEditingController();
    
    String? selectedGender;
    String? selectedType = 'Full-time';
    DateTime? selectedDob;
    DateTime? selectedStartDate = DateTime.now();
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
                const Text('Register New Staff', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Profile Picture
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
                      backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                      child: selectedImage == null ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Basic Info
                const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(),
                TextField(textCapitalization: TextCapitalization.sentences, controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: AppDropdownFormField<String>(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.people),
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
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
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
                TextField(textCapitalization: TextCapitalization.sentences, controller: roleCtrl, decoration: const InputDecoration(labelText: 'Role (e.g. Herder)', prefixIcon: Icon(Icons.work))),
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
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setDiagState(() => selectedStartDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(selectedStartDate != null ? DateFormat('MMM dd, yyyy').format(selectedStartDate!) : 'Employment Start Date'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: salaryCtrl, decoration: const InputDecoration(labelText: 'Base Salary', prefixIcon: Icon(Icons.payments)), keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                
                // Contact Info
                const Text('Contact & Emergency', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(),
                TextField(textCapitalization: TextCapitalization.sentences, controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                TextField(textCapitalization: TextCapitalization.sentences, controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on))),
                const SizedBox(height: 12),
                TextField(textCapitalization: TextCapitalization.sentences, controller: emergencyCtrl, decoration: const InputDecoration(labelText: 'Emergency Contact Info', prefixIcon: Icon(Icons.warning))),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('A profile picture is mandatory.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (nameCtrl.text.isEmpty || roleCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter the name and role.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      context.read<StaffBloc>().add(AddStaffMember({
                        'name': nameCtrl.text,
                        'role': roleCtrl.text,
                        'base_salary': double.tryParse(salaryCtrl.text) ?? 0.0,
                        'phone': phoneCtrl.text,
                        'address': addressCtrl.text,
                        'emergency_contact': emergencyCtrl.text,
                        'gender': selectedGender,
                        'employment_type': selectedType,
                        'date_of_birth': selectedDob?.toIso8601String(),
                        'start_date': selectedStartDate?.toIso8601String(),
                        'profile_pic': selectedImage?.path,
                      }));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Register Staff'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIssueQueryDialog(BuildContext context) {
    final state = context.read<StaffBloc>().state;
    if (state is! StaffLoaded) return;

    String? selectedStaffId;
    final titleCtrl = TextEditingController();
    final deductionCtrl = TextEditingController(text: '0.0');

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Issue Disciplinary Query', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.error)),
              const SizedBox(height: 8),
              const Text('Record an infraction and set a pending deduction amount.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              AppDropdownFormField<String>(
                labelText: 'Select Staff Member *',
                prefixIcon: const Icon(Icons.person),
                value: selectedStaffId,
                items: state.staff.map((s) {
                  final id = s is Map ? s['id'] : (s as dynamic).id;
                  final name = s is Map ? s['name'] : (s as dynamic).name;
                  return DropdownMenuItem<String>(value: id.toString(), child: Text(name));
                }).toList(),
                onChanged: (val) => setDiagState(() => selectedStaffId = val),
              ),
              const SizedBox(height: 16),
              TextField(textCapitalization: TextCapitalization.sentences, controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Reason / Infraction', prefixIcon: Icon(Icons.report), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(textCapitalization: TextCapitalization.sentences, controller: deductionCtrl,
                decoration: const InputDecoration(labelText: 'Deduction Amount (₦)', prefixIcon: Icon(Icons.money_off), border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedStaffId != null) {
                      context.read<StaffBloc>().add(IssueStaffQuery(selectedStaffId!, {
                        'title': titleCtrl.text,
                        'deduction_amount': double.tryParse(deductionCtrl.text) ?? 0.0,
                        'issue_date': DateTime.now().toIso8601String().substring(0, 10),
                      }));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Query Issued Successfully')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Issue Query'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showResolveQueryDialog(BuildContext context, String queryId) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Query'),
        content: TextField(textCapitalization: TextCapitalization.sentences, controller: notesCtrl, decoration: const InputDecoration(labelText: 'Resolution Notes')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<StaffBloc>().add(ResolveStaffQuery(queryId, notesCtrl.text));
              Navigator.pop(ctx);
            },
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }

  void _showEditStaffSheet(BuildContext context, dynamic staff) {
    final isMap = staff is Map;
    final staffId = isMap ? staff['id'] : staff.id;
    final name = isMap ? staff['name'] : staff.name;
    final ratingCtrl = TextEditingController(text: (isMap ? staff['performance_rating'] : staff.performanceRating).toString());
    final salaryCtrl = TextEditingController(text: (isMap ? staff['base_salary'] : staff.baseSalary).toString());
    final roleCtrl = TextEditingController(text: (isMap ? staff['role'] : staff.role).toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('Manage Worker: $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<StaffBloc>().add(DeleteStaffMember(staffId));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name deleted')));
                    },
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Divider(),
              TextField(
                textCapitalization: TextCapitalization.words, 
                controller: roleCtrl, 
                decoration: InputDecoration(labelText: 'Role (e.g. Herder)', prefixIcon: const Icon(Icons.work), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))
              ),
              const SizedBox(height: 16),
              const Text('Compensation & Performance', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Divider(),
              TextField(
                textCapitalization: TextCapitalization.sentences, 
                controller: salaryCtrl, 
                decoration: InputDecoration(labelText: 'Monthly Salary', prefixIcon: const Icon(Icons.payments), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
                keyboardType: TextInputType.number
              ),
              const SizedBox(height: 16),
              TextField(
                textCapitalization: TextCapitalization.sentences, 
                controller: ratingCtrl, 
                decoration: InputDecoration(labelText: 'Performance Rating (1-5)', prefixIcon: const Icon(Icons.star), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
                keyboardType: TextInputType.number
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showSalaryAdvanceDialog(context, staffId, name);
                  },
                  icon: const Icon(Icons.money),
                  label: const Text('Request Salary Advance'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<StaffBloc>().add(UpdateStaffMember(staffId, {
                      'role': roleCtrl.text,
                      'base_salary': double.tryParse(salaryCtrl.text) ?? 0.0,
                      'performance_rating': double.tryParse(ratingCtrl.text) ?? 5.0,
                    }));
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Update Worker'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSalaryAdvanceDialog(BuildContext context, String staffId, String staffName) {
    final amountCtrl = TextEditingController();
    final deductionCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime collectionDate = DateTime.now();
    int repaymentMonths = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDiagState) {
          void calculateRepayment() {
            final amt = double.tryParse(amountCtrl.text) ?? 0.0;
            final ded = double.tryParse(deductionCtrl.text) ?? 0.0;
            if (amt > 0 && ded > 0) {
              setDiagState(() {
                repaymentMonths = (amt / ded).ceil();
              });
            } else {
              setDiagState(() {
                repaymentMonths = 0;
              });
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Record Salary Advance for $staffName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: amountCtrl,
                    decoration: InputDecoration(labelText: 'Advance Amount (₦)', prefixIcon: const Icon(Icons.money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => calculateRepayment(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: deductionCtrl,
                    decoration: InputDecoration(labelText: 'Monthly Deduction (₦)', prefixIcon: const Icon(Icons.money_off), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => calculateRepayment(),
                  ),
                  const SizedBox(height: 8),
                  if (repaymentMonths > 0)
                    Text('Repayment: $repaymentMonths months', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: collectionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setDiagState(() => collectionDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(DateFormat('MMM dd, yyyy').format(collectionDate)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(labelText: 'Notes (Optional)', prefixIcon: const Icon(Icons.note), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (amountCtrl.text.isEmpty || deductionCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
                          return;
                        }
                        context.read<StaffBloc>().add(CreateSalaryAdvance(staffId, {
                          'advance_amount': double.tryParse(amountCtrl.text) ?? 0.0,
                          'monthly_deduction': double.tryParse(deductionCtrl.text) ?? 0.0,
                          'collection_date': collectionDate.toIso8601String(),
                          'notes': notesCtrl.text,
                        }));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salary advance recorded successfully.')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Record Advance'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  String _formatTenure(DateTime startDate) {
    final now = DateTime.now();
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;
    if (days < 0) { months--; days += DateTime(now.year, now.month, 0).day; }
    if (months < 0) { years--; months += 12; }
    return '${years}yr ${months}mo ${days}d';
  }
}
