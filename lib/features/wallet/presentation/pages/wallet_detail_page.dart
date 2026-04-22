import 'package:finance_management/core/shared/widgets/animated_currency_text.dart';
import 'package:finance_management/core/shared/widgets/date_separator.dart';
import 'package:finance_management/core/shared/widgets/empty_state_widget.dart';
import 'package:finance_management/core/shared/widgets/transaction_item_tile.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/date_formatter.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:finance_management/features/wallet/presentation/widgets/add_wallet_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WalletDetailPage extends ConsumerWidget {
  final Wallet wallet;
  const WalletDetailPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final wallets = ref.watch(walletsStreamProvider).value ?? [];
    final currentWallet = wallets.firstWhere(
      (w) => w.id == wallet.id,
      orElse: () => wallet,
    );

    final transactions = ref.watch(walletTransactionsProvider(currentWallet.id));
    final categories = ref.watch(categoriesStreamProvider).value ?? [];

    final walletConvertedBalance =
        currentWallet.balance * (settings.exchangeRate ?? 1.0);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Premium Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () => _showAddWalletModal(context, currentWallet),
                icon: const Icon(Icons.edit_outlined),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.backgroundColor, AppColors.widgetColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.main.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(
                          currentWallet.iconCode,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: AppColors.main,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currentWallet.name,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
                    const SizedBox(height: 5),
                    AnimatedCurrencyText(
                      amount: walletConvertedBalance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 400.ms).scaleXY(begin: 0.9),
                  ],
                ),
              ),
            ),
          ),

          // 2. Transaction List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${transactions.length} items",
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // 3. Transactions List
          if (transactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyStateWidget(
                  message: "No transactions found for this wallet",
                  icon: Icons.history_rounded,
                  onActionPressed: () => Navigator.pop(context),
                  actionLabel: "Back",
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    final category = categories.firstWhere(
                      (c) => c.id == tx.categoryId,
                      orElse: () => tx.category ?? categories.first,
                    );

                    final dateLabel = DateFormatter.getNiceDateLabel(tx.date);
                    bool showHeader = index == 0 ||
                        DateFormatter.getNiceDateLabel(tx.date) !=
                            DateFormatter.getNiceDateLabel(
                              transactions[index - 1].date,
                            );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) DateSeparator(date: dateLabel),
                        TransactionItemTile(tx: tx, category: category),
                      ],
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
                  },
                  childCount: transactions.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  void _showAddWalletModal(BuildContext context, Wallet wallet) {
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
}
