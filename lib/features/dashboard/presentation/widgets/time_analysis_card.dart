import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:intl/intl.dart';

class TimeAnalysisCard extends ConsumerStatefulWidget {
  const TimeAnalysisCard({super.key});

  @override
  ConsumerState<TimeAnalysisCard> createState() => _TimeAnalysisCardState();
}

class _TimeAnalysisCardState extends ConsumerState<TimeAnalysisCard> {
  String selectedPeriod = 'Weekly';

  @override
  Widget build(BuildContext context) {
    // ref tersedia otomatis di sini
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabSelector(), // Panggil tanpa ref
            const SizedBox(height: 25),
            Row(
              children: [
                _buildLegendItem("Income", AppColors.green),
                const SizedBox(width: 20),
                _buildLegendItem("Spending", AppColors.red),
              ],
            ),
            const SizedBox(height: 20),
            transactionsAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (transactions) {
                final chartData = _processTransactionData(transactions);
                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            _buildLineData(
                              color: AppColors.green,
                              spots: chartData.incomeSpots,
                            ),
                            _buildLineData(
                              color: AppColors.red,
                              spots: chartData.expenseSpots,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildXAxisLabels(chartData.labels),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // UI HELPERS - Pastikan tidak ada (WidgetRef ref) di parameter fungsi ini
  Widget _buildTabSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Daily', 'Weekly', 'Monthly'].map((period) {
        final isSelected = selectedPeriod == period;
        return GestureDetector(
          onTap: () => setState(() => selectedPeriod = period),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.main : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // LOGIKA PEMPROSESAN DATA
  _ChartProcessedData _processTransactionData(List<Transaction> transactions) {
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    List<String> labels = [];

    DateTime now = DateTime.now();
    int iterations = selectedPeriod == 'Daily'
        ? 24
        : (selectedPeriod == 'Weekly' ? 7 : 12);

    for (int i = 0; i < iterations; i++) {
      double totalIncome = 0;
      double totalExpense = 0;
      DateTime targetDate;
      String label = "";

      if (selectedPeriod == 'Daily') {
        targetDate = DateTime(now.year, now.month, now.day, i);
        label = "$i:00";
        for (var tx in transactions) {
          if (tx.date.day == now.day && tx.date.hour == i) {
            tx.type == TransactionType.income
                ? totalIncome += tx.amount
                : totalExpense += tx.amount;
          }
        }
      } else if (selectedPeriod == 'Weekly') {
        // 7 Hari terakhir
        targetDate = now.subtract(Duration(days: 6 - i));
        label = DateFormat('E').format(targetDate);
        for (var tx in transactions) {
          if (tx.date.day == targetDate.day &&
              tx.date.month == targetDate.month) {
            tx.type == TransactionType.income
                ? totalIncome += tx.amount
                : totalExpense += tx.amount;
          }
        }
      } else {
        // 12 Bulan terakhir
        int month = (now.month - (11 - i));
        int year = now.year;
        if (month <= 0) {
          month += 12;
          year -= 1;
        }
        label = DateFormat('MMM').format(DateTime(year, month));
        for (var tx in transactions) {
          if (tx.date.month == month && tx.date.year == year) {
            tx.type == TransactionType.income
                ? totalIncome += tx.amount
                : totalExpense += tx.amount;
          }
        }
      }

      incomeSpots.add(FlSpot(i.toDouble(), totalIncome));
      expenseSpots.add(FlSpot(i.toDouble(), totalExpense));
      labels.add(label);
    }

    return _ChartProcessedData(incomeSpots, expenseSpots, labels);
  }

  Widget _buildXAxisLabels(List<String> labels) {
    // Ambil beberapa label saja agar tidak penuh (misal: tiap 3 jam untuk daily)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.asMap().entries.map((e) {
        bool show =
            selectedPeriod == 'Weekly' ||
            e.key % (selectedPeriod == 'Daily' ? 4 : 2) == 0;
        return Text(
          show ? e.value : "",
          style: const TextStyle(color: AppColors.grey, fontSize: 10),
        );
      }).toList(),
    );
  }

  LineChartBarData _buildLineData({
    required Color color,
    required List<FlSpot> spots,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
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

class _ChartProcessedData {
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final List<String> labels;
  _ChartProcessedData(this.incomeSpots, this.expenseSpots, this.labels);
}
