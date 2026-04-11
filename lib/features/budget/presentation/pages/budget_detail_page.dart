import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class BudgetDetailPage extends ConsumerWidget {
  final MonthlySummary summary;
  const BudgetDetailPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kita panggil detail kategori berdasarkan bulan & tahun dari summary
    final targetDate = DateTime(summary.year, summary.month);
    final categoryBudgetsAsync = ref.watch(budgetDetailsProvider(targetDate));
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final transactions = ref.watch(transactionsStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Detail: ${summary.month}/${summary.year}")),
      body: categoryBudgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (budgets) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final category = categories.firstWhere(
                (c) => c.id == budget.categoryId,
                orElse: () => categories.first,
              );

              // Hitung spending per kategori
              final spent = transactions
                  .where(
                    (tx) =>
                        tx.categoryId == budget.categoryId &&
                        tx.date.month == summary.month &&
                        tx.date.year == summary.year,
                  )
                  .fold(0.0, (sum, tx) => sum + tx.amount);

              return _buildCategoryCard(context, budget, category, spent);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    dynamic budget,
    dynamic cat,
    double spent,
  ) {
    final progress = (spent / budget.limitAmount).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppColors.main.withOpacity(0.1),
          child: Icon(cat.icon, color: AppColors.main),
        ),
        title: Text(
          cat.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              color: spent > budget.limitAmount
                  ? AppColors.red
                  : AppColors.main,
              backgroundColor: AppColors.grey.withOpacity(0.1),
            ),
            const SizedBox(height: 5),
            Text(
              "${CurrencyFormatter.format(spent)} of ${CurrencyFormatter.format(budget.limitAmount)}",
            ),
          ],
        ),
      ),
    );
  }
}
