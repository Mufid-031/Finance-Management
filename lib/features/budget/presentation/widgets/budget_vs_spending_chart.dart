import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';

class BudgetVsSpendingChart extends ConsumerWidget {
  const BudgetVsSpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetNotifierProvider);
    final computedBudgets = ref.watch(computedBudgetsProvider);

    if (budgetState.activeSummary == null || computedBudgets.isEmpty) {
      return const SizedBox.shrink();
    }

    // Hitung total limit vs total spent
    final totalLimit = budgetState.activeSummary!.totalLimit;
    final totalSpent = computedBudgets.fold(
      0.0,
      (sum, b) => sum + b.spentAmount,
    );

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Legend Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("Budget", AppColors.main),
              const SizedBox(width: 20),
              _buildLegendItem("Spending", AppColors.expense),
            ],
          ),
          const SizedBox(height: 20),
          // Bar Chart Section
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: totalLimit > totalSpent
                    ? totalLimit * 1.2
                    : totalSpent * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalLimit,
                        color: AppColors.main,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      BarChartRodData(
                        toY: totalSpent,
                        color: totalSpent > totalLimit
                            ? AppColors.red
                            : AppColors.expense,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
