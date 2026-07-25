import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class TaskPdfExportService {
  static Future<void> exportTasksPdf({
    required List<dynamic> tasks,
    required String filterTitle,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm');

    int totalTasks = tasks.length;
    int completedCount = 0;
    int pendingCount = 0;
    int upcomingCount = 0;

    final List<dynamic> completedList = [];
    final List<dynamic> pendingList = [];
    final List<dynamic> upcomingList = [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var task in tasks) {
      final status = (task is Map ? task['status'] : task.status)?.toString() ?? 'pending';
      if (status == 'completed') {
        completedCount++;
        completedList.add(task);
      } else {
        DateTime? dueDate;
        final dueDateRaw = task is Map ? task['due_date'] ?? task['dueDate'] : task.dueDate;
        if (dueDateRaw != null) {
          dueDate = dueDateRaw is DateTime ? dueDateRaw : DateTime.tryParse(dueDateRaw.toString());
        }

        if (dueDate == null) {
          upcomingCount++;
          upcomingList.add(task);
        } else {
          final taskDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
          if (taskDay.isAtSameMomentAs(today) || taskDay.isBefore(today)) {
            pendingCount++;
            pendingList.add(task);
          } else {
            upcomingCount++;
            upcomingList.add(task);
          }
        }
      }
    }

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
                        'ROYAL HERITAGE FARMS',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'TASK & OPERATIONS LOG REPORT',
                        style: pw.TextStyle(
                          color: PdfColors.teal100,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Scope: $filterTitle',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Generated: ${timeFormat.format(now)}',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Summary Stats Cards
            pw.Row(
              children: [
                _buildPdfStatBox('Total Tasks', totalTasks.toString(), PdfColors.blueGrey800),
                pw.SizedBox(width: 8),
                _buildPdfStatBox('Completed', completedCount.toString(), PdfColors.green700),
                pw.SizedBox(width: 8),
                _buildPdfStatBox('Pending / Due', pendingCount.toString(), PdfColors.amber800),
                pw.SizedBox(width: 8),
                _buildPdfStatBox('Upcoming', upcomingCount.toString(), PdfColors.blue700),
              ],
            ),
            pw.SizedBox(height: 20),

            // 1. Pending Tasks Section
            pw.Text(
              '1. PENDING & OVERDUE OPERATIONS (${pendingList.length})',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900),
            ),
            pw.SizedBox(height: 6),
            if (pendingList.isEmpty)
              pw.Text('No pending tasks for this period.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
            else
              _buildTaskTable(pendingList, dateFormat),
            pw.SizedBox(height: 16),

            // 2. Upcoming Tasks Section
            pw.Text(
              '2. UPCOMING SCHEDULED OPERATIONS (${upcomingList.length})',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 6),
            if (upcomingList.isEmpty)
              pw.Text('No upcoming scheduled tasks.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
            else
              _buildTaskTable(upcomingList, dateFormat),
            pw.SizedBox(height: 16),

            // 3. Completed Operations Log Section
            pw.Text(
              '3. COMPLETED OPERATIONS LOG HISTORY (${completedList.length})',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
            ),
            pw.SizedBox(height: 6),
            if (completedList.isEmpty)
              pw.Text('No completed operations logged for this period.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
            else
              _buildTaskTable(completedList, dateFormat),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Royal_Heritage_Farm_Tasks_Log.pdf',
    );
  }

  static pw.Widget _buildPdfStatBox(String label, String val, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            pw.Text(val, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 2),
            pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTaskTable(List<dynamic> list, DateFormat dateFormat) {
    return pw.TableHelper.fromTextArray(
      columnWidths: {
        0: const pw.FixedColumnWidth(70),
        1: const pw.FixedColumnWidth(65),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FixedColumnWidth(70),
        4: const pw.FixedColumnWidth(55),
        5: const pw.FixedColumnWidth(60),
      },
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      headers: ['Due Date', 'Category', 'Task Title', 'Assignee', 'Priority', 'Status'],
      data: list.map((t) {
        final title = (t is Map ? t['title'] : t.title)?.toString() ?? '';
        final category = (t is Map ? t['category'] : t.category)?.toString() ?? 'other';
        final priority = (t is Map ? t['priority'] : t.priority)?.toString() ?? 'medium';
        final status = (t is Map ? t['status'] : t.status)?.toString() ?? 'pending';
        final assignee = (t is Map ? t['assignedTo'] ?? t['assigned_to'] : t.assignedTo)?.toString() ?? 'personal';

        final dueDateRaw = t is Map ? t['due_date'] ?? t['dueDate'] : t.dueDate;
        String dateStr = 'No date';
        if (dueDateRaw != null) {
          final dt = dueDateRaw is DateTime ? dueDateRaw : DateTime.tryParse(dueDateRaw.toString());
          if (dt != null) dateStr = dateFormat.format(dt);
        }

        return [
          dateStr,
          category.toUpperCase().replaceAll('_', ' '),
          title,
          assignee.toUpperCase(),
          priority.toUpperCase(),
          status.toUpperCase(),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
    );
  }
}
