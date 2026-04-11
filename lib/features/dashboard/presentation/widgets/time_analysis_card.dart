import 'package:finance_management/core/shared/widgets/custom_chip_filter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:intl/intl.dart';

enum AnalysisPeriod { daily, weekly, monthly }

class TimeAnalysisCard extends ConsumerStatefulWidget {
  const TimeAnalysisCard({super.key});

  @override
  ConsumerState<TimeAnalysisCard> createState() => _TimeAnalysisCardState();
}

class _TimeAnalysisCardState extends ConsumerState<TimeAnalysisCard> {
  // Ganti String ke Enum
  AnalysisPeriod selectedPeriod = AnalysisPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMPLEMENTASI SHARED WIDGET
            CustomChipFilter<AnalysisPeriod>(
              values: AnalysisPeriod.values,
              selectedValue: selectedPeriod,
              labelBuilder: (period) =>
                  period.name, // Mengambil 'daily', 'weekly', dll
              onSelected: (period) {
                setState(() => selectedPeriod = period);
              },
            ),
            const SizedBox(height: 20),

            transactionsAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(child: Text("Error: $err")),
              // ... inside transactionsAsync.when data: (transactions) ...
              data: (transactions) {
                final chartData = _processTransactionData(transactions);

                // Cari nilai tertinggi untuk skala sumbu Y
                final maxIncome = chartData.incomeSpots
                    .map((e) => e.y)
                    .fold(0.0, (a, b) => a > b ? a : b);
                final maxExpense = chartData.expenseSpots
                    .map((e) => e.y)
                    .fold(0.0, (a, b) => a > b ? a : b);
                final maxY = (maxIncome > maxExpense ? maxIncome : maxExpense);

                return Column(
                  children: [
                    _buildTopLegend(
                      chartData,
                    ), // Legend dengan nominal (seperti request sebelumnya)
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        // SUMBU Y
                        _buildYAxisLabels(maxY),
                        const SizedBox(width: 10),
                        // CHART
                        Expanded(
                          child: SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: AppColors.white.withValues(
                                      alpha: 0.05,
                                    ),
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: const FlTitlesData(show: false),
                                lineTouchData: const LineTouchData(
                                  enabled: true,
                                ),
                                borderData: FlBorderData(show: false),
                                // Atur skala Y agar konsisten dengan label
                                minY: 0,
                                maxY: maxY == 0
                                    ? 100
                                    : maxY * 1.2, // Kasih margin 20% di atas
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
                        ),
                      ],
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

  // --- LOGIKA PEMPROSESAN DATA DENGAN ENUM ---
  _ChartProcessedData _processTransactionData(List<Transaction> transactions) {
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    List<String> labels = [];

    DateTime now = DateTime.now();

    // Sesuaikan iterasi dengan Enum
    int iterations = selectedPeriod == AnalysisPeriod.daily
        ? 24
        : (selectedPeriod == AnalysisPeriod.weekly ? 7 : 12);

    for (int i = 0; i < iterations; i++) {
      double totalIncome = 0;
      double totalExpense = 0;
      String label = "";

      if (selectedPeriod == AnalysisPeriod.daily) {
        label = "$i:00";
        for (var tx in transactions) {
          if (tx.date.day == now.day &&
              tx.date.month == now.month &&
              tx.date.year == now.year &&
              tx.date.hour == i) {
            tx.type == TransactionType.income
                ? totalIncome += tx.amount
                : totalExpense += tx.amount;
          }
        }
      } else if (selectedPeriod == AnalysisPeriod.weekly) {
        DateTime targetDate = now.subtract(Duration(days: 6 - i));
        label = DateFormat('E').format(targetDate);
        for (var tx in transactions) {
          if (tx.date.day == targetDate.day &&
              tx.date.month == targetDate.month &&
              tx.date.year == targetDate.year) {
            tx.type == TransactionType.income
                ? totalIncome += tx.amount
                : totalExpense += tx.amount;
          }
        }
      } else {
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

  Widget _buildYAxisLabels(double maxY) {
    // Jika tidak ada data, tampilkan range default
    final effectiveMax = maxY == 0 ? 100.0 : maxY;

    // Buat 5 tingkatan label (0%, 25%, 50%, 75%, 100%)
    return SizedBox(
      height: 200,
      width: 40, // Lebar area label
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (index) {
          // Hitung nilai per baris (dibalik karena Column mulai dari atas)
          final value = effectiveMax - (effectiveMax / 4 * index);

          return Text(
            _formatShortAmount(value),
            style: const TextStyle(color: AppColors.grey, fontSize: 9),
          );
        }),
      ),
    );
  }

  // Helper untuk menyingkat angka (misal 1.000.000 jadi 1M atau 1jt)
  String _formatShortAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildXAxisLabels(List<String> labels) {
    // Ambil beberapa label saja agar tidak penuh (misal: tiap 3 jam untuk daily)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.asMap().entries.map((e) {
        bool show =
            selectedPeriod == AnalysisPeriod.weekly ||
            e.key % (selectedPeriod == AnalysisPeriod.daily ? 4 : 2) == 0;
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

  Widget _buildTopLegend(_ChartProcessedData data) {
    final totalIn = data.incomeSpots.fold(0.0, (sum, spot) => sum + spot.y);
    final totalOut = data.expenseSpots.fold(0.0, (sum, spot) => sum + spot.y);

    return Row(
      children: [
        _buildLegendItem("Income", AppColors.green, amount: totalIn),
        const SizedBox(width: 20),
        _buildLegendItem("Spending", AppColors.red, amount: totalOut),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {double? amount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
        ),
        if (amount != null)
          Text(
            NumberFormat.compactSimpleCurrency(locale: 'en_US').format(amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
