import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/color_generator.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/core/utils/currency_formatter.dart'; // Gunakan formatter kita

class ListWalletCard extends ConsumerWidget {
  const ListWalletCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);

    return SizedBox(
      height: 170,
      child: walletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (wallets) {
          if (wallets.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _buildAddWalletCard(context),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: wallets.length + 1,
            itemBuilder: (context, index) {
              if (index < wallets.length) {
                final wallet = wallets[index];
                // Kirim iconCode sebagai int
                return _buildSquareCard(context, wallet, ref);
              } else {
                return _buildAddWalletCard(context);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSquareCard(BuildContext context, Wallet wallet, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final convertedBalance = wallet.balance * (settings.exchangeRate ?? 1.0);

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                ),
                Text(
                  // Gunakan CurrencyFormatter agar konsisten
                  CurrencyFormatter.formatLocaleCompact(
                    amount: convertedBalance,
                    symbol: settings.currencySymbol,
                    currencyCode: settings.currency,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWalletCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/wallets'),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.main.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.main, size: 32),
            SizedBox(height: 8),
            Text(
              "Add Wallet",
              style: TextStyle(
                color: AppColors.main,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
