import 'package:finance_management/core/shared/widgets/animated_percentage_text.dart';
import 'package:finance_management/core/shared/widgets/section_header.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MonthlyBudgetCard extends ConsumerWidget {
  const MonthlyBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetNotifierProvider);
    final totalSpent = ref.watch(totalMonthlyExpenseProvider);
    final settings = ref.watch(settingsProvider);

    final summary = budgetState.activeSummary;

    if (summary == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () => context.push('/budgets'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SectionHeader(title: "Monthly Budget"),
                const SizedBox(height: 10),
                const Text(
                  "You haven't established a budget for this month.",
                  style: TextStyle(color: AppColors.grey),
                ),                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => context.push('/budgets'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Set Up Budget"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalLimit = summary.totalLimit.toConverted(settings);
    final totalSpentConverted = totalSpent.toConverted(settings);
    final percentUsed = totalLimit > 0
        ? (totalSpentConverted / totalLimit)
        : 0.0;
    final displayPercent = (percentUsed * 100).clamp(0, 100).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/budgets'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SectionHeader(
                title: "Monthly Budget",
                onPressed: () => context.push('/budgets'),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Monthly spending limit",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.formatLocale(
                            amount: totalSpentConverted,
                            symbol: settings.currencySymbol,
                            currencyCode: settings.currency,
                          ),
                          style: const TextStyle(
                            color: AppColors.main,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "of ${CurrencyFormatter.formatLocale(amount: totalLimit, symbol: settings.currencySymbol, currencyCode: settings.currency)}",
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // DONUT CHART
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 100,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: percentUsed),
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 30,
                                  startDegreeOffset: -90,
                                  sections: [
                                    PieChartSectionData(
                                      value: value > 1 ? 1 : value,
                                      color: value > 0.9
                                          ? AppColors.expense
                                          : AppColors.main,
                                      radius: 12,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: value > 1 ? 0 : 1 - value,
                                      color: AppColors.grey.withValues(alpha: 0.2),
                                      radius: 12,
                                      showTitle: false,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${(value * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
