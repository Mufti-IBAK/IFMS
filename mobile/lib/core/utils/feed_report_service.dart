import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../core/database/local_db.dart';
import '../../features/inventory/inventory_repository.dart';

class FeedReportService {
  static final _currencyFmt = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
  static final _dateFmt = DateFormat('dd/MM/yyyy');

  static Future<void> generateFeedAnalyticsReport({
    required List<dynamic> items,
    required List<LocalFeedFormula> formulas,
    required List<LocalFeedConsumptionLog> consumptionLogs,
    required InventoryRepository repository,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // ── PAGE 1: FEED STOCK DASHBOARD ──
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _reportHeader('Feed Analytics Report', 'Stock Overview'),
        footer: (context) => _reportFooter(now, context),
        build: (context) => [
          _stockDashboard(items),
          pw.SizedBox(height: 20),
          _stockTable(items),
        ],
      ),
    );

    // ── PAGE 2: FEED FORMULA COST ANALYSIS ──
    for (var formula in formulas) {
      final ingredients = await repository.calculateFormulaCost(formula.id, formula.batchSize);
      if (ingredients.isEmpty) continue;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _reportHeader('Feed Formula Analysis', formula.name),
          footer: (context) => _reportFooter(now, context),
          build: (context) => [
            _formulaAnalysis(formula, ingredients),
          ],
        ),
      );
    }

    // ── PAGE 3: CONSUMPTION ANALYTICS ──
    if (consumptionLogs.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _reportHeader('Feed Analytics Report', 'Consumption Analysis'),
          footer: (context) => _reportFooter(now, context),
          build: (context) => [
            _consumptionAnalysis(consumptionLogs, items),
          ],
        ),
      );
    }

    // Print/share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'feed_analytics_${DateFormat('yyyyMMdd').format(now)}.pdf',
    );
  }

  // ══════════════════════════════════════════════
  // HEADER / FOOTER
  // ══════════════════════════════════════════════

  static pw.Widget _reportHeader(String title, String subtitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.green900)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: const pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
              pw.Text(subtitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
            ],
          ),
          pw.Text('IFMS', style: const pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
        ],
      ),
    );
  }

  static pw.Widget _reportFooter(DateTime generated, pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5, color: PdfColors.grey400)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(generated)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // PAGE 1: STOCK DASHBOARD
  // ══════════════════════════════════════════════

  static pw.Widget _stockDashboard(List<dynamic> items) {
    int total = items.length;
    int lowCount = 0;
    double totalValue = 0.0;

    for (var i in items) {
      final stock = double.tryParse(i['current_stock'].toString()) ?? 0.0;
      final threshold = double.tryParse(i['reorder_threshold'].toString()) ?? 0.0;
      final cost = double.tryParse(i['cost_per_unit'].toString()) ?? 0.0;
      totalValue += stock * cost;
      if (stock <= threshold) lowCount++;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.green200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _kpiBox('Total Feed Items', '$total', PdfColors.green900),
          _kpiBox('Low Stock Items', '$lowCount', lowCount > 0 ? PdfColors.red : PdfColors.green),
          _kpiBox('Total Stock Value', _currencyFmt.format(totalValue), PdfColors.blue900),
        ],
      ),
    );
  }

  static pw.Widget _kpiBox(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  static pw.Widget _stockTable(List<dynamic> items) {
    return pw.TableHelper.fromTextArray(
      headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green900),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignments: const {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      headers: const ['Item', 'Unit', 'Stock', 'Reorder At', 'Cost/Unit', 'Total Value'],
      data: items.map((i) {
        final stock = double.tryParse(i['current_stock'].toString()) ?? 0.0;
        final cost = double.tryParse(i['cost_per_unit'].toString()) ?? 0.0;
        return [
          i['name'] ?? '',
          i['unit'] ?? 'kg',
          stock.toStringAsFixed(1),
          (double.tryParse(i['reorder_threshold'].toString()) ?? 0.0).toStringAsFixed(1),
          _currencyFmt.format(cost),
          _currencyFmt.format(stock * cost),
        ];
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════
  // PAGE 2: FORMULA COST ANALYSIS
  // ══════════════════════════════════════════════

  static pw.Widget _formulaAnalysis(LocalFeedFormula formula, List<Map<String, dynamic>> ingredients) {
    final totalCost = ingredients.fold<double>(0.0, (s, c) => s + (c['line_cost'] as double));
    final totalPercent = ingredients.fold<double>(0.0, (s, c) => s + (c['percentage'] as double));
    final batchKg = formula.batchSize;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Batch Size: ${batchKg.toStringAsFixed(0)} kg', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_batchUnitLabel(formula.batchUnit), style: const pw.TextStyle(color: PdfColors.grey700)),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // Ingredients table
        pw.TableHelper.fromTextArray(
          headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellPadding: const pw.EdgeInsets.all(6),
          cellAlignments: const {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          headers: const ['Ingredient', 'Percentage', 'Quantity (kg)', 'Cost/kg', 'Line Cost (₦)'],
          data: ingredients.map((c) {
            return [
              c['feed_item_name'],
              '${(c['percentage'] as double).toStringAsFixed(1)}%',
              (c['quantity_kg'] as double).toStringAsFixed(1),
              _currencyFmt.format(c['cost_per_unit']),
              _currencyFmt.format(c['line_cost']),
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 16),

        // Summary box
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: const pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.fromBorderSide(pw.BorderSide(color: PdfColors.green300)),
          ),
          child: pw.Column(
            children: [
              _summaryRow('Total Percentage', '${totalPercent.toStringAsFixed(1)}%'),
              pw.SizedBox(height: 6),
              _summaryRow('Total Cost (${batchKg.toStringAsFixed(0)} kg)', _currencyFmt.format(totalCost)),
              pw.SizedBox(height: 6),
              _summaryRow('Cost per kg', batchKg > 0 ? _currencyFmt.format(totalCost / batchKg) : '—'),
              pw.SizedBox(height: 6),
              _summaryRow('Cost per Tonne', batchKg > 0 ? _currencyFmt.format(totalCost / batchKg * 1000) : '—'),
            ],
          ),
        ),

        if (formula.notes != null && formula.notes!.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text('Notes: ${formula.notes}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ],
    );
  }

  static pw.Widget _summaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
      ],
    );
  }

  static String _batchUnitLabel(String unit) {
    switch (unit) {
      case 'per_tonne':
        return 'Per Tonne';
      case 'per_100kg':
        return 'Per 100kg';
      default:
        return 'Custom';
    }
  }

  // ══════════════════════════════════════════════
  // PAGE 3: CONSUMPTION ANALYTICS
  // ══════════════════════════════════════════════

  static pw.Widget _consumptionAnalysis(List<LocalFeedConsumptionLog> logs, List<dynamic> items) {
    // Group by animal
    final byAnimal = <String, List<LocalFeedConsumptionLog>>{};
    for (var log in logs) {
      byAnimal.putIfAbsent(log.animalId, () => []).add(log);
    }

    // Compute per-animal totals
    final animalSummaries = <List<String>>[];
    double grandTotalKg = 0.0;
    double grandTotalCost = 0.0;

    for (var entry in byAnimal.entries) {
      double totalKg = 0.0;
      double totalCost = 0.0;
      final feedEntries = entry.value.length;

      for (var log in entry.value) {
        totalKg += log.quantityKg;
        final item = items.cast<Map<String, dynamic>?>().firstWhere(
          (i) => i?['id'] == log.feedItemId,
          orElse: () => null,
        );
        final costPer = double.tryParse(item?['cost_per_unit']?.toString() ?? '0') ?? 0.0;
        totalCost += log.quantityKg * costPer;
      }
      grandTotalKg += totalKg;
      grandTotalCost += totalCost;

      animalSummaries.add([
        entry.key.length > 12 ? '${entry.key.substring(0, 12)}...' : entry.key,
        '$feedEntries',
        totalKg.toStringAsFixed(1),
        _currencyFmt.format(totalCost),
      ]);
    }

    // Group by date for daily totals
    final byDate = <String, double>{};
    for (var log in logs) {
      final key = _dateFmt.format(log.logDate);
      byDate[key] = (byDate[key] ?? 0.0) + log.quantityKg;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Summary KPIs
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.blue200),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _kpiBox('Total Feedings', '${logs.length}', PdfColors.blue900),
              _kpiBox('Animals Fed', '${byAnimal.length}', PdfColors.green900),
              _kpiBox('Total Feed (kg)', grandTotalKg.toStringAsFixed(1), PdfColors.orange900),
              _kpiBox('Total Cost', _currencyFmt.format(grandTotalCost), PdfColors.red900),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Per-animal table
        pw.Text('Per-Animal Consumption', style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellPadding: const pw.EdgeInsets.all(6),
          headers: const ['Animal ID', 'Feedings', 'Total (kg)', 'Total Cost (₦)'],
          data: animalSummaries,
        ),
        pw.SizedBox(height: 20),

        // Daily totals
        if (byDate.isNotEmpty) ...[
          pw.Text('Daily Consumption Summary', style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: const ['Date', 'Total Feed Consumed (kg)'],
            data: byDate.entries.map((e) => [e.key, e.value.toStringAsFixed(1)]).toList(),
          ),
        ],
        pw.SizedBox(height: 16),

        // Grand total
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: const pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.fromBorderSide(pw.BorderSide(color: PdfColors.green300)),
          ),
          child: pw.Column(
            children: [
              _summaryRow('Grand Total Feed', '${grandTotalKg.toStringAsFixed(1)} kg'),
              pw.SizedBox(height: 4),
              _summaryRow('Grand Total Feed Cost', _currencyFmt.format(grandTotalCost)),
              if (byAnimal.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                _summaryRow('Avg Cost per Animal', _currencyFmt.format(grandTotalCost / byAnimal.length)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
