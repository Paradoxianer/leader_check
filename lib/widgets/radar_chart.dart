import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Netzdiagramm für die vier Risikoskalen: ein Blick, der zeigt, wie die
/// Muster im Verhältnis zueinander stehen — die Balken pro Skala bleiben
/// darunter für die Details.
class RadarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;

  const RadarChart({
    super.key,
    required this.labels,
    required this.values,
  }) : assert(labels.length == values.length);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RadarPainter(
          values: values,
          labels: labels,
          labelStyle: labelStyle,
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final TextStyle? labelStyle;

  _RadarPainter({
    required this.values,
    required this.labels,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final center = Offset(size.width / 2, size.height / 2);
    // Platz für die Achsenbeschriftung am Rand freihalten.
    final radius = size.shortestSide / 2 - 46;
    final gridPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Offset pointFor(int i, double fraction) {
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      return center + Offset(math.cos(angle), math.sin(angle)) * radius * fraction;
    }

    // Konzentrische Ringe bei 25/50/75/100 %.
    for (final fraction in [0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = pointFor(i, fraction);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Achsen vom Zentrum zum Rand.
    for (var i = 0; i < n; i++) {
      canvas.drawLine(center, pointFor(i, 1.0), gridPaint);
    }

    // Ausgefüllte Fläche der eigenen Werte.
    final dataPath = Path();
    for (var i = 0; i < n; i++) {
      final p = pointFor(i, (values[i] / 100).clamp(0.0, 1.0));
      i == 0 ? dataPath.moveTo(p.dx, p.dy) : dataPath.lineTo(p.dx, p.dy);
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (var i = 0; i < n; i++) {
      final p = pointFor(i, (values[i] / 100).clamp(0.0, 1.0));
      canvas.drawCircle(p, 3, Paint()..color = AppColors.accent);
    }

    // Achsenbeschriftung, nach außen versetzt und an der Kante ausgerichtet.
    for (var i = 0; i < n; i++) {
      final labelPoint = pointFor(i, 1.0);
      final direction = labelPoint - center;
      final normalized =
          direction.distance == 0 ? Offset.zero : direction / direction.distance;
      final anchor = labelPoint + normalized * 10;

      final painter = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 150);

      final offset = Offset(
        anchor.dx - painter.width / 2,
        anchor.dy - painter.height / 2,
      );
      painter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}
