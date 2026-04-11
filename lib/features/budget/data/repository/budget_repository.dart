import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart'; // <--- Import ini

abstract class BudgetRepository {
  Stream<List<MonthlySummary>> watchMonthlySummaries(String userId);

  Stream<List<Budget>> watchBudgetsByMonth(String userId, int month, int year);

  Future<void> setBudget(Budget budget);

  Future<void> deleteBudget(
    String userId,
    String budgetId,
    int month,
    int year,
  );
}
