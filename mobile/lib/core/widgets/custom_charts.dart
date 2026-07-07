import 'package:flutter/material.dart';
import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// 1. CUSTOM LINE CHART
// ─────────────────────────────────────────────────────────────────────────────
class CustomLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final List<double>? targetLineData; // Optional baseline comparison
  final Color lineColor;
  final List<Color> gradientColors;
  final double height;
  final double strokeWidth;

  const CustomLineChart({
    super.key,
    required this.data,
    required this.labels,
    this.targetLineData,
    this.lineColor = const Color(0xFF1E88E5),
    this.gradientColors = const [Color(0x8090CAF9), Color(0x0090CAF9)],
    this.height = 160,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height, child: const Center(child: Text('No data')));
    
    final maxVal = max(data.reduce(max), 1.0) * 1.15;
    const minVal = 0.0;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: CustomPaint(
        size: Size(double.infinity, height - 16),
        painter: _LineChartPainter(
          data: data,
          labels: labels,
          targetLineData: targetLineData,
          maxVal: maxVal,
          minVal: minVal,
          lineColor: lineColor,
          gradientColors: gradientColors,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final List<double>? targetLineData;
  final double maxVal;
  final double minVal;
  final Color lineColor;
  final List<Color> gradientColors;
  final double strokeWidth;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.targetLineData,
    required this.maxVal,
    required this.minVal,
    required this.lineColor,
    required this.gradientColors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const paddingLeft = 32.0;
    const paddingBottom = 20.0;
    const paddingTop = 10.0;
    const paddingRight = 10.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 1. Draw horizontal grids & Y-axis labels
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = paddingTop + chartHeight - (chartHeight / gridLines) * i;
      final val = minVal + ((maxVal - minVal) / gridLines) * i;

      // Grid line
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      // Y-axis Label
      textPainter.text = TextSpan(
        text: val.toStringAsFixed(1),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 8, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 6, y - textPainter.height / 2));
    }

    final stepX = chartWidth / (data.length - 1);

    // 2. Draw Target Baseline (if provided)
    if (targetLineData != null && targetLineData!.length == data.length) {
      final targetPaint = Paint()
        ..color = Colors.grey.withOpacity(0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      final targetPath = Path();
      for (int i = 0; i < targetLineData!.length; i++) {
        final x = paddingLeft + i * stepX;
        final y = paddingTop + chartHeight - ((targetLineData![i] - minVal) / (maxVal - minVal)) * chartHeight;
        if (i == 0) {
          targetPath.moveTo(x, y);
        } else {
          targetPath.lineTo(x, y);
        }
      }
      canvas.drawPath(targetPath, targetPaint);
    }

    // 3. Construct Smooth Bezier Curve Path
    final path = Path();
    final fillPath = Path();

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = paddingLeft + i * stepX;
      final y = paddingTop + chartHeight - ((data[i] - minVal) / (maxVal - minVal)) * chartHeight;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        
        // Control points for smooth bezier curve
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
      }

      // Close fill path to bottom of chart
      fillPath.lineTo(points.last.dx, paddingTop + chartHeight);
      fillPath.lineTo(points.first.dx, paddingTop + chartHeight);
      fillPath.close();

      // 4. Paint Fill Gradient
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // 5. Paint Main Line Curve
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawPath(path, linePaint);

      // 6. Draw dots & X-axis labels
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      
      final dotOuterPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      for (int i = 0; i < points.length; i++) {
        canvas.drawCircle(points[i], 4, dotPaint);
        canvas.drawCircle(points[i], 4, dotOuterPaint);

        // Draw X label
        if (i < labels.length) {
          textPainter.text = TextSpan(
            text: labels[i],
            style: TextStyle(color: Colors.grey.shade600, fontSize: 8, fontWeight: FontWeight.bold),
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(points[i].dx - textPainter.width / 2, paddingTop + chartHeight + 6));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. CUSTOM BAR CHART (Grouped/Side-by-Side)
// ─────────────────────────────────────────────────────────────────────────────
class CustomBarChart extends StatelessWidget {
  final List<double> primaryData; // e.g. Revenue
  final List<double> secondaryData; // e.g. Expenses
  final List<String> labels;
  final Color primaryColor;
  final Color secondaryColor;
  final double height;

  const CustomBarChart({
    super.key,
    required this.primaryData,
    required this.secondaryData,
    required this.labels,
    this.primaryColor = const Color(0xFF2E7D32),
    this.secondaryColor = const Color(0xFFC62828),
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (primaryData.isEmpty) return SizedBox(height: height, child: const Center(child: Text('No data')));

    final allData = [...primaryData, ...secondaryData];
    final maxVal = max(allData.reduce(max), 1.0) * 1.15;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: CustomPaint(
        size: Size(double.infinity, height - 16),
        painter: _BarChartPainter(
          primaryData: primaryData,
          secondaryData: secondaryData,
          labels: labels,
          maxVal: maxVal,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> primaryData;
  final List<double> secondaryData;
  final List<String> labels;
  final double maxVal;
  final Color primaryColor;
  final Color secondaryColor;

  _BarChartPainter({
    required this.primaryData,
    required this.secondaryData,
    required this.labels,
    required this.maxVal,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const paddingLeft = 36.0;
    const paddingBottom = 20.0;
    const paddingTop = 10.0;
    const paddingRight = 10.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 1. Draw horizontal grids & Y-axis labels
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = paddingTop + chartHeight - (chartHeight / gridLines) * i;
      final val = (maxVal / gridLines) * i;

      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      textPainter.text = TextSpan(
        text: val >= 1000 ? '${(val / 1000).toStringAsFixed(0)}k' : val.toStringAsFixed(0),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 8, fontWeight: FontWeight.w600),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 6, y - textPainter.height / 2));
    }

    // 2. Draw Grouped Bars
    final groupCount = primaryData.length;
    final groupWidth = chartWidth / groupCount;
    const barSpacing = 2.0;
    final barWidth = (groupWidth * 0.5 - barSpacing) * 0.8;

    final pPaint = Paint()..color = primaryColor..style = PaintingStyle.fill;
    final sPaint = Paint()..color = secondaryColor..style = PaintingStyle.fill;

    for (int i = 0; i < groupCount; i++) {
      final groupCenterX = paddingLeft + i * groupWidth + groupWidth / 2;

      // Primary Bar Left Offset, Secondary Bar Right Offset
      final pHeight = (primaryData[i] / maxVal) * chartHeight;
      final sHeight = (secondaryData[i] / maxVal) * chartHeight;

      final pLeft = groupCenterX - barWidth - barSpacing / 2;
      final pRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(pLeft, paddingTop + chartHeight - pHeight, barWidth, pHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(pRect, pPaint);

      final sLeft = groupCenterX + barSpacing / 2;
      final sRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(sLeft, paddingTop + chartHeight - sHeight, barWidth, sHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(sRect, sPaint);

      // Group X-axis Label
      if (i < labels.length) {
        textPainter.text = TextSpan(
          text: labels[i],
          style: TextStyle(color: Colors.grey.shade700, fontSize: 8, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(groupCenterX - textPainter.width / 2, paddingTop + chartHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. CUSTOM DONUT CHART
// ─────────────────────────────────────────────────────────────────────────────
class CustomDonutChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final double radius;
  final double thickness;
  final String centerTitle;
  final String centerValue;

  const CustomDonutChart({
    super.key,
    required this.values,
    required this.labels,
    required this.colors,
    this.radius = 65,
    this.thickness = 14,
    this.centerTitle = 'TOTAL',
    required this.centerValue,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox();

    return Row(
      children: [
        // Donut circle
        Container(
          width: radius * 2,
          height: radius * 2,
          padding: const EdgeInsets.all(8),
          child: CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: _DonutChartPainter(
              values: values,
              colors: colors,
              thickness: thickness,
              centerTitle: centerTitle,
              centerValue: centerValue,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Legends
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(values.length, (index) {
              final val = values[index];
              final total = values.fold(0.0, (s, e) => s + e);
              final pct = total > 0 ? (val / total * 100).toStringAsFixed(0) : '0';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${labels[index]} ($pct%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double thickness;
  final String centerTitle;
  final String centerValue;

  _DonutChartPainter({
    required this.values,
    required this.colors,
    required this.thickness,
    required this.centerTitle,
    required this.centerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0.0, (sum, val) => sum + val);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;

    if (total == 0) {
      final paint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      // Draw arc slightly shorter if there are multiple segments to show rounded edges
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw center texts
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Title (e.g. "TOTAL")
    textPainter.text = TextSpan(
      text: centerTitle.toUpperCase(),
      style: TextStyle(color: Colors.grey.shade500, fontSize: 8, letterSpacing: 0.5, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height - 1));

    // Value (e.g. "84.5 L")
    textPainter.text = TextSpan(
      text: centerValue,
      style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 13, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy + 1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
