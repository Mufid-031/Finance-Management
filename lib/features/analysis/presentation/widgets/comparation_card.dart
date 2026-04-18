import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparisonCard extends ConsumerWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const ComparisonCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final convertedAmount = amount.toConverted(settings);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            CurrencyFormatter.formatLocale(
              amount: convertedAmount,
              symbol: settings.currencySymbol,
              currencyCode: settings.currency,
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
