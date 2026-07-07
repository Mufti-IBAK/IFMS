import 'package:flutter/material.dart';

class AnimalSilhouette extends StatelessWidget {
  final String species;
  final String sex;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const AnimalSilhouette({
    super.key,
    required this.species,
    required this.sex,
    this.size = 48,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isFemale = sex.toLowerCase() == 'female';
    final speciesLower = species.toLowerCase();

    // Premium themed color selection
    final defaultBgColor = isFemale 
        ? Colors.pink.shade50 
        : Colors.blue.shade50;
    
    final defaultColor = isFemale 
        ? Colors.pink.shade700 
        : Colors.blue.shade700;

    final bg = backgroundColor ?? defaultBgColor;
    final fg = color ?? defaultColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: fg.withOpacity(0.15),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: CustomPaint(
        size: Size(size * 0.7, size * 0.7),
        painter: _SilhouettePainter(
          species: speciesLower,
          color: fg,
        ),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  final String species;
  final Color color;

  _SilhouettePainter({
    required this.species,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (species.contains('cow') || species.contains('bovine') || species.contains('cattle')) {
      // 🐄 Cattle (Holstein Head Silhouette)
      // Muzzle
      path.moveTo(w * 0.35, h * 0.85);
      path.quadraticBezierTo(w * 0.5, h * 0.95, w * 0.65, h * 0.85);
      // Cheeks
      path.lineTo(w * 0.70, h * 0.60);
      // Right Ear
      path.cubicTo(w * 0.85, h * 0.50, w * 0.95, h * 0.55, w * 0.98, h * 0.62);
      path.cubicTo(w * 0.95, h * 0.68, w * 0.85, h * 0.68, w * 0.75, h * 0.65);
      
      // Horn base & Horn right
      path.lineTo(w * 0.73, h * 0.40);
      path.cubicTo(w * 0.82, h * 0.25, w * 0.85, h * 0.10, w * 0.82, h * 0.05);
      path.cubicTo(w * 0.78, h * 0.10, w * 0.70, h * 0.28, w * 0.68, h * 0.38);

      // Crown (middle top of head)
      path.lineTo(w * 0.32, h * 0.38);

      // Horn left
      path.cubicTo(w * 0.30, h * 0.28, w * 0.22, h * 0.10, w * 0.18, h * 0.05);
      path.cubicTo(w * 0.15, h * 0.10, w * 0.18, h * 0.25, w * 0.27, h * 0.40);

      // Left Ear
      path.lineTo(w * 0.25, h * 0.65);
      path.cubicTo(w * 0.15, h * 0.68, w * 0.05, h * 0.68, w * 0.02, h * 0.62);
      path.cubicTo(w * 0.05, h * 0.55, w * 0.15, h * 0.50, w * 0.30, h * 0.60);

      path.lineTo(w * 0.35, h * 0.85);
      path.close();

      // Draw eyes & nostrils as highlights
      canvas.drawPath(path, paint);

      // Add two small nostrils
      final nostrilPaint = Paint()..color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(Offset(w * 0.43, h * 0.85), w * 0.04, nostrilPaint);
      canvas.drawCircle(Offset(w * 0.57, h * 0.85), w * 0.04, nostrilPaint);
    } 
    else if (species.contains('goat') || species.contains('caprine')) {
      // 🐐 Goat Head Silhouette (Upright narrow horns, dropping ears, triangular muzzle)
      // Muzzle
      path.moveTo(w * 0.42, h * 0.90);
      path.quadraticBezierTo(w * 0.5, h * 0.98, w * 0.58, h * 0.90);
      // Beard/Cheeks
      path.lineTo(w * 0.68, h * 0.60);
      
      // Right Ear dropping
      path.cubicTo(w * 0.88, h * 0.62, w * 0.95, h * 0.75, w * 0.92, h * 0.85);
      path.cubicTo(w * 0.88, h * 0.82, w * 0.78, h * 0.70, w * 0.68, h * 0.62);

      // Horn right (swept back)
      path.lineTo(w * 0.66, h * 0.35);
      path.cubicTo(w * 0.78, h * 0.15, w * 0.80, h * 0.02, w * 0.75, h * 0.00);
      path.cubicTo(w * 0.68, h * 0.08, w * 0.60, h * 0.22, w * 0.58, h * 0.34);

      // Top of head
      path.lineTo(w * 0.42, h * 0.34);

      // Horn left (swept back)
      path.cubicTo(w * 0.40, h * 0.22, w * 0.32, h * 0.08, w * 0.25, h * 0.00);
      path.cubicTo(w * 0.20, h * 0.02, w * 0.22, h * 0.15, w * 0.34, h * 0.35);

      // Left Ear dropping
      path.lineTo(w * 0.32, h * 0.62);
      path.cubicTo(w * 0.22, h * 0.70, w * 0.12, h * 0.82, w * 0.08, h * 0.85);
      path.cubicTo(w * 0.05, h * 0.75, w * 0.12, h * 0.62, w * 0.32, h * 0.60);

      path.lineTo(w * 0.42, h * 0.90);
      path.close();

      canvas.drawPath(path, paint);
    } 
    else if (species.contains('sheep') || species.contains('ovine')) {
      // 🐑 Sheep Silhouette (Fluffy cloud shape head, dropping soft ears)
      final cloudPath = Path();
      cloudPath.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.45), radius: w * 0.32));
      cloudPath.addOval(Rect.fromCircle(center: Offset(w * 0.3, h * 0.45), radius: w * 0.22));
      cloudPath.addOval(Rect.fromCircle(center: Offset(w * 0.7, h * 0.45), radius: w * 0.22));
      cloudPath.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.65), radius: w * 0.26));
      
