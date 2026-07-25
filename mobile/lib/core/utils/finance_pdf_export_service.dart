import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../database/local_db.dart';

class FinancePdfExportService {
  static Future<void> exportMonthlyAccountStatementPdf({
    required List<LocalTransaction> transactions,
    required DateTime selectedMonth,
    String? ownerEmail,
    String? managerEmail,
    String farmName = 'ROYAL HERITAGE FARMS',
  }) async {
    final pdf = pw.Document();

    final monthFormat = DateFormat('MMMM yyyy');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final currencyFormatter = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    final statementMonthStr = monthFormat.format(selectedMonth).toUpperCase();

    // Filter transactions for selected month
    final monthTxs = transactions.where((t) {
      return t.transactionDate.year == selectedMonth.year &&
             t.transactionDate.month == selectedMonth.month;
    }).toList();

    // Sort by date ascending for statement order
    monthTxs.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var tx in monthTxs) {
      if (tx.transactionType == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    final netCashFlow = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Banner
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple900,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        farmName.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'MONTHLY FINANCIAL ACCOUNT STATEMENT',
                        style: pw.TextStyle(
                          color: PdfColors.purple100,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'PERIOD: $statementMonthStr',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(color: PdfColors.purple200, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Account Recipient & Profile Details
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('STATEMENT DISTRIBUTION COPIES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.purple900)),
                      pw.SizedBox(height: 2),
                      pw.Text('Farm Owner Email: ${ownerEmail ?? "owner@royalheritagefarms.com"}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('General Manager Email: ${managerEmail ?? "gm@royalheritagefarms.com"}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('ACCOUNT STATUS: VERIFIED', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.green800)),
                      pw.SizedBox(height: 2),
                      pw.Text('Total Transactions: ${monthTxs.length}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Financial Summary KPI Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.purple200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _summaryCol('TOTAL REVENUE (+)', currencyFormatter.format(totalIncome), PdfColors.green800),
                  _summaryCol('TOTAL EXPENSES (-)', currencyFormatter.format(totalExpense), PdfColors.red800),
                  _summaryCol('NET CASH FLOW', currencyFormatter.format(netCashFlow), netCashFlow >= 0 ? PdfColors.purple900 : PdfColors.orange900),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Transactions Table Title
            pw.Text(
              'ITEMIZED MONTHLY TRANSACTIONS AUDIT LEDGER',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.purple900),
            ),
            pw.SizedBox(height: 8),

            // Table of Transactions
            if (monthTxs.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                alignment: pw.Alignment.center,
                child: pw.Text('No transactions recorded for $statementMonthStr.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
              )
            else
              pw.Table.fromTextArray(
                columnWidths: {
                  0: const pw.FixedColumnWidth(85),
                  1: const pw.FixedColumnWidth(75),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FixedColumnWidth(65),
                  4: const pw.FixedColumnWidth(85),
                  5: const pw.FixedColumnWidth(60),
                },
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple900),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                headers: ['DATE / TIME', 'CATEGORY', 'DESCRIPTION / LINKED ASSET', 'TYPE', 'AMOUNT', 'STATUS'],
                data: monthTxs.map((t) {
                  final isIncome = t.transactionType == 'income';
                  final desc = t.description?.isNotEmpty == true ? t.description! : t.category.replaceAll('_', ' ').toUpperCase();
                  final status = t.isReconciled ? 'APPROVED' : 'PENDING';
                  return [
                    dateFormat.format(t.transactionDate),
                    t.category.replaceAll('_', ' ').toUpperCase(),
                    desc,
                    isIncome ? 'INCOME (+)' : 'EXPENSE (-)',
                    '${isIncome ? '+' : '-'}${currencyFormatter.format(t.amount)}',
                    status,
                  ];
                }).toList(),
              ),

            pw.SizedBox(height: 24),

            // Sign-off / Signature Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('GENERAL MANAGER SIGNATURE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Royal Heritage Operations', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('FARM OWNER / AUDITOR SIGNATURE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Royal Heritage Executive Board', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final title = 'Account_Statement_${statementMonthStr.replaceAll(' ', '_')}.pdf';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: title,
    );
  }

  static pw.Widget _summaryCol(String title, String val, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(val, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}
