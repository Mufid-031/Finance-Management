import 'package:finance_management/features/budget/data/repository/budget_repository.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';

class BudgetService {
  final BudgetRepository repository;
  BudgetService(this.repository);

  Stream<List<MonthlySummary>> getSummaries(String userId) =>
      repository.watchMonthlySummaries(userId);

  Stream<List<Budget>> getBudgetsByMonth(String userId, int m, int y) =>
      repository.watchBudgetsByMonth(userId, m, y);

  Future<void> addBudget(Budget budget) => repository.setBudget(budget);
}
