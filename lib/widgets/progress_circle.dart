import 'package:flutter/material.dart';
import '../theme.dart';

class ProgressCircle extends StatelessWidget {
  final double percent; // 0.0 – 1.0
  final String label;

  const ProgressCircle({
    Key? key,
    required this.percent,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const size = 120.0;
    const strokeWidth = 12.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: strokeWidth,
              backgroundColor: AppTheme.pastelLavender,
              valueColor: AlwaysStoppedAnimation(AppTheme.pastelCoral),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(percent * 100).round()}%', style: Theme.of(context).textTheme.headlineMedium),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
