import 'package:countup/countup.dart';
import 'package:flutter/material.dart';

class AnimatedPercentageText extends StatelessWidget {
  final double percentage; // Expected 0.0 to 1.0 or 0 to 100
  final TextStyle style;
  final Duration duration;
  final bool isDecimal;

  const AnimatedPercentageText({
    super.key,
    required this.percentage,
    required this.style,
    this.duration = const Duration(seconds: 2),
    this.isDecimal = true, // If true, percentage is 0.0-1.0. If false, 0-100.
  });

  @override
  Widget build(BuildContext context) {
    final double targetValue = isDecimal ? (percentage * 100) : percentage;
    final double clampedValue = targetValue.clamp(0, 100);

    return Countup(
      begin: 0,
      end: clampedValue,
      duration: duration,
      precision: 0,
      suffix: "%",
      style: style,
    );
  }
}
