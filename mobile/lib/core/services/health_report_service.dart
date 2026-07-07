import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../database/local_db.dart';
import '../di/service_locator.dart';

class HealthReportService {
  static Future<void> generateReport({
    required DateTime startDate,
    required DateTime endDate,
    required String farmName,
  }) async {
    final db = sl<LocalDatabase>();
    
    // Fetch lookups
    final allAnimals = await db.select(db.localAnimals).get();
    final animalMap = {for (var a in allAnimals) a.id: a.tagId};
    
    final allMeds = await db.select(db.localMedications).get();
    final medMap = {for (var m in allMeds) m.id: m.name};

    // Adjust end date to include the whole day
    final adjustedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    // Fetch Medical Records
    final medicalRecords = await (db.select(db.localAnimalMedicalRecords)
      ..where((tbl) => tbl.treatmentDate.isBetweenValues(startDate, adjustedEndDate))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.treatmentDate)])).get();
      
    // Fetch Farm Events (Births and Mortality)
    final farmEvents = await (db.select(db.localFarmEvents)
      ..where((tbl) => tbl.eventDate.isBetweenValues(startDate, adjustedEndDate) & 
             (tbl.eventType.equals('birth') | tbl.eventType.equals('mortality')))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.eventDate)])).get();

    // Aggregations
    int totalBirths = farmEvents.where((e) => e.eventType == 'birth').length;
    int totalDeaths = farmEvents.where((e) => e.eventType == 'mortality').length;
    int totalTreated = medicalRecords.length;
    double totalMedCost = medicalRecords.fold(0.0, (sum, record) => sum + record.cost);
    
    // Generate PDF
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final currency = NumberFormat.currency(symbol: 'NGN ', decimalDigits: 2);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(farmName, startDate, adjustedEndDate, dateFormat),
          pw.SizedBox(height: 20),
          _buildSummaryCards(totalBirths, totalDeaths, totalTreated, totalMedCost, currency),
          pw.SizedBox(height: 20),
          if (medicalRecords.isNotEmpty) ...[
            _buildMedicalRecordsTable(medicalRecords, animalMap, medMap, dateFormat, currency),
            pw.SizedBox(height: 20),
          ],
          if (farmEvents.isNotEmpty) ...[
            _buildFarmEventsTable(farmEvents, dateFormat),
          ],
          if (medicalRecords.isEmpty && farmEvents.isEmpty)
            pw.Center(child: pw.Text('No health events recorded in this period.', style: const pw.TextStyle(color: PdfColors.grey))),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Health_Report_${dateFormat.format(startDate)}_to_${dateFormat.format(adjustedEndDate)}.pdf',
    );
  }

  static pw.Widget _buildHeader(String farmName, DateTime start, DateTime end, DateFormat format) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(farmName.toUpperCase(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
            pw.SizedBox(height: 4),
            pw.Text('General Health & Vitality Report', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Period: ${format.format(start)} to ${format.format(end)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCards(int births, int deaths, int treated, double cost, NumberFormat currency) {
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
          _summaryItem('New Births', '$births', isHighlight: true, color: PdfColors.green800),
          _summaryItem('Mortality', '$deaths', isHighlight: true, color: PdfColors.red800),
          _summaryItem('Animals Treated', '$treated'),
          _summaryItem('Total Med Cost', currency.format(cost)),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value, {bool isHighlight = false, PdfColor color = PdfColors.black}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: isHighlight ? color : PdfColors.black)),
      ],
    );
  }

  static pw.Widget _buildMedicalRecordsTable(List<LocalAnimalMedicalRecord> records, Map<String, String> animals, Map<String, String> meds, DateFormat format, NumberFormat currency) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Medical Treatments', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          context: null,
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
          cellPadding: const pw.EdgeInsets.all(6),
          headers: ['Date', 'Animal Tag', 'Condition', 'Medication', 'Dose', 'Cost'],
          data: records.map((r) {
            final animalTag = animals[r.animalId] ?? r.animalId;
            final medName = meds[r.medicationId] ?? 'Unknown';
            return [
              format.format(r.treatmentDate),
              animalTag,
              r.diagnosedCondition,
              medName,
              r.administeredDose.toString(),
              currency.format(r.cost),
            ];
          }).toList(),
        ),
      ]
    );
  }

  static pw.Widget _buildFarmEventsTable(List<LocalFarmEvent> events, DateFormat format) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Critical Farm Events (Births & Mortality)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          context: null,
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
          cellPadding: const pw.EdgeInsets.all(6),
          headers: ['Date', 'Event Type', 'Involved Animals', 'Description'],
          data: events.map((e) {
            return [
              format.format(e.eventDate),
              e.eventType.toUpperCase(),
              e.involvedAnimals ?? 'None',
              e.description,
            ];
          }).toList(),
        ),
      ]
    );
  }
}
