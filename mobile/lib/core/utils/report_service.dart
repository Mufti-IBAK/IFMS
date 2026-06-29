import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReportService {
  static Future<void> generateHerdReport(List<dynamic> animals) async {
    final pdf = pw.Document();
    
    // Summary counts
    int total = animals.length;
    int dead = 0;
    int male = 0;
    int female = 0;
    
    for (var a in animals) {
      final isMap = a is Map;
      final status = ((isMap ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
      final sex = ((isMap ? a['sex'] : a.sex) ?? 'female').toString().toLowerCase();
      if (status == 'dead') {
        dead++;
      }
      if (sex == 'male') {
        male++;
      } else {
        female++;
      }
    }

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('NAMANZO FARMS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                      pw.Text('INTEGRATED FARM MANAGEMENT SYSTEM (IFMS)', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('HERD REGISTRY REPORT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#005C4B'))),
                      pw.Text('Generated: $dateStr', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('#005C4B')),
              pw.SizedBox(height: 12),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CONFIDENTIAL - FOR INTERNAL USE ONLY', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                  pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // KPI Summary Cards row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildKpiCard('Total Population', total.toString(), '#005C4B'),
                _buildKpiCard('Active Females', female.toString(), '#C2185B'),
                _buildKpiCard('Active Males', male.toString(), '#1976D2'),
                _buildKpiCard('Deceased Status', dead.toString(), '#E64A19'),
              ],
            ),
            pw.SizedBox(height: 16),
            
            // Animals Table
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['Tag ID', 'Species', 'Breed', 'Sex', 'DOB', 'Weight', 'Repro Status', 'Purpose', 'Vaccination Notes', 'Deworming Notes', 'Status'],
              data: animals.map((a) {
                final isMap = a is Map;
                final tagId = (isMap ? a['tag_id'] : a.tagId) ?? '';
                final species = (isMap ? a['species'] : a.species) ?? '';
                final breed = (isMap ? a['breed'] : a.breed) ?? 'N/A';
                final sex = (isMap ? a['sex'] : a.sex) ?? '';
                
                final dobRaw = isMap ? a['date_of_birth'] : a.dateOfBirth;
                String dobStr = '';
                if (dobRaw != null) {
                  final dobDt = dobRaw is DateTime ? dobRaw : DateTime.tryParse(dobRaw.toString());
                  if (dobDt != null) {
                    dobStr = DateFormat('yyyy-MM-dd').format(dobDt);
                  } else {
                    dobStr = dobRaw.toString().split('T')[0];
                  }
                }
                
                final weight = (isMap ? a['weight'] : a.weight)?.toString() ?? 'N/A';
                final repro = (isMap ? a['current_reproductive_status'] : a.currentReproductiveStatus) ?? 'open';
                final purpose = (isMap ? a['purpose'] : a.purpose) ?? 'N/A';
                final vac = (isMap ? a['vaccination_status'] : a.vaccinationStatus) ?? 'None';
                final dew = (isMap ? a['deworming_status'] : a.dewormingStatus) ?? 'None';
                final status = (isMap ? a['status'] : a.status) ?? 'active';
                
                return [
                  '#$tagId',
                  species.toString().toUpperCase(),
                  breed,
                  sex.toString().toUpperCase(),
                  dobStr,
                  weight != 'N/A' ? '${weight}kg' : 'N/A',
                  repro.toString().toUpperCase(),
                  purpose.toString().toUpperCase(),
                  vac,
                  dew,
                  status.toString().toUpperCase(),
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#005C4B')),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellHeight: 22,
              rowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey50,
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.white,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.centerLeft,
                9: pw.Alignment.centerLeft,
                10: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildKpiCard(String label, String value, String hexColor) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex(hexColor),
            ),
          ),
        ],
      ),
    );
  }
}
