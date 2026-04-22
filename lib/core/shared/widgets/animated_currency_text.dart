import 'package:countup/countup.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimatedCurrencyText extends ConsumerWidget {
  final double amount;
  final TextStyle style;
  final Duration duration;
  final TextAlign textAlign;

  const AnimatedCurrencyText({
    super.key,
    required this.amount,
    required this.style,
    this.duration = const Duration(seconds: 2),
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currencySymbol = settings.currencySymbol;
    
    // Determine precision and separator based on currency
    final isIdr = settings.currency == 'IDR';
    final int decimalDigits = isIdr ? 0 : 2;
    final String separator = isIdr ? '.' : ',';

    return Countup(
      begin: 0,
      end: amount,
      duration: duration,
      separator: separator,
      prefix: "$currencySymbol ",
      precision: decimalDigits,
      style: style,
      textAlign: textAlign,
    );
  }
}
