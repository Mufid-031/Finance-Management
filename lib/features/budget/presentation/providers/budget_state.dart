// lib/features/budget/presentation/providers/budget_state.dart
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';

class BudgetState {
  final bool isLoading;
  final String? errorMessage;
  final MonthlySummary? activeSummary;
  final List<Budget> categoryBudgets;

  BudgetState({
    this.isLoading = false,
    this.errorMessage,
    this.activeSummary,
    this.categoryBudgets = const [],
  });

  BudgetState copyWith({
    bool? isLoading,
    String? errorMessage,
    MonthlySummary? activeSummary,
    List<Budget>? categoryBudgets,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Kita biarkan null jika tidak dioper
      activeSummary: activeSummary ?? this.activeSummary,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }
}
