import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';

class WalletAnalysisList extends ConsumerWidget {
  final List<Wallet> wallets;

  const WalletAnalysisList({super.key, required this.wallets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Hitung total semua saldo untuk cari persentase
    final totalBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);

    if (wallets.isEmpty) {
      return const Text(
        "No wallets found",
        style: TextStyle(color: AppColors.grey),
      );
    }

    return Column(
      children: wallets.map((wallet) {
        final percentage = totalBalance > 0
            ? (wallet.balance / totalBalance)
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.widgetColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                IconData(wallet.iconCode, fontFamily: 'MaterialIcons'),
                color: AppColors.main,
                size: 20,
              ),
            ),
            title: Text(
              wallet.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              "${(percentage * 100).toStringAsFixed(1)}% of total balance",
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            trailing: Text(
              CurrencyFormatter.formatLocaleCompact(
                amount: wallet.balance * (settings.exchangeRate ?? 1.0),
                symbol: settings.currencySymbol,
                currencyCode: settings.currency,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
