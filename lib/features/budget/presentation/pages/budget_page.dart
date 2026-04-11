import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';
import 'package:finance_management/features/budget/presentation/widgets/add_budget_modal.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final budgetTabProvider = StateProvider<int>((ref) => 0);
final budgetFilterProvider = StateProvider<int>((ref) => 0);

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(monthlySummariesStreamProvider);
    final selectedTab = ref.watch(budgetFilterProvider);
    final transactions = ref.watch(transactionsStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Budgets")),
      body: Column(
        children: [
          CustomFilterTabs(
            labels: const ["ACTIVE", "CLOSED"],
            currentIndex: selectedTab,
            onTabChanged: (index) {
              ref.read(budgetFilterProvider.notifier).state = index;
            },
          ),
          Expanded(
            child: summariesAsync.when(
              data: (summaries) {
                final now = DateTime.now();
                final filtered = summaries.where((s) {
                  final isCurrent = s.month == now.month && s.year == now.year;
                  return selectedTab == 0 ? isCurrent : !isCurrent;
                }).toList();

                if (filtered.isEmpty) return _buildEmptyState(context, ref);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final s = filtered[i];
                    final spent = transactions
                        .where(
                          (tx) =>
                              tx.date.month == s.month &&
                              tx.date.year == s.year &&
                              tx.type.name == 'expense',
                        )
                        .fold(0.0, (sum, tx) => sum + tx.amount);

                    return _monthlyCard(context, s, spent);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _monthlyCard(BuildContext context, MonthlySummary s, double spent) {
    final progress = (spent / s.totalLimit).clamp(0.0, 1.0);
    final date = DateTime(s.year, s.month);
    return GestureDetector(
      onTap: () => context.push('/budget-detail', extra: s),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${s.categoryCount} Categories",
                    style: const TextStyle(color: AppColors.main, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.grey.withOpacity(0.1),
                color: spent > s.totalLimit ? AppColors.red : AppColors.main,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _info("Limit", CurrencyFormatter.format(s.totalLimit)),
                  _info("Spent", CurrencyFormatter.format(spent)),
                  _info(
                    "Left",
                    CurrencyFormatter.format(s.totalLimit - spent),
                    color: AppColors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String l, String v, {Color? color}) => Column(
    children: [
      Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
      Text(
        v,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    ],
  );

  void _showAddBudgetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const AddBudgetModal(),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "No budgets set yet",
            style: TextStyle(color: AppColors.grey),
          ),
          TextButton(
            onPressed: () => _showAddBudgetDialog(context),
            child: const Text("Create your first budget"),
          ),
        ],
      ),
    );
  }
}
