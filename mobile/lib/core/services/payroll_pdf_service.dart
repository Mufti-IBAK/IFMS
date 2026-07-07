import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PayrollPdfService {
  static Future<void> generatePayrollPdf({
    required List<dynamic> staff,
    required Map<String, dynamic> budget,
    required String farmName,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy').format(now);
    final currency = NumberFormat.currency(symbol: 'NGN ', decimalDigits: 2);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(farmName, monthYear),
          pw.SizedBox(height: 20),
          _buildSummaryCards(budget, currency),
          pw.SizedBox(height: 30),
          _buildStaffTable(staff, currency),
          pw.SizedBox(height: 40),
          _buildSignatureBlock(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Payroll_$monthYear.pdf',
    );
  }

  static pw.Widget _buildHeader(String farmName, String monthYear) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(farmName.toUpperCase(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
            pw.SizedBox(height: 4),
            pw.Text('Farm Payroll & Compensation Report', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Period: $monthYear', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCards(Map<String, dynamic> budget, NumberFormat currency) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Total Staff', '${budget['staff_count'] ?? 0}'),
          _summaryItem('Base Salary', currency.format(budget['total_base_salary'] ?? 0.0)),
          _summaryItem('Deductions', currency.format(budget['total_active_deductions'] ?? 0.0)),
          _summaryItem('Net Payable', currency.format(budget['net_salary_budget'] ?? 0.0), isHighlight: true),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value, {bool isHighlight = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: isHighlight ? PdfColors.teal800 : PdfColors.black)),
      ],
    );
  }

  static pw.Widget _buildStaffTable(List<dynamic> staff, NumberFormat currency) {
    return pw.TableHelper.fromTextArray(
      context: null,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
      cellPadding: const pw.EdgeInsets.all(8),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      headers: ['Name', 'Role', 'Rating', 'Base Salary', 'Deductions', 'Net Pay'],
      data: staff.map((s) {
        final isMap = s is Map;
        final name = isMap ? s['name'] : s.name;
        final role = isMap ? s['role'] : s.role;
        final rating = isMap ? s['performance_rating'] : s.performanceRating;
        final base = isMap ? s['base_salary'] : s.baseSalary;
        final net = isMap ? (s['final_payout'] ?? base) : base;
        final deductions = base - net;
        return [
          name.toString(),
          role.toString(),
          '${rating.toString()}/5.0',
          currency.format(base),
          currency.format(deductions),
          currency.format(net),
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildSignatureBlock() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Farm Manager', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: ________________', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Finance Officer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: ________________', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
