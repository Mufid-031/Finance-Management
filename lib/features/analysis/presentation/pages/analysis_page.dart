import 'package:finance_management/core/shared/widgets/animated_currency_text.dart';
import 'package:finance_management/core/shared/widgets/custom_chip_filter.dart';
import 'package:finance_management/core/shared/widgets/section_header.dart';
import 'package:finance_management/core/utils/color_generator.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/analysis/presentation/widgets/analysis_line_chart.dart';
import 'package:finance_management/features/analysis/presentation/widgets/comparation_card.dart';
import 'package:finance_management/features/analysis/presentation/widgets/wallet_analysis_list.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/analysis/presentation/providers/analysis_provider.dart';
import 'package:finance_management/features/analysis/presentation/providers/analysis_state.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  AnalysisPeriod _mapFilterToPeriod(AnalysisTimeFilter filter) {
    return AnalysisPeriod.values[filter.index];
  }

  AnalysisTimeFilter _mapPeriodToFilter(AnalysisPeriod period) {
    return AnalysisTimeFilter.values[period.index];
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisNotifierProvider);
    final walletsAsync = ref.watch(walletsStreamProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final settings = ref.watch(settingsProvider);

    final convertedTotalBalance = totalBalance.toConverted(settings);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Analysis",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
              .read(analysisNotifierProvider.notifier)
              .changeFilter(analysisState.selectedFilter);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomChipFilter<AnalysisTimeFilter>(
              values: AnalysisTimeFilter.values,
              selectedValue: analysisState.selectedFilter,
              labelBuilder: (p) => p.name.toUpperCase(),
              onSelected: (newPeriod) {
                ref
                    .read(analysisNotifierProvider.notifier)
                    .changeFilter(newPeriod);
              },
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
            const SizedBox(height: 25),

            TimeAnalysisChart(
              selectedPeriod: _mapFilterToPeriod(analysisState.selectedFilter),
              onPeriodChanged: (newPeriod) {
                ref
                    .read(analysisNotifierProvider.notifier)
                    .changeFilter(_mapPeriodToFilter(newPeriod));
              },
            ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.95),
            const SizedBox(height: 25),

            _buildComparisonSection(analysisState)
                .animate()
                .fadeIn(delay: 400.ms)
                .slideX(begin: 0.1),
            const SizedBox(height: 30),

            SectionHeader(title: "Balance"),
            const SizedBox(height: 10),

            AnimatedCurrencyText(
              amount: convertedTotalBalance,
              style: const TextStyle(color: AppColors.main, fontSize: 28),
            ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
            const SizedBox(height: 10),

            walletsAsync.when(
              data: (wallets) => WalletAnalysisList(wallets: wallets),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text("Error: $err"),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
            const SizedBox(height: 30),

            SectionHeader(
              title: "Top Spending Categories",
              onPressed: () {
                context.pushNamed('expenses');
              },
            ),
            const SizedBox(height: 15),
            _buildTopCategories(analysisState)
                .animate()
                .fadeIn(delay: 1000.ms)
                .slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(AnalysisState state) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var data in state.timeSeriesData) {
      totalIncome += data.income;
      totalExpense += data.expense;
    }

    return Row(
      children: [
        Expanded(
          child: ComparisonCard(
            label: "Total Income",
            amount: totalIncome,
            icon: Icons.arrow_upward,
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ComparisonCard(
            label: "Total Expense",
            amount: totalExpense,
            icon: Icons.arrow_downward,
            color: AppColors.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildTopCategories(AnalysisState state) {
    if (state.categoryReports.isEmpty) {
      return const Center(child: Text("No data for this period"));
    }

    return Column(
      children: state.categoryReports.take(3).map((report) {
        final bgColor = ColorGenerator.fromIdLowOpacity(report.categoryId);
        final reportColor = ColorGenerator.fromId(report.categoryId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.widgetColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  IconData(report.iconCode, fontFamily: 'MaterialIcons'),
                  color: reportColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: report.percentage,
                      backgroundColor: AppColors.backgroundColor,
                      color: reportColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "${(report.percentage * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.main,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
