import 'package:finance_management/features/budget/presentation/widgets/category_budget_item.dart';
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
    final budgetState = ref.watch(budgetNotifierProvider);

    final allocated = budgetState.categoryBudgets.fold(
      0.0,
      (sum, b) => sum + b.limitAmount,
    );

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

    final totalLimit = budgetState.activeSummary?.totalLimit ?? 0.0;

    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(budgetNotifierProvider.notifier).initCurrentMonth(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          BudgetSummaryCard(totalLimit: totalLimit, allocated: allocated),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Category Budgets",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: onAddCategoryPressed,
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (budgetState.categoryBudgets.isEmpty)
            const Center(child: Text("No category budgets added yet."))
          else
            ...budgetState.categoryBudgets.map(
              (budget) => CategoryBudgetItem(budget: budget),
            ),
        ],
      ),
    );
  }
}
