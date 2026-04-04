import 'package:finance_management/features/dashboard/presentation/widgets/monthly_budget_card.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/time_analysis_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/info_card.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/list_wallet_card.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:finance_management/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletsStreamProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    // Ambil warna background dari tema aktif
    final themeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor:
          themeBackground, // GUNAKAN INI, jangan AppColors.backgroundColor
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (wallets) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(balance: totalBalance),
              const InfoCard(),
              const SizedBox(height: 15),
              const ListWalletCard(),
              const SizedBox(height: 15),
              const QuickActions(),
              const SizedBox(height: 15),
              const RecentTransactions(),
              const SizedBox(height: 15),
              const MonthlyBudgetCard(),
              const SizedBox(height: 15),
              const TimeAnalysisCard(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