      // Face area (smooth shield)
      final facePath = Path();
      facePath.moveTo(w * 0.38, h * 0.45);
      facePath.lineTo(w * 0.62, h * 0.45);
      facePath.lineTo(w * 0.58, h * 0.80);
      facePath.quadraticBezierTo(w * 0.5, h * 0.88, w * 0.42, h * 0.80);
      facePath.close();

      // Ears dropping
      final leftEar = Path();
      leftEar.moveTo(w * 0.32, h * 0.46);
      leftEar.cubicTo(w * 0.15, h * 0.48, w * 0.10, h * 0.62, w * 0.15, h * 0.68);
      leftEar.cubicTo(w * 0.22, h * 0.65, w * 0.28, h * 0.55, w * 0.32, h * 0.50);

      final rightEar = Path();
      rightEar.moveTo(w * 0.68, h * 0.50);
      rightEar.cubicTo(w * 0.72, h * 0.55, w * 0.78, h * 0.65, w * 0.85, h * 0.68);
      rightEar.cubicTo(w * 0.90, h * 0.62, w * 0.85, h * 0.48, w * 0.68, h * 0.46);

      canvas.drawPath(cloudPath, Paint()..color = color.withOpacity(0.25)..style = PaintingStyle.fill);
      canvas.drawPath(leftEar, paint);
      canvas.drawPath(rightEar, paint);
      canvas.drawPath(facePath, paint);
    } 
    else if (species.contains('poultry') || species.contains('avian') || species.contains('chicken') || species.contains('bird')) {
      // 🐔 Chicken/Poultry Silhouette
      // Comb
      path.moveTo(w * 0.45, h * 0.22);
      path.cubicTo(w * 0.40, h * 0.05, w * 0.50, h * 0.02, w * 0.50, h * 0.12);
      path.cubicTo(w * 0.55, h * 0.02, w * 0.62, h * 0.05, w * 0.60, h * 0.15);
      path.cubicTo(w * 0.68, h * 0.08, w * 0.75, h * 0.12, w * 0.68, h * 0.24);

      // Head and neck/beak
      path.lineTo(w * 0.70, h * 0.32);
      // Beak (pointing right)
      path.lineTo(w * 0.88, h * 0.38);
      path.lineTo(w * 0.70, h * 0.46);
      
      // Wattle (hanging down)
      path.cubicTo(w * 0.68, h * 0.58, w * 0.58, h * 0.62, w * 0.58, h * 0.52);
      
      // Chest
      path.quadraticBezierTo(w * 0.50, h * 0.75, w * 0.32, h * 0.80);
      // Body/back of head
      path.lineTo(w * 0.20, h * 0.55);
      path.quadraticBezierTo(w * 0.32, h * 0.38, w * 0.45, h * 0.32);
      path.close();

      canvas.drawPath(path, paint);
    } 
    else {
      // 🐾 Default silhouette icon/animal footprint or standard target
      final center = Offset(w * 0.5, h * 0.5);
      canvas.drawCircle(center, w * 0.35, paint);
      
      // Subtract inner paw or generic details
      final highlightPaint = Paint()..color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(Offset(w * 0.5, w * 0.4), w * 0.10, highlightPaint);
      canvas.drawCircle(Offset(w * 0.35, w * 0.55), w * 0.08, highlightPaint);
      canvas.drawCircle(Offset(w * 0.65, w * 0.55), w * 0.08, highlightPaint);
      canvas.drawCircle(Offset(w * 0.5, w * 0.7), w * 0.07, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) {
    return oldDelegate.species != species || oldDelegate.color != color;
  }
}
