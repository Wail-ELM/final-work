import 'dart:math';
import 'package:flutter/material.dart';

class ProgressCircle extends StatefulWidget {
  final double percentage;
  final double size;
  final String label;
  final Duration animationDuration;

  const ProgressCircle({
    super.key,
    required this.percentage,
    this.size = 100,
    this.label = '',
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<ProgressCircle> createState() => _ProgressCircleState();
}

class _ProgressCircleState extends State<ProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    // Calculer la taille du texte proportionnellement à la taille du cercle
    final fontSize = widget.size * 0.12; // 12% de la taille du cercle

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: _CirclePainter(_animation.value, color),
            child: Container(
              width:
                  widget.size * 0.7, // 70% de la taille du cercle pour le texte
              height: widget.size * 0.7,
              alignment: Alignment.center,
              child: Text(
                widget.label.isNotEmpty
                    ? widget.label
                    : '${(_animation.value * 100).round()}%',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double percentage;
  final Color color;
  _CirclePainter(this.percentage, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.08; // 8% de la taille pour l'épaisseur
    final radius = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Background circle with gradient
    final bgGradient = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey.shade200, Colors.grey.shade300],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    // Foreground with gradient
    final fgGradient = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgGradient);
    final sweep = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fgGradient,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) =>
      old.percentage != percentage || old.color != color;
}
