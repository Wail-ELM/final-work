  import 'dart:math';
  import 'package:flutter/material.dart';

  class ProgressCircle extends StatelessWidget {
    final double percentage;
    final double size;
    final String label;

    const ProgressCircle({
      super.key,
      required this.percentage,
      this.size = 100,
      this.label = '',
    });

    @override
    Widget build(BuildContext context) {
      final color = Theme.of(context).colorScheme.primary;
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CirclePainter(percentage, color),
          child: Center(
            child: Text(
              label.isNotEmpty ? label : '${(percentage * 100).round()}%',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
      );
    }
  }

  class _CirclePainter extends CustomPainter {
    final double percentage;
    final Color color;
    _CirclePainter(this.percentage, this.color);

    @override
    void paint(Canvas canvas, Size size) {
      final stroke = 8.0;
      final radius = (size.width - stroke) / 2;
      final center = Offset(size.width / 2, size.height / 2);

      final bg = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke;

      final fg = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, bg);
      final sweep = 2 * pi * percentage;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweep,
        false,
        fg,
      );
    }

    @override
    bool shouldRepaint(covariant _CirclePainter old) =>
        old.percentage != percentage || old.color != color;
  }
