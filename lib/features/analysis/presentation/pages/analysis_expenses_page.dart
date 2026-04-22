import 'package:finance_management/core/utils/color_generator.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/analysis/domain/category_report.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/settings/domain/settings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/shared/widgets/custom_chip_filter.dart';
import 'package:finance_management/features/analysis/presentation/providers/analysis_provider.dart';
import 'package:finance_management/features/analysis/presentation/providers/analysis_state.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';

class AnalysisExpensesPage extends ConsumerWidget {
  const AnalysisExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final budgetState = ref.watch(budgetNotifierProvider);
    final computedBudgets = ref.watch(computedBudgetsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Expenses Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomChipFilter<AnalysisTimeFilter>(
              values: AnalysisTimeFilter.values,
              selectedValue: analysisState.selectedFilter,
              labelBuilder: (p) => p.name.toUpperCase(),
              onSelected: (newFilter) {
                ref
                    .read(analysisNotifierProvider.notifier)
                    .changeFilter(newFilter);
              },
            ),
          ),
          Expanded(
            child: (analysisState.isLoading || (budgetState.isLoading && computedBudgets.isEmpty))
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildChartSection(analysisState, ref),
                      const SizedBox(height: 40),
                      analysisState.categoryReports.isEmpty
                          ? Container()
                          : const Text(
                              "Category Breakdown",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const SizedBox(height: 15),
                      ...analysisState.categoryReports.map(
                        (report) => _buildCategoryTile(
                          report: report,
                          settings: settings,
                          ref: ref,
                          computedBudgets: computedBudgets,
                          selectedFilter: analysisState.selectedFilter,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(AnalysisState state, WidgetRef ref) {
    if (state.categoryReports.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No data available")),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 160,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 100),
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35,
                      sections: _buildPieSections(state, value),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: state.categoryReports.take(5).map((report) {
                // PAKAI UTILS COLOR DISINI BOSS
                final color = ColorGenerator.fromId(report.categoryId);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          report.categoryName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${(report.percentage * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(AnalysisState state, double animValue) {
    return state.categoryReports.map((report) {
      // PAKAI UTILS COLOR DISINI BOSS
      final color = ColorGenerator.fromId(report.categoryId);

      return PieChartSectionData(
        color: color,
        value: report.totalAmount * animValue,
        title: '',
        radius: 25,
        showTitle: false,
      );
    }).toList();
  }

  Widget _buildCategoryTile({
    required CategoryReport report,
    required Settings settings,
    required WidgetRef ref,
    required List<Budget> computedBudgets,
    required AnalysisTimeFilter selectedFilter,
  }) {
    final color = ColorGenerator.fromId(report.categoryId);
    final bgColor = ColorGenerator.fromIdLowOpacity(report.categoryId);
    final convertedAmount = report.totalAmount.toConverted(settings);

    final budgetForThisCategory = computedBudgets.firstWhere(
      (b) => b.categoryId == report.categoryId,
      orElse: () => Budget(
        id: '',
        categoryId: '',
        monthlySummaryId: '',
        limitAmount: 0.0,
      ),
    );

    final bool hasBudget = budgetForThisCategory.id.isNotEmpty;

    final adjustedLimit = budgetForThisCategory.getAdjustedLimit(selectedFilter);
    final isOverlimit = budgetForThisCategory.checkIsOverlimit(
      report.totalAmount,
      selectedFilter,
    );
    final convertedAdjustedLimit = adjustedLimit.toConverted(settings);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            IconData(report.iconCode, fontFamily: 'MaterialIcons'),
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          report.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Limit: ${CurrencyFormatter.formatLocale(amount: convertedAdjustedLimit, symbol: settings.currencySymbol, currencyCode: settings.currency)}",
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // TAMPILKAN PERBANDINGAN NOMINAL DI SINI, BOSS
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: CurrencyFormatter.formatLocale(
                      amount: convertedAmount,
                      symbol: settings.currencySymbol,
                      currencyCode: settings.currency,
                    ),
                    style: TextStyle(
                      color: isOverlimit ? AppColors.red : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${(report.percentage * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
                const SizedBox(width: 4),
                Icon(
                  !hasBudget
                      ? Icons.help_outline
                      : (isOverlimit ? Icons.trending_up : Icons.trending_flat),
                  size: 14,
                  color: !hasBudget
                      ? AppColors.grey
                      : (isOverlimit ? AppColors.red : AppColors.green),
                ),
                const SizedBox(width: 4),
                Text(
                  !hasBudget ? "No Budget" : (isOverlimit ? "Over" : "Safe"),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: !hasBudget
                        ? AppColors.grey
                        : (isOverlimit ? AppColors.red : AppColors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
