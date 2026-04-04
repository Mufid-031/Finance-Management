import 'package:finance_management/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bagian Teks
              Expanded(
                flex: 3, // Mengambil 60% lebar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Well done!",
                      style: TextStyle(fontSize: 24, color: AppColors.white),
                    ),
                    SizedBox(height: 4),
                    const Text(
                      "Your spending reduced by 2% last month",
                      style: TextStyle(color: AppColors.grey),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      style: ButtonStyle(
                        alignment: AlignmentGeometry.centerLeft,
                      ),
                      onPressed: () {},
                      child: Text(
                        "View Details",
                        style: TextStyle(color: AppColors.main, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              // Bagian Chart
              Expanded(
                flex: 3, // Mengambil 40% lebar
                child: _buildSpendingChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    return SizedBox(
      height: 100, // Tentukan tinggi chart
      child: PieChart(
        PieChartData(
          sectionsSpace: 5,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(
              value: 40,
              color: AppColors.main,
              title: 'Food',
              radius: 30,
              titleStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              value: 30,
              color: AppColors.blue,
              title: 'Bill',
              radius: 30,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              value: 30,
              color: AppColors.purple,
              title: 'Other',
              radius: 30,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
