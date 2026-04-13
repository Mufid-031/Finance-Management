import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart'; // Import provider settings
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceCard extends ConsumerWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currencySymbol = ref.watch(settingsProvider).currencySymbol;

    final convertedBalance = balance * (settings.exchangeRate ?? 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Balance",
            style: TextStyle(fontSize: 26, color: AppColors.grey),
          ),
          Text(
            CurrencyFormatter.formatLocale(
              amount: convertedBalance,
              symbol: currencySymbol,
              currencyCode: settings.currency,
            ),
            style: const TextStyle(
              fontSize: 56,
              color: AppColors.main,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
