import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetSummaryCard extends ConsumerWidget {
  final double totalLimit;
  final double allocated;

  const BudgetSummaryCard({
    super.key,
    required this.totalLimit,
    required this.allocated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final remaining = totalLimit - allocated;
    final percent = totalLimit > 0 ? (allocated / totalLimit) : 0.0;
    final displayPercent = (percent * 100).clamp(0, 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Budget",
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.formatLocale(
                          amount: totalLimit,
                          symbol: settings.currencySymbol,
                          currencyCode: settings.currency,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 30,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            value: percent > 1 ? 1 : percent,
                            color: AppColors.main,
                            radius: 8,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: percent > 1 ? 0 : 1 - percent,
                            color: Colors.white.withValues(alpha: 0.05),
                            radius: 8,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$displayPercent%",
                      style: const TextStyle(
                        color: AppColors.main,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildInfoItem(
                  context,
                  "Allocated",
                  allocated,
                  AppColors.main,
                  settings,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                ),
                _buildInfoItem(
                  context,
                  "Remaining",
                  remaining,
                  remaining < 0 ? AppColors.red : AppColors.blue,
                  settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    dynamic settings,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.grey, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatLocaleCompact(
              amount: amount,
              symbol: settings.currencySymbol,
              currencyCode: settings.currency,
            ),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
