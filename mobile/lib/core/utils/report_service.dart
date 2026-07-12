import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../database/local_db.dart';

class ReportService {
  static Future<void> generateHerdReport(List<LocalAnimal> animals) async {
    final pdf = pw.Document();
    
    // Summary counts
    int total = animals.length;
    int dead = 0;
    int male = 0;
    int female = 0;
    
    final speciesCounts = <String, int>{};
    final speciesTotalWeight = <String, double>{};
    final speciesWeightCount = <String, int>{};
    final reproCounts = <String, int>{};

    for (var a in animals) {
      final status = a.status.toLowerCase();
      final sex = (a.sex).toString().toLowerCase();
      final sp = (a.species).toString().toLowerCase();
      final repro = (a.currentReproductiveStatus).toString().toLowerCase();
      final weightRaw = a.weight;

      if (status == 'dead') {
        dead++;
      } else {
        if (sex == 'male') {
          male++;
        } else {
          female++;
        }
        
        speciesCounts[sp] = (speciesCounts[sp] ?? 0) + 1;

        if (weightRaw != null) {
          final weight = double.tryParse(weightRaw.toString());
          if (weight != null) {
            speciesTotalWeight[sp] = (speciesTotalWeight[sp] ?? 0.0) + weight;
            speciesWeightCount[sp] = (speciesWeightCount[sp] ?? 0) + 1;
          }
        }

        reproCounts[repro] = (reproCounts[repro] ?? 0) + 1;
      }
    }

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    // Map species keys to display names and hex colors
    final speciesMetaData = {
      'bovine': {'name': 'Cattle (Bovine)', 'color': '#004D40'},
      'avian': {'name': 'Poultry (Avian)', 'color': '#FFB300'},
      'caprine': {'name': 'Goats (Caprine)', 'color': '#D81B60'},
      'ovine': {'name': 'Sheep (Ovine)', 'color': '#5E35B1'},
      'feline': {'name': 'Cats (Feline)', 'color': '#E53935'},
      'canine': {'name': 'Dogs (Canine)', 'color': '#1E88E5'},
      'leprine': {'name': 'Rabbits (Leprine)', 'color': '#43A047'},
      'other': {'name': 'Others', 'color': '#757575'},
    };

    final activeCount = total - dead;

    // --- PAGE 1: STATISTICAL ANALYSIS & INSIGHTS ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('NAMANZO FARMS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                      pw.Text('INTEGRATED FARM MANAGEMENT SYSTEM (IFMS)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('HERD STATISTICAL ANALYSIS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#005C4B'))),
                      pw.Text('Generated: $dateStr', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('#005C4B')),
              pw.SizedBox(height: 12),

              // KPI Row
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

              // Statistics Panels
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left side: Species Distribution Progress Bars
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      height: 150,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('SPECIES DISTRIBUTION ANALYSIS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                          pw.SizedBox(height: 8),
                          if (speciesCounts.isEmpty)
                            pw.Text('No active species recorded.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600))
                          else
                            ...speciesCounts.entries.map((entry) {
                              final sp = entry.key;
                              final count = entry.value;
                              final pct = activeCount > 0 ? count / activeCount : 0.0;
                              final meta = speciesMetaData[sp] ?? {'name': sp, 'color': '#757575'};
                              return _buildProgressBar(meta['name']!, count, pct, meta['color']!);
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),

                  // Right side: Sex Ratio & Breakdowns
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      children: [
                        // Sex ratio summary
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('SEX DISTRIBUTION RATIO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                              pw.SizedBox(height: 6),
                              _buildProgressBar('Females', female, activeCount > 0 ? female / activeCount : 0.0, '#C2185B'),
                              _buildProgressBar('Males', male, activeCount > 0 ? male / activeCount : 0.0, '#1976D2'),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 12),

                        // Double breakdown columns
                        pw.Container(
                          width: double.infinity,
                          height: 86,
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Repro Breakdown
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('REPRODUCTIVE METRICS', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                                    pw.SizedBox(height: 4),
                                    if (reproCounts.isEmpty)
                                      pw.Text('No status recorded.', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600))
                                    else
                                      ...reproCounts.entries.take(4).map((entry) {
                                        return pw.Padding(
                                          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                                          child: pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Text(entry.key.toUpperCase(), style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
                                              pw.Text(entry.value.toString(), style: const pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),
                              pw.SizedBox(width: 12),
                              pw.VerticalDivider(width: 1, thickness: 0.5, color: PdfColors.grey300),
                              pw.SizedBox(width: 12),

                              // Avg weight
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('AVERAGE SPECIES WEIGHT', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                                    pw.SizedBox(height: 4),
                                    if (speciesTotalWeight.isEmpty)
                                      pw.Text('No weight records.', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600))
                                    else
                                      ...speciesTotalWeight.entries.take(4).map((entry) {
                                        final sp = entry.key;
                                        final totalW = entry.value;
                                        final wCount = speciesWeightCount[sp] ?? 1;
                                        final avg = totalW / wCount;
                                        final meta = speciesMetaData[sp] ?? {'name': sp};
                                        final metaName = meta['name']!.toString().split(' ')[0];
                                        return pw.Padding(
                                          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                                          child: pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                               pw.Text(metaName.toUpperCase(), style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
                                               pw.Text('${avg.toStringAsFixed(0)} kg', style: const pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.Spacer(),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CONFIDENTIAL - NAMANZO FARMS STATISTICAL ANALYSIS', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                  pw.Text('Page 1', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                ],
              ),
            ],
          );
        },
      ),
    );

    // --- PAGE 2+: DETAILED HERD REGISTRY TABLE ---
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
                      pw.Text('INTEGRATED FARM MANAGEMENT SYSTEM (IFMS)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('FARM REGISTRY REPORT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#005C4B'))),
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
                  pw.Text('Page ${context.pageNumber}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['Tag ID', 'Species', 'Breed', 'Sex', 'DOB', 'Weight', 'Repro Status', 'Purpose', 'Vaccination Notes', 'Deworming Notes', 'Status'],
              data: animals.map((a) {
                final tagId = a.tagId;
                final species = a.species;
                final breed = a.breed ?? 'N/A';
                final sex = a.sex;
                
                final dobDt = a.dateOfBirth;
                String dobStr = '';
                if (dobDt != null) {
                  dobStr = DateFormat('yyyy-MM-dd').format(dobDt);
                }
                
                final weight = a.weight?.toString() ?? 'N/A';
                final repro = a.currentReproductiveStatus;
                final purpose = a.purpose ?? 'N/A';
                final vac = a.vaccinationStatus ?? 'None';
                final dew = a.dewormingStatus ?? 'None';
                final status = a.status;
                
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

  static pw.Widget _buildProgressBar(String label, int count, double percentage, String hexColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 75,
            child: pw.Text(
              label.toUpperCase(),
              style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
          ),
          pw.Expanded(
            child: pw.Row(
              children: [
                if (percentage > 0.0)
                  pw.Expanded(
                    flex: (percentage * 1000).round().clamp(1, 1000),
                    child: pw.Container(
                      height: 6,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex(hexColor),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                    ),
                  ),
                if (percentage < 1.0)
                  pw.Expanded(
                    flex: ((1.0 - percentage) * 1000).round().clamp(1, 1000),
                    child: pw.Container(
                      height: 6,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 45,
            child: pw.Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> generateAnimalProfileReport({
    required LocalAnimal animal,
    required List<LocalMilkRecord> milkRecords,
    required List<Map<String, dynamic>> feedLogs,
    required List<Map<String, dynamic>> medRecords,
    required List<dynamic> breedingEvents,
  }) async {
    final pdf = pw.Document();

    final tagId = animal.tagId.toString();
    final species = animal.species.toString().toUpperCase();
    final sex = animal.sex.toString().toUpperCase();
    final breed = (animal.breed ?? 'Crossbreed').toString();
    
    final dob = animal.dateOfBirth;
    final dobStr = dob != null ? DateFormat('yyyy-MM-dd').format(dob) : 'Unknown';

    final weight = animal.weight?.toString() ?? 'N/A';
    final purpose = (animal.purpose ?? 'General').toString().toUpperCase();
    final marks = (animal.uniqueMarks ?? 'None').toString();
    final pedigree = (animal.pedigreeType ?? 'Commercial').toString().toUpperCase();
    final status = (animal.currentReproductiveStatus).toString().toUpperCase();

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    // Expense calculations
    final double medExpense = medRecords.fold<double>(0.0, (s, r) => s + (double.tryParse(r['cost'].toString()) ?? 0.0));
    final double feedExpense = feedLogs.fold<double>(0.0, (s, l) => s + (double.tryParse(l['qty'].toString()) ?? 0.0) * 150.0); // Assume feed cost per kg estimate
    final double totalExpense = medExpense + feedExpense;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('NAMANZO FARMS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                      pw.Text('ANIMAL INDIVIDUAL DOSSIER', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('ANIMAL PROFILE: #$tagId', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#005C4B'))),
                      pw.Text('Exported: $dateStr', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('#005C4B')),
              pw.SizedBox(height: 16),

              // Specifications Table
              pw.Text('1. PROFILE SPECIFICATIONS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tag ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(tagId, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Species', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(species, style: const pw.TextStyle(fontSize: 9))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Sex', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(sex, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Breed', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(breed, style: const pw.TextStyle(fontSize: 9))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Date of Birth', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(dobStr, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Current Weight', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$weight kg', style: const pw.TextStyle(fontSize: 9))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Purpose', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(purpose, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Reproductive Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(status, style: const pw.TextStyle(fontSize: 9))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pedigree Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(pedigree, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Unique Marks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(marks, style: const pw.TextStyle(fontSize: 9))),
                  ]),
                ],
              ),
              pw.SizedBox(height: 16),

              // Economics Card
              pw.Text('2. ECONOMIC METRICS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E0F2F1'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColor.fromHex('#004D40'), width: 0.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ESTIMATED FEED EXPENSE', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text('NGN ${feedExpense.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColor.fromHex('#004D40'))),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PHARMACY & MEDICAL TREATMENT', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text('NGN ${medExpense.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColor.fromHex('#004D40'))),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('TOTAL CUMULATIVE OUTLAY', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text('NGN ${totalExpense.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.red900)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Health Treatment Table
              pw.Text('3. CLINICAL TREATMENT LOGS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
              pw.SizedBox(height: 8),
              if (medRecords.isEmpty)
                pw.Text('No clinical treatments logged.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600))
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Diagnosis / Condition', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Drug Administered', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Dose', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Cost (NGN)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                      ],
                    ),
                    ...medRecords.take(8).map((m) {
                      final date = DateFormat('yyyy-MM-dd').format(m['date'] as DateTime);
                      return pw.TableRow(children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(date, style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(m['condition'].toString(), style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(m['medication_name'].toString(), style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${m['dose']} ${m['unit']}', style: const pw.TextStyle(fontSize: 8))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(double.parse(m['cost'].toString()).toStringAsFixed(2), style: const pw.TextStyle(fontSize: 8))),
                      ]);
                    }),
                  ],
                ),
            ],
          );
        },
      ),
    );

    // Second Page: Milk, Feed and Breeding tables
    if (milkRecords.isNotEmpty || feedLogs.isNotEmpty || breedingEvents.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ANIMAL ACTIVITY LOGS (CONTINUED)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                pw.SizedBox(height: 6),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 12),

                // Milk Table (if Cow)
                if (milkRecords.isNotEmpty) ...[
                  pw.Text('4. RECENT MILK PRODUCTION HISTORY', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Milking Session', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Quantity (Liters)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Safety Withdrawal Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                        ],
                      ),
                      ...milkRecords.take(8).map((r) {
                        return pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(DateFormat('yyyy-MM-dd').format(r.recordDate), style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(r.milkingSession.toUpperCase(), style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(r.quantityLiters.toStringAsFixed(1), style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(r.isWithdrawn ? 'WITHDRAWN (WARNING)' : 'SAFE (COMMERCIAL)', style: pw.TextStyle(fontSize: 8, color: r.isWithdrawn ? PdfColors.orange900 : PdfColors.green900, fontWeight: pw.FontWeight.bold))),
                        ]);
                      }),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                ],

                // Feed Table
                if (feedLogs.isNotEmpty) ...[
                  pw.Text('5. RECENT NUTRITION & FEED CONSUMPTION', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Feed Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Quantity Consumed (kg)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                        ],
                      ),
                      ...feedLogs.take(8).map((l) {
                        return pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(DateFormat('yyyy-MM-dd').format(l['date'] as DateTime), style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l['feed_name'].toString(), style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l['qty'].toString(), style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l['notes'].toString(), style: const pw.TextStyle(fontSize: 8))),
                        ]);
                      }),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                ],

                // Breeding Events Table
                if (breedingEvents.isNotEmpty) ...[
                  pw.Text('6. REPRODUCTIVE HISTORY & BREEDING EVENTS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#004D40'))),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Event Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Result Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Notes / Observations', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                        ],
                      ),
                      ...breedingEvents.take(8).map((e) {
                        final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(e['event_date'].toString()));
                        return pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(date, style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e['event_type'].toString().replaceAll('_', ' ').toUpperCase(), style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e['result']?.toString() ?? 'N/A', style: const pw.TextStyle(fontSize: 8))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e['notes']?.toString() ?? '', style: const pw.TextStyle(fontSize: 8))),
                        ]);
                      }),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
