import 'package:finance_management/features/analysis/domain/category_report.dart';
import 'package:finance_management/features/analysis/domain/time_series_data.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:flutter/material.dart';

class AnalysisService {
  // Menghitung Laporan per Kategori (untuk Pie Chart)
  List<CategoryReport> calculateCategoryReports(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    if (transactions.isEmpty) return [];

    final totalExpense = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    Map<String, double> categorySum = {};
    Map<String, int> categoryCount = {};

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        categorySum[tx.categoryId] =
            (categorySum[tx.categoryId] ?? 0.0) + tx.amount;
        categoryCount[tx.categoryId] = (categoryCount[tx.categoryId] ?? 0) + 1;
      }
    }

    return categorySum.entries.map((entry) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(
          id: '',
          name: 'Unknown',
          icon: Icons.question_mark,
          type: CategoryType.expense,
        ),
      );

      return CategoryReport(
        categoryId: category.id,
        categoryName: category.name,
        totalAmount: entry.value,
        percentage: totalExpense > 0 ? (entry.value / totalExpense) : 0.0,
        transactionCount: categoryCount[entry.key] ?? 0,
        iconCode: category.icon.codePoint,
      );
    }).toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  }

  // Menghitung Data Time Series (untuk Line Chart)
  List<TimeSeriesData> calculateTimeSeriesData(
    List<Transaction> transactions,
    DateTime start,
    DateTime end,
  ) {
    Map<String, TimeSeriesData> dailyMap = {};

    // Inisialisasi map dengan rentang tanggal agar tidak ada gap di grafik
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final date = start.add(Duration(days: i));
      final key = "${date.year}-${date.month}-${date.day}";
      dailyMap[key] = TimeSeriesData(date, 0.0, 0.0);
    }

    for (var tx in transactions) {
      final key = "${tx.date.year}-${tx.date.month}-${tx.date.day}";
      if (dailyMap.containsKey(key)) {
        final current = dailyMap[key]!;
        if (tx.type == TransactionType.income) {
          dailyMap[key] = TimeSeriesData(
            current.date,
            current.income + tx.amount,
            current.expense,
          );
        } else {
          dailyMap[key] = TimeSeriesData(
            current.date,
            current.income,
            current.expense + tx.amount,
          );
        }
      }
    }

    return dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }
}
