import 'package:finance_management/features/dashboard/presentation/widgets/monthly_budget_card.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/time_analysis_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/list_wallet_card.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';

import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletsStreamProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    final themeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: themeBackground,
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (wallets) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(balance: totalBalance)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.1),
              const SizedBox(height: 15),
              const ListWalletCard()
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: 0.1),
              const SizedBox(height: 15),
              const QuickActions()
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 15),
              const RecentTransactions()
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 15),
              const MonthlyBudgetCard()
                  .animate()
                  .fadeIn(delay: 800.ms)
                  .scaleXY(begin: 0.95),
              const SizedBox(height: 15),
              const TimeAnalysisCard()
                  .animate()
                  .fadeIn(delay: 1000.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
