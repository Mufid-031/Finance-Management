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
import 'package:go_router/go_router.dart';

import 'package:flutter_animate/flutter_animate.dart';

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
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Dismissible(
                  key: Key(wallet.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title: "Delete Wallet",
                        message:
                            "Are you sure? All transactions in this wallet will be affected.",
                        confirmLabel: "Delete",
                        onConfirm: () {},
                      ),
                    ).then((value) => value ?? false);
                  },
                  onDismissed: (_) {
                    ref
                        .read(walletNotifierProvider.notifier)
                        .deleteWallet(wallet.id);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.widgetColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ListTile(
                      onTap: () =>
                          context.pushNamed('wallet-detail', extra: wallet),
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.main.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          IconData(
                            wallet.iconCode,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: AppColors.main,
                        ),
                      ),
                      title: Text(
                        wallet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          CurrencyFormatter.formatLocale(
                            amount: walletConvertedBalance,
                            symbol: settings.currencySymbol,
                            currencyCode: settings.currency,
                          ),
                          style: const TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2);
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
