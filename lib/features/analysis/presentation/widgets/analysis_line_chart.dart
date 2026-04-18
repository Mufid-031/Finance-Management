import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:intl/intl.dart';

// Enum kita pindahkan ke file ini agar bisa diakses secara global
enum AnalysisPeriod { daily, weekly, monthly, yearly }

class TimeAnalysisChart extends ConsumerWidget {
  // --- PROPS / PARAMETERS ---
  final AnalysisPeriod selectedPeriod;
  final Function(AnalysisPeriod) onPeriodChanged;

  const TimeAnalysisChart({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            transactionsAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (transactions) {
                final settings = ref.watch(settingsProvider);
                final chartData = _processTransactionData(
                  transactions,
                  settings.exchangeRate ?? 1.0,
                );

                // Hitung Max Y untuk skala otomatis
                final maxIncome = chartData.incomeSpots.isEmpty
                    ? 0.0
                    : chartData.incomeSpots
                          .map((e) => e.y)
                          .reduce((a, b) => a > b ? a : b);
                final maxExpense = chartData.expenseSpots.isEmpty
                    ? 0.0
                    : chartData.expenseSpots
                          .map((e) => e.y)
                          .reduce((a, b) => a > b ? a : b);

                final maxY = (maxIncome > maxExpense ? maxIncome : maxExpense);

                return Column(
                  children: [
                    Row(
                      children: [
                        _buildYAxisLabels(maxY, ref),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.white.withOpacity(0.05),
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: const FlTitlesData(show: false),
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipColor: (_) =>
                                        AppColors.widgetColor,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minY: 0,
                                maxY: maxY == 0 ? 100 : maxY * 1.2,
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
                    const SizedBox(height: 25),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA PEMROSESAN DATA (Tetap Private di sini) ---
  _ChartProcessedData _processTransactionData(
    List<Transaction> transactions,
    double rate,
  ) {
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    List<String> labels = [];
    DateTime now = DateTime.now();

    // Tentukan jumlah iterasi berdasarkan period
    int iterations;
    if (selectedPeriod == AnalysisPeriod.daily) {
      iterations = 24;
    } else if (selectedPeriod == AnalysisPeriod.weekly) {
      iterations = 7;
    } else if (selectedPeriod == AnalysisPeriod.monthly) {
      iterations = 30; // Atau 12 jika ingin review bulan-bulan sebelumnya
    } else {
      iterations = 12; // Yearly (12 bulan)
    }

    for (int i = 0; i < iterations; i++) {
      double totalIn = 0;
      double totalOut = 0;
      String label = "";

      if (selectedPeriod == AnalysisPeriod.daily) {
        label = "$i:00";
        for (var tx in transactions) {
          if (tx.date.day == now.day &&
              tx.date.hour == i &&
              tx.date.month == now.month) {
            tx.type == TransactionType.income
                ? totalIn += tx.amount
                : totalOut += tx.amount;
          }
        }
      } else if (selectedPeriod == AnalysisPeriod.weekly) {
        DateTime target = now.subtract(Duration(days: (iterations - 1) - i));
        label = DateFormat('E').format(target);
        for (var tx in transactions) {
          if (tx.date.day == target.day &&
              tx.date.month == target.month &&
              tx.date.year == target.year) {
            tx.type == TransactionType.income
                ? totalIn += tx.amount
                : totalOut += tx.amount;
          }
        }
      } else if (selectedPeriod == AnalysisPeriod.yearly) {
        // --- LOGIKA YEARLY (Per Bulan dalam setahun ini) ---
        int targetMonth = i + 1;
        label = DateFormat('MMM').format(DateTime(now.year, targetMonth));
        for (var tx in transactions) {
          if (tx.date.month == targetMonth && tx.date.year == now.year) {
            tx.type == TransactionType.income
                ? totalIn += tx.amount
                : totalOut += tx.amount;
          }
        }
      } else {
        // --- LOGIKA MONTHLY (30 Hari Terakhir) ---
        DateTime target = now.subtract(Duration(days: (iterations - 1) - i));
        label = target.day.toString();
        for (var tx in transactions) {
          if (tx.date.day == target.day &&
              tx.date.month == target.month &&
              tx.date.year == target.year) {
            tx.type == TransactionType.income
                ? totalIn += tx.amount
                : totalOut += tx.amount;
          }
        }
      }

      incomeSpots.add(FlSpot(i.toDouble(), totalIn * rate));
      expenseSpots.add(FlSpot(i.toDouble(), totalOut * rate));
      labels.add(label);
    }
    return _ChartProcessedData(incomeSpots, expenseSpots, labels);
  }

  // --- UI HELPERS ---
  Widget _buildYAxisLabels(double maxY, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final effectiveMax = maxY == 0 ? 100.0 : maxY;
    return SizedBox(
      height: 200,
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (index) {
          final value = effectiveMax - (effectiveMax / 4 * index);
          return Text(
            CurrencyFormatter.formatLocaleCompact(
              amount: value,
              symbol: settings.currencySymbol,
              currencyCode: settings.currency,
            ).replaceAll(' ', ''),
            style: const TextStyle(color: AppColors.grey, fontSize: 9),
          );
        }),
      ),
    );
  }

  Widget _buildXAxisLabels(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.asMap().entries.map((e) {
        // Tampilkan label tiap 1 unit untuk mingguan, tiap 3 unit untuk bulanan/yearly, tiap 4 untuk daily
        bool show = false;
        if (selectedPeriod == AnalysisPeriod.weekly) show = true;
        if (selectedPeriod == AnalysisPeriod.daily && e.key % 4 == 0) {
          show = true;
        }
        if ((selectedPeriod == AnalysisPeriod.monthly ||
                selectedPeriod == AnalysisPeriod.yearly) &&
            e.key % 3 == 0) {
          show = true;
        }
        if (e.key == labels.length - 1) {
          show = true; // Selalu tampilkan label terakhir
        }

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

  Widget _buildBottomLegend(_ChartProcessedData data, WidgetRef ref) {
    final totalIn = data.incomeSpots.fold(0.0, (sum, spot) => sum + spot.y);
    final totalOut = data.expenseSpots.fold(0.0, (sum, spot) => sum + spot.y);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem("Income", AppColors.green, amount: totalIn, ref: ref),
        const SizedBox(width: 25),
        _buildLegendItem("Spending", AppColors.red, amount: totalOut, ref: ref),
      ],
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color, {
    double? amount,
    WidgetRef? ref,
  }) {
    final settings = ref!.watch(settingsProvider);
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
        Text(
          CurrencyFormatter.formatLocaleCompact(
            amount: amount ?? 0,
            symbol: settings.currencySymbol,
            currencyCode: settings.currency,
          ),
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
