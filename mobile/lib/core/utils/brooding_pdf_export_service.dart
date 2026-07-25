import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class BroodingPdfExportService {
  static Future<void> exportBroodingBatchPdf({
    required dynamic batch,
    required List<dynamic> logs,
    required double totalAccumulatedCost,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm');

    final String batchNumber = (batch is Map ? batch['batchNumber'] ?? batch['batch_number'] : batch.batchNumber)?.toString() ?? 'N/A';
    final String penName = (batch is Map ? batch['penName'] ?? batch['pen_name'] : batch.penName)?.toString() ?? 'N/A';
    final String breed = (batch is Map ? batch['breed'] : batch.breed)?.toString() ?? 'Chicks';
    final String chickSource = (batch is Map ? batch['chickSource'] ?? batch['chick_source'] : batch.chickSource)?.toString() ?? 'N/A';
    final String status = (batch is Map ? batch['status'] : batch.status)?.toString() ?? 'brooding';
    
    final int initialCount = (batch is Map ? batch['initialCount'] ?? batch['initial_count'] : batch.initialCount) ?? 0;
    final int currentCount = (batch is Map ? batch['currentCount'] ?? batch['current_count'] : batch.currentCount) ?? 0;
    final int totalLoss = initialCount - currentCount;
    final double mortalityPct = initialCount > 0 ? (totalLoss / initialCount * 100) : 0.0;

    final DateTime startDate = batch is Map 
        ? (batch['startDate'] is DateTime ? batch['startDate'] : DateTime.parse(batch['startDate'].toString()))
        : batch.startDate;
    final DateTime targetGraduationDate = batch is Map 
        ? (batch['targetGraduationDate'] is DateTime ? batch['targetGraduationDate'] : DateTime.parse(batch['targetGraduationDate'].toString()))
        : batch.targetGraduationDate;

    final int ageDays = DateTime.now().difference(startDate).inDays;

    double totalFeedKg = 0.0;
    double totalFeedCost = 0.0;
    double totalMedCost = 0.0;
    int totalMortality = 0;
    int totalCulls = 0;

    for (var l in logs) {
      final feedKg = (l is Map ? l['starterFeedKg'] ?? l['starter_feed_kg'] : l.starterFeedKg) ?? 0.0;
      final feedCost = (l is Map ? l['feedCost'] ?? l['feed_cost'] : l.feedCost) ?? 0.0;
      final medCost = (l is Map ? l['medicationCost'] ?? l['medication_cost'] : l.medicationCost) ?? 0.0;
      final mort = (l is Map ? l['mortalityCount'] ?? l['mortality_count'] : l.mortalityCount) ?? 0;
      final cull = (l is Map ? l['cullCount'] ?? l['cull_count'] : l.cullCount) ?? 0;

      totalFeedKg += (feedKg as num).toDouble();
      totalFeedCost += (feedCost as num).toDouble();
      totalMedCost += (medCost as num).toDouble();
      totalMortality += (mort as num).toInt();
      totalCulls += (cull as num).toInt();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ROYAL HERITAGE FARMS',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.purple900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'BROODING BATCH PERFORMANCE PROFILE',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.Text(
                      'Batch #: $batchNumber | Pen: $penName',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: status == 'brooding' ? PdfColors.purple100 : PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        status.toUpperCase(),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: status == 'brooding' ? PdfColors.purple900 : PdfColors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Report Date: ${dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.purple300, thickness: 1.5),
            pw.SizedBox(height: 12),

            // Overview KPI Cards Table
            pw.Text('Batch Overview & Metrics', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900)),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.purple50),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Breed / Strain', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(breed, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Chick Origin', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(chickSource.replaceAll('_', ' ').toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Brooding Start Date', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(dateFormat.format(startDate), style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Target Graduation Date', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(dateFormat.format(targetGraduationDate), style: const pw.TextStyle(fontSize: 10))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Current Age', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$ageDays Days (${ageDays ~/ 7} Weeks)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Chick Population', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$currentCount / $initialCount alive', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Mortality Rate', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${mortalityPct.toStringAsFixed(1)}% ($totalLoss lost)', style: pw.TextStyle(fontSize: 10, color: mortalityPct > 5 ? PdfColors.red800 : PdfColors.green800))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total Accumulated Cost', style: const pw.TextStyle(fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('NGN ${totalAccumulatedCost.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800))),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // Cost & Consumption Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Total Feed Consumed', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('${totalFeedKg.toStringAsFixed(1)} kg', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Total Feed Cost', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('NGN ${totalFeedCost.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Total Vaccines & Meds Cost', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('NGN ${totalMedCost.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Total Deaths / Culls', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('$totalMortality d / $totalCulls c', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),
            pw.Text('Daily Environmental & Health Logs (${logs.length} Entries)', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900)),
            pw.SizedBox(height: 8),

            // Daily Logs Table
            if (logs.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                alignment: pw.Alignment.center,
                child: pw.Text('No daily brooding entries logged yet.', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FixedColumnWidth(55),
                  2: const pw.FixedColumnWidth(85),
                  3: const pw.FlexColumnWidth(3),
                  4: const pw.FixedColumnWidth(45),
                  5: const pw.FixedColumnWidth(60),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.purple100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Log Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Temp (°C)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Feed (kg / NGN)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Vaccines / Medication', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Loss', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Avg Wt (g)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900))),
                    ],
                  ),
                  ...logs.map((l) {
                    final DateTime logDate = l is Map 
                        ? (l['logDate'] is DateTime ? l['logDate'] : DateTime.parse(l['logDate'].toString()))
                        : l.logDate;
                    final temp = (l is Map ? l['temperatureCelsius'] ?? l['temperature_celsius'] : l.temperatureCelsius);
                    final heat = (l is Map ? l['heatingStatus'] ?? l['heating_status'] : l.heatingStatus)?.toString();
                    final feedKg = (l is Map ? l['starterFeedKg'] ?? l['starter_feed_kg'] : l.starterFeedKg) ?? 0.0;
                    final feedCost = (l is Map ? l['feedCost'] ?? l['feed_cost'] : l.feedCost) ?? 0.0;
                    final medGiven = (l is Map ? l['medicationGiven'] ?? l['medication_given'] : l.medicationGiven)?.toString() ?? '-';
                    final medCost = (l is Map ? l['medicationCost'] ?? l['medication_cost'] : l.medicationCost) ?? 0.0;
                    final mort = (l is Map ? l['mortalityCount'] ?? l['mortality_count'] : l.mortalityCount) ?? 0;
                    final cull = (l is Map ? l['cullCount'] ?? l['cull_count'] : l.cullCount) ?? 0;
                    final weight = (l is Map ? l['averageWeightGrams'] ?? l['average_weight_grams'] : l.averageWeightGrams);

                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(timeFormat.format(logDate), style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(temp != null ? '$temp°C (${heat ?? "ON"})' : '-', style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('$feedKg kg (NGN $feedCost)', style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(medCost > 0 ? '$medGiven (NGN $medCost)' : medGiven, style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('$mort d / $cull c', style: pw.TextStyle(fontSize: 8, color: (mort + cull) > 0 ? PdfColors.red700 : PdfColors.black))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(weight != null ? '$weight g' : '-', style: const pw.TextStyle(fontSize: 8))),
                      ],
                    );
                  }),
                ],
              ),

            pw.SizedBox(height: 30),

            // Signatures Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 1)),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Brooder Pen Supervisor Signature', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 1)),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Farm Manager Approval & Date', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Brooding_Batch_${batchNumber}_Report.pdf',
    );
  }
}
