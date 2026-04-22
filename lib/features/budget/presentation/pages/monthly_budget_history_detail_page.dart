import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/budget/presentation/widgets/category_budget_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthlyBudgetHistoryDetailPage extends ConsumerWidget {
  final MonthlySummary summary;
  const MonthlyBudgetHistoryDetailPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(historicalBudgetsProvider(summary.id));

    final months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${months[summary.month]} ${summary.year}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(
              child: Text(
                "No budget configurations found for this period.",
                style: TextStyle(color: AppColors.grey),
              ),
            ).animate().fadeIn();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              return CategoryBudgetItem(budget: budgets[index])
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }
}
