import 'package:finance_management/core/shared/widgets/confirm_dialog.dart';
import 'package:finance_management/core/shared/widgets/empty_state_widget.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:finance_management/features/wallet/presentation/widgets/add_wallet_modal.dart'; // Import modal baru
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final walletsAsync = ref.watch(walletsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Wallets")),
      body: walletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (wallets) {
          if (wallets.isEmpty) {
            return EmptyStateWidget(
              message: "No wallets found",
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: "Add New Wallet",
              onActionPressed: () => _showAddWalletModal(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];

              final walletConvertedBalance =
                  wallet.balance * (settings.exchangeRate ?? 1.0);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.main.withValues(alpha: 0.1),
                    child: Icon(
                      IconData(wallet.iconCode, fontFamily: 'MaterialIcons'),
                      color: AppColors.main,
                    ),
                  ),
                  title: Text(
                    wallet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    CurrencyFormatter.formatLocale(
                      amount: walletConvertedBalance,
                      symbol: settings.currencySymbol,
                      currencyCode: settings.currency,
                    ),
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.grey,
                        ),
                        onPressed: () =>
                            _showAddWalletModal(context, wallet: wallet),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.red,
                        ),
                        onPressed: () =>
                            _showDeleteConfirmation(context, ref, wallet),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _showAddWalletModal(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddWalletModal(BuildContext context, {Wallet? wallet}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => AddWalletModal(wallet: wallet),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) {
    ConfirmDialog.show(
      context,
      title: "Delete Wallet",
      message: "Are you sure you want to delete '${wallet.name}'?",
      onConfirm: () =>
          ref.read(walletNotifierProvider.notifier).deleteWallet(wallet.id),
    );
  }
}
