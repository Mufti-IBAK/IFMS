import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/dairy/dairy_bloc.dart';

class DairyPdfExportService {
  static Future<void> exportDairyReportPdf({
    required DairyLoaded dairyData,
    String farmName = 'ROYAL HERITAGE FARMS',
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm');
    final currencyFormatter = NumberFormat.currency(symbol: 'N', decimalDigits: 2);

    final String periodLabel = dairyData.currentFilter == AnalyticsFilter.daily
        ? 'DAILY ANALYSIS (${dateFormat.format(dairyData.selectedDashboardDate)})'
        : dairyData.currentFilter == AnalyticsFilter.weekly
            ? 'WEEKLY ANALYSIS'
            : 'MONTHLY ANALYSIS (${DateFormat('MMMM yyyy').format(dairyData.selectedDashboardDate)})';

    // Prepare Cow Breakdown List
    final cowBreakdownList = dairyData.cowYieldBreakdown.entries.toList();

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
                color: PdfColors.teal800,
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
                        'DAIRY & MILK PRODUCTION ANALYSIS REPORT',
                        style: pw.TextStyle(
                          color: PdfColors.teal100,
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
                        periodLabel,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated: ${timeFormat.format(DateTime.now())}',
                        style: const pw.TextStyle(color: PdfColors.teal200, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // KPI Overview Section
            pw.Text(
              'EXECUTIVE PRODUCTION & COMMERCIAL SUMMARY',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
            ),
            pw.SizedBox(height: 8),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildPdfKpiBox(
                    'TOTAL HARVESTED',
                    '${dairyData.totalCollectedLiters.toStringAsFixed(1)} Liters',
                    PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpiBox(
                    'AVAILABLE IN STORE',
                    '${dairyData.inStoreLiters.toStringAsFixed(1)} Liters',
                    PdfColors.teal700,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpiBox(
                    'TOTAL SOLD',
                    '${dairyData.totalSoldLiters.toStringAsFixed(1)} Liters',
                    PdfColors.orange700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildPdfKpiBox(
                    'COWS MILKED',
                    '${dairyData.cowsMilkedCount} Cows (${dairyData.averagePerCowDashboard.toStringAsFixed(1)} L/Cow)',
                    PdfColors.purple700,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpiBox(
                    'MEDICAL WITHDRAWN',
                    '${dairyData.totalWithdrawnLiters.toStringAsFixed(1)} Liters',
                    PdfColors.red700,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _buildPdfKpiBox(
                    'TOTAL REVENUE',
                    currencyFormatter.format(dairyData.totalRevenue),
                    PdfColors.green700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Cow Breakdown Table
            pw.Text(
              'HERD INDIVIDUAL YIELD PERFORMANCE BREAKDOWN',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
            ),
            pw.SizedBox(height: 8),

            if (cowBreakdownList.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Center(
                  child: pw.Text('No individual cow production records for this period.', style: const pw.TextStyle(fontSize: 10)),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      _buildHeaderCell('#', width: 30),
                      _buildHeaderCell('Cow Tag ID'),
                      _buildHeaderCell('Production (Liters)'),
                      _buildHeaderCell('Herd Share (%)'),
                    ],
                  ),
                  ...cowBreakdownList.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final cowTag = entry.value.key;
                    final yieldLiters = entry.value.value;
                    final share = dairyData.totalYieldForPeriod > 0
                        ? (yieldLiters / dairyData.totalYieldForPeriod) * 100
                        : 0.0;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: idx % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                      ),
                      children: [
                        _buildTableCell(idx.toString(), alignRight: false),
                        _buildTableCell(cowTag),
                        _buildTableCell('${yieldLiters.toStringAsFixed(1)} L'),
                        _buildTableCell('${share.toStringAsFixed(1)}%'),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 20),

            // Production Log Entries
            pw.Text(
              'MILK HARVEST LOG ENTRIES',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
            ),
            pw.SizedBox(height: 8),

            if (dairyData.dashboardRecords.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Center(
                  child: pw.Text('No milk harvest logs for this period.', style: const pw.TextStyle(fontSize: 10)),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      _buildHeaderCell('Date & Time'),
                      _buildHeaderCell('Cow Tag ID'),
                      _buildHeaderCell('Session'),
                      _buildHeaderCell('Quantity (L)'),
                      _buildHeaderCell('Status'),
                    ],
                  ),
                  ...dairyData.dashboardRecords.take(50).map((r) {
                    final tag = dairyData.animalTagMap[r.animalId] ?? r.animalId.substring(0, 8);
                    return pw.TableRow(
                      children: [
                        _buildTableCell(timeFormat.format(r.recordDate)),
                        _buildTableCell(tag),
                        _buildTableCell(r.milkingSession.toUpperCase()),
                        _buildTableCell('${r.quantityLiters.toStringAsFixed(1)} L'),
                        _buildTableCell(
                          r.isWithdrawn ? 'WITHDRAWN (DISCARD)' : 'OK (CLEAN)',
                          textColor: r.isWithdrawn ? PdfColors.red700 : PdfColors.green700,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 20),

            // Commercial Sales History
            pw.Text(
              'COMMERCIAL BULK MILK SALES HISTORY',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
            ),
            pw.SizedBox(height: 8),

            if (dairyData.salesHistory.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Center(
                  child: pw.Text('No bulk milk sales transactions recorded.', style: const pw.TextStyle(fontSize: 10)),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.green50),
                    children: [
                      _buildHeaderCell('Date'),
                      _buildHeaderCell('Description / Buyer'),
                      _buildHeaderCell('Revenue (N)'),
                    ],
                  ),
                  ...dairyData.salesHistory.take(30).map((tx) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(timeFormat.format(tx.transactionDate)),
                        _buildTableCell(tx.description ?? 'Bulk Milk Sale'),
                        _buildTableCell(currencyFormatter.format(tx.amount), textColor: PdfColors.green800),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 30),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('Farm Manager Signature', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('Veterinary Doctor Stamp', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Dairy_Analysis_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildPdfKpiBox(String title, String value, PdfColor accentColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        ],
      ),
    );
  }

  static pw.Widget _buildHeaderCell(String text, {double? width}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool alignRight = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, color: textColor ?? PdfColors.grey900),
      ),
    );
  }
}
