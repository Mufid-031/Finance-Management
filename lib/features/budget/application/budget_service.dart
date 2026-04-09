import 'package:finance_management/features/budget/data/repository/budget_repository.dart';
import 'package:finance_management/features/budget/domain/budget.dart';

class BudgetService {
  final BudgetRepository repository;
  BudgetService(this.repository);

  Stream<List<Budget>> getBudgets(String userId) =>
      repository.watchBudgets(userId);
  Future<void> createOrUpdateBudget(Budget budget) =>
      repository.setBudget(budget);

  Future<void> deleteBudget(String budgetId) =>
      repository.deleteBudget(budgetId);
}
