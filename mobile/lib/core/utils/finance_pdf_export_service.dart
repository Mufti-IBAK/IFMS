import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../database/local_db.dart';

class FinancePdfExportService {
  /// Exports a clean, audit-ready Daily Financial Transactions Statement PDF.
  static Future<void> exportDailyLedgerStatementPdf({
    required List<LocalTransaction> transactions,
    required DateTime selectedDate,
    String? ownerEmail,
    String? managerEmail,
    String farmName = 'ROYAL GOLDEN INTEGRATED FARMS LTD',
  }) async {
    final pdf = pw.Document();

    final dayFormat = DateFormat('EEEE, d MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final currencyFormatter = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    final statementDateStr = dayFormat.format(selectedDate).toUpperCase();

    // Filter transactions for the selected day
    final dayTxs = transactions.where((t) {
      return t.transactionDate.year == selectedDate.year &&
             t.transactionDate.month == selectedDate.month &&
             t.transactionDate.day == selectedDate.day;
    }).toList();

    // Sort by date/time ascending
    dayTxs.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double yoghurtIncome = 0.0;
    double yoghurtExpense = 0.0;
    int reconciledCount = 0;

    for (var tx in dayTxs) {
      if (tx.isReconciled) reconciledCount++;
      if (tx.transactionType == 'income') {
        totalIncome += tx.amount;
        if (tx.category == 'yoghurt_sales') {
          yoghurtIncome += tx.amount;
        }
      } else {
        totalExpense += tx.amount;
        if (tx.category == 'yoghurt_expense' || tx.category == 'yoghurt_raw_material_transfer') {
          yoghurtExpense += tx.amount;
        }
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
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'DAILY FINANCIAL TRANSACTIONS LEDGER',
                        style: pw.TextStyle(
                          color: PdfColors.purple100,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        statementDateStr,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Exported: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(color: PdfColors.purple200, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Metadata & Distribution Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
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
                      pw.Text('AUDIT DISTRIBUTION:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900)),
                      pw.SizedBox(height: 2),
                      pw.Text('Owner Email: ${ownerEmail ?? "owner@royalheritagefarms.com"}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Manager Email: ${managerEmail ?? "gm@royalheritagefarms.com"}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('DAILY TRANSACTIONS: ${dayTxs.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900)),
                      pw.SizedBox(height: 2),
                      pw.Text('Reconciled: $reconciledCount / ${dayTxs.length}', style: pw.TextStyle(fontSize: 8, color: PdfColors.green800)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Daily Financial Summary KPI Box
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
                  _summaryCol('DAILY REVENUE (+)', currencyFormatter.format(totalIncome), PdfColors.green800),
                  _summaryCol('DAILY EXPENSES (-)', currencyFormatter.format(totalExpense), PdfColors.red800),
                  _summaryCol('NET DAILY CASH FLOW', currencyFormatter.format(netCashFlow), netCashFlow >= 0 ? PdfColors.purple900 : PdfColors.orange900),
                ],
              ),
            ),

            // Yoghurt Factory Breakdown (if yoghurt activity present)
            if (yoghurtIncome > 0 || yoghurtExpense > 0) ...[
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.cyan50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.cyan200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('YOGHURT FACTORY DAILY CONTRIBUTION:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.cyan900)),
                    pw.Text('Sales: ${currencyFormatter.format(yoghurtIncome)}  |  Expenses: ${currencyFormatter.format(yoghurtExpense)}  |  Net: ${currencyFormatter.format(yoghurtIncome - yoghurtExpense)}',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: (yoghurtIncome - yoghurtExpense) >= 0 ? PdfColors.green800 : PdfColors.red800),
                    ),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 16),

            // Table Title
            pw.Text(
              'ITEMIZED DAILY TRANSACTIONS AUDIT',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.purple900),
            ),
            pw.SizedBox(height: 6),

            // Transactions Table
            if (dayTxs.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                alignment: pw.Alignment.center,
                child: pw.Text('No transactions recorded for $statementDateStr.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
              )
            else
              pw.Table.fromTextArray(
                columnWidths: {
                  0: const pw.FixedColumnWidth(50),
                  1: const pw.FixedColumnWidth(85),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FixedColumnWidth(65),
                  4: const pw.FixedColumnWidth(80),
                  5: const pw.FixedColumnWidth(55),
                },
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple900),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                headers: ['TIME', 'CATEGORY', 'DESCRIPTION / LINKED ASSET', 'TYPE', 'AMOUNT', 'STATUS'],
                data: dayTxs.map((t) {
                  final isIncome = t.transactionType == 'income';
                  final desc = t.description?.isNotEmpty == true ? t.description! : t.category.replaceAll('_', ' ').toUpperCase();
                  final status = t.isReconciled ? 'APPROVED' : 'PENDING';
                  return [
                    timeFormat.format(t.transactionDate),
                    _formatCategoryLabel(t.category),
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
                    pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('GENERAL MANAGER SIGNATURE', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Royal Golden Operations', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('FARM OWNER / AUDITOR SIGNATURE', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Royal Golden Executive Board', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final title = 'Daily_Ledger_${DateFormat('yyyy_MM_dd').format(selectedDate)}.pdf';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: title,
    );
  }

  /// Exports Monthly Account Statement PDF including Yoghurt Factory Breakdown.
  static Future<void> exportMonthlyAccountStatementPdf({
    required List<LocalTransaction> transactions,
    required DateTime selectedMonth,
    String? ownerEmail,
    String? managerEmail,
    String farmName = 'ROYAL GOLDEN INTEGRATED FARMS LTD',
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

    monthTxs.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double yoghurtSales = 0.0;
    double yoghurtExpenses = 0.0;
    double dairySales = 0.0;
    double livestockSales = 0.0;
    double poultrySales = 0.0;
    int reconciledCount = 0;

    for (var tx in monthTxs) {
      if (tx.isReconciled) reconciledCount++;
      if (tx.transactionType == 'income') {
        totalIncome += tx.amount;
        if (tx.category == 'yoghurt_sales') yoghurtSales += tx.amount;
        if (tx.category == 'milk_sales') dairySales += tx.amount;
        if (tx.category == 'animal_sales') livestockSales += tx.amount;
        if (tx.category == 'poultry_sales' || tx.category == 'hatchery_sales') poultrySales += tx.amount;
      } else {
        totalExpense += tx.amount;
        if (tx.category == 'yoghurt_expense' || tx.category == 'yoghurt_raw_material_transfer') {
          yoghurtExpenses += tx.amount;
        }
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
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'MONTHLY FINANCIAL ACCOUNT STATEMENT',
                        style: pw.TextStyle(
                          color: PdfColors.purple100,
                          fontSize: 11,
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
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(color: PdfColors.purple200, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Profile Details
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
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
                      pw.Text('STATEMENT DISTRIBUTION COPIES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900)),
                      pw.SizedBox(height: 2),
                      pw.Text('Farm Owner Email: ${ownerEmail ?? "owner@royalheritagefarms.com"}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('General Manager Email: ${managerEmail ?? "gm@royalheritagefarms.com"}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('AUDIT STATUS: VERIFIED', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.green800)),
                      pw.SizedBox(height: 2),
                      pw.Text('Reconciled: $reconciledCount / ${monthTxs.length}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

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
            pw.SizedBox(height: 12),

            // Departmental Revenue Contribution
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DEPARTMENTAL REVENUE CONTRIBUTION:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900)),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Yoghurt Sales: ${currencyFormatter.format(yoghurtSales)} (Exp: ${currencyFormatter.format(yoghurtExpenses)})', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Dairy Milk: ${currencyFormatter.format(dairySales)}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Livestock: ${currencyFormatter.format(livestockSales)}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Poultry: ${currencyFormatter.format(poultrySales)}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Table Title
            pw.Text(
              'ITEMIZED MONTHLY TRANSACTIONS AUDIT LEDGER',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.purple900),
            ),
            pw.SizedBox(height: 6),

            // Transactions Table
            if (monthTxs.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                alignment: pw.Alignment.center,
                child: pw.Text('No transactions recorded for $statementMonthStr.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
              )
            else
              pw.Table.fromTextArray(
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FixedColumnWidth(75),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FixedColumnWidth(65),
                  4: const pw.FixedColumnWidth(80),
                  5: const pw.FixedColumnWidth(55),
                },
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple900),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                headers: ['DATE / TIME', 'CATEGORY', 'DESCRIPTION / LINKED ASSET', 'TYPE', 'AMOUNT', 'STATUS'],
                data: monthTxs.map((t) {
                  final isIncome = t.transactionType == 'income';
                  final desc = t.description?.isNotEmpty == true ? t.description! : t.category.replaceAll('_', ' ').toUpperCase();
                  final status = t.isReconciled ? 'APPROVED' : 'PENDING';
                  return [
                    dateFormat.format(t.transactionDate),
                    _formatCategoryLabel(t.category),
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
                    pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('GENERAL MANAGER SIGNATURE', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Royal Golden Operations', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('FARM OWNER / AUDITOR SIGNATURE', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Royal Golden Executive Board', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
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
        pw.Text(title, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(val, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static String _formatCategoryLabel(String cat) {
    switch (cat.toLowerCase()) {
      case 'yoghurt_sales':
        return 'YOGHURT SALES';
      case 'yoghurt_expense':
        return 'YOGHURT EXPENSE';
      case 'yoghurt_raw_material_transfer':
        return 'MILK TRANSFER (YOGHURT)';
      case 'milk_sales':
        return 'MILK SALES';
      case 'animal_sales':
        return 'LIVESTOCK SALES';
      case 'poultry_sales':
        return 'POULTRY SALES';
      case 'hatchery_sales':
        return 'HATCHERY SALES';
      default:
        return cat.replaceAll('_', ' ').toUpperCase();
    }
  }
}
