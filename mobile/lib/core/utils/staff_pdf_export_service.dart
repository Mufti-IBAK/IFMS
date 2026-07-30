import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../database/local_db.dart';

class StaffPdfExportService {
  static Future<void> exportStaffReportPdf({
    required List<dynamic> staffList,
    required List<LocalStaffQuery> queries,
    required Map<String, dynamic> budget,
  }) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.currency(symbol: 'NGN ', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final generatedAt = DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.now());

    // Calculate Best Worker of the Month
    Map<String, dynamic>? bestWorker;
    double highestScore = -1.0;

    for (final member in staffList) {
      final id = member is LocalStaffData ? member.id : member['id'];
      final name = member is LocalStaffData ? member.name : member['name'];
      final role = member is LocalStaffData ? member.role : member['role'];
      final rating = (member is LocalStaffData ? member.performanceRating : double.tryParse((member['performance_rating'] ?? 5.0).toString())) ?? 5.0;
      final startDate = member is LocalStaffData ? member.startDate : (member['start_date'] != null ? DateTime.tryParse(member['start_date']) : null);
      
      final staffQueries = queries.where((q) => q.staffId == id).toList();
      final unresolvedQueries = staffQueries.where((q) => !q.isResolved).length;

      // Score formula: rating (0-5) * 20 - (unresolvedQueries * 15) + (tenureYears * 2)
      int tenureDays = startDate != null ? DateTime.now().difference(startDate).inDays : 0;
      double tenureYears = tenureDays / 365.0;
      double score = (rating * 20.0) - (unresolvedQueries * 15.0) + (tenureYears * 2.0);

      if (score > highestScore) {
        highestScore = score;
        bestWorker = {
          'name': name,
          'role': role,
          'rating': rating,
          'tenureDays': tenureDays,
          'unresolvedQueries': unresolvedQueries,
          'score': score,
        };
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ROYAL HERITAGE FARMS', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    pw.Text('STAFF & PAYROLL ANALYSIS REPORT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal700)),
                    pw.Text('Generated: $generatedAt', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(color: PdfColors.teal50, borderRadius: pw.BorderRadius.circular(6)),
                  child: pw.Text('CONFIDENTIAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Executive Budget Summary Cards
            pw.Text('PAYROLL & FINANCIAL SUMMARY', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildPdfKpiCard('Total Active Staff', '${budget['staff_count'] ?? staffList.length}', PdfColors.blue50, PdfColors.blue900),
                _buildPdfKpiCard('Base Salary Budget', currencyFormatter.format(budget['total_base_salary'] ?? 0.0), PdfColors.green50, PdfColors.green900),
                _buildPdfKpiCard('Total Deductions', currencyFormatter.format(budget['total_active_deductions'] ?? 0.0), PdfColors.red50, PdfColors.red900),
                _buildPdfKpiCard('Net Outflow', currencyFormatter.format(budget['net_salary_budget'] ?? 0.0), PdfColors.teal50, PdfColors.teal900),
              ],
            ),
            pw.SizedBox(height: 16),

            // Best Worker of the Month Banner
            if (bestWorker != null) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  border: pw.Border.all(color: PdfColors.amber400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 40,
                      height: 40,
                      decoration: const pw.BoxDecoration(color: PdfColors.amber400, shape: pw.BoxShape.circle),
                      child: pw.Center(child: pw.Text('★', style: pw.TextStyle(fontSize: 22, color: PdfColors.white))),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('WORKER OF THE MONTH', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900)),
                        pw.Text('${bestWorker['name']} — ${bestWorker['role']}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                        pw.Text('Performance Rating: ${bestWorker['rating']} / 5.0 | Active Queries: ${bestWorker['unresolvedQueries']}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // Staff Roster Table
            pw.Text('STAFF DIRECTORY & PAYROLL BREAKDOWN', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['Name', 'Role', 'Employment', 'Base Salary', 'Performance', 'Status'],
              data: staffList.map((m) {
                final name = m is LocalStaffData ? m.name : m['name'];
                final role = m is LocalStaffData ? m.role : m['role'];
                final empType = m is LocalStaffData ? (m.employmentType ?? 'Full-time') : (m['employment_type'] ?? 'Full-time');
                final baseSalary = m is LocalStaffData ? m.baseSalary : double.tryParse((m['base_salary'] ?? 0).toString()) ?? 0.0;
                final rating = m is LocalStaffData ? m.performanceRating : double.tryParse((m['performance_rating'] ?? 5.0).toString()) ?? 5.0;
                final isActive = m is LocalStaffData ? m.isActive : (m['is_active'] ?? true);
                return [
                  name,
                  role,
                  empType,
                  currencyFormatter.format(baseSalary),
                  '$rating / 5.0',
                  isActive ? 'Active' : 'Inactive',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
            ),
            pw.SizedBox(height: 16),

            // Disciplinary & Query Breakdown Table
            if (queries.isNotEmpty) ...[
              pw.Text('INFRACTIONS & QUERY HISTORY', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Staff ID/Name', 'Category / Title', 'Deduction', 'Delegated Duty', 'Status', 'Date'],
                data: queries.map((q) {
                  final dynamic qDyn = q;
                  final String categoryStr = (qDyn.category != null) ? qDyn.category.toString().replaceAll('_', ' ').toUpperCase() : 'GENERAL';
                  final isDelegated = (qDyn.isTaskDelegated == true) ? 'YES' : 'NO';
                  return [
                    q.staffId,
                    '$categoryStr\n${q.title}',
                    currencyFormatter.format(q.deductionAmount),
                    isDelegated,
                    q.isResolved ? 'Resolved' : 'Active Penalty',
                    dateFormatter.format(q.issueDate),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
              ),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'RHF_Staff_Payroll_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildPdfKpiCard(String title, String value, PdfColor bgColor, PdfColor textColor) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(color: bgColor, borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 8, color: textColor, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 11, color: textColor, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
