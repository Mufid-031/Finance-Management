import 'package:finance_management/features/budget/domain/budget.dart';

abstract class BudgetRepository {
  Stream<List<Budget>> watchBudgets(String userId);
  Future<void> setBudget(Budget budget);
  Future<void> deleteBudget(String budgetId);
}
