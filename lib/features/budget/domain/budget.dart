// lib/features/budget/domain/budget.dart

import 'package:finance_management/features/analysis/presentation/providers/analysis_state.dart';
import 'package:flutter/material.dart';

class Budget {
  final String id;
  final String categoryId;
  final String monthlySummaryId;
  final double limitAmount;
  final double spentAmount;
  final bool isRollover;
  final double rolloverAmount;

  Budget({
    required this.id,
    required this.categoryId,
    required this.monthlySummaryId,
    required this.limitAmount,
    this.spentAmount = 0.0,
    this.isRollover = false,
    this.rolloverAmount = 0.0,
  });

  // Tambahkan ini jika belum ada
  Budget copyWith({
    String? id,
    String? categoryId,
    String? monthlySummaryId,
    double? limitAmount,
    double? spentAmount,
    bool? isRollover,
    double? rolloverAmount,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthlySummaryId: monthlySummaryId ?? this.monthlySummaryId,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      isRollover: isRollover ?? this.isRollover,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
    );
  }

  double get totalLimit => limitAmount + rolloverAmount;
  double get remaining => totalLimit - spentAmount;
  double get percentUsed => totalLimit > 0 ? (spentAmount / totalLimit) : 0.0;
}

extension BudgetX on Budget {
  double getAdjustedLimit(AnalysisTimeFilter filter) {
    if (limitAmount <= 0) return 0.0;

    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    switch (filter) {
      case AnalysisTimeFilter.daily:
        return limitAmount / daysInMonth;
      case AnalysisTimeFilter.weekly:
        return (limitAmount / daysInMonth) * 7;
      case AnalysisTimeFilter.monthly:
        return limitAmount;
      case AnalysisTimeFilter.yearly:
        return limitAmount * 12;
      default:
        return limitAmount;
    }
  }

  bool checkIsOverlimit(double spent, AnalysisTimeFilter filter) {
    if (limitAmount <= 0) return false;
    return spent > getAdjustedLimit(filter);
  }
}
