import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/budget/presentation/widgets/category_budget_item.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/budget/presentation/widgets/budget_summary_card.dart';
import 'package:finance_management/core/shared/widgets/empty_state_widget.dart';

class ActiveBudgetView extends ConsumerWidget {
  final VoidCallback onSetupPressed;
  final VoidCallback onAddCategoryPressed;

  const ActiveBudgetView({
    super.key,
    required this.onSetupPressed,
    required this.onAddCategoryPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final budgetState = ref.watch(budgetNotifierProvider);

    // --- GUNAKAN PROVIDER BARU DI SINI ---
    final computedBudgets = ref.watch(computedBudgetsProvider);

    final rawAllocated = computedBudgets.fold(
      0.0,
      (sum, b) => sum + b.limitAmount,
    );
    final convertedAllocated = rawAllocated.toConverted(settings);

    if (budgetState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (budgetState.activeSummary == null) {
      return EmptyStateWidget(
        icon: Icons.account_balance_wallet_outlined,
        message: "No budget found for this month",
        onActionPressed: onSetupPressed,
        actionLabel: "Setup Monthly Budget",
      );
    }

    final rawTotalLimit = budgetState.activeSummary?.totalLimit ?? 0.0;
    final convertedTotalLimit = rawTotalLimit.toConverted(settings);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(budgetNotifierProvider.notifier).initCurrentMonth();
        await ref.read(budgetNotifierProvider.notifier).refreshAndSync();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          BudgetSummaryCard(
            totalLimit: convertedTotalLimit,
            allocated: convertedAllocated,
          ),
          const SizedBox(height: 35),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Category Budgets",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Set limits for each category",
                      style: TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.main.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                child: IconButton(
                  onPressed: onAddCategoryPressed,
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.main,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (computedBudgets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "No budget categories established yet.",
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            )
          else
            ...computedBudgets.map(
              (budget) => CategoryBudgetItem(budget: budget),
            ),
          const SizedBox(height: 80), // Space for FAB if any
        ],
      ),
    );
  }
}
