import 'package:finance_management/core/shared/widgets/section_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class MonthlyBudgetCard extends StatelessWidget {
  const MonthlyBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SectionHeader(title: "Monthly Budget"),
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
                        style: TextStyle(color: AppColors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "spends: \$1000 / \$2000",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // DONUT CHART
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 100,
                    width: 80,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 30,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            value: 70,
                            color: AppColors.main,
                            radius: 20,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 30, // Sisa
                            color: AppColors.grey.withValues(alpha: 0.2),
                            radius: 20,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
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
