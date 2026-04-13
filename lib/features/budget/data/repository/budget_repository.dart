import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';

abstract class BudgetRepository {
  Stream<MonthlySummary?> watchMonthlySummary(String userId, String summaryId);
  Stream<List<Budget>> watchCategoryBudgets(String userId, String summaryId);
  Future<void> createMonthlySummary(String userId, MonthlySummary summary);
  Future<void> upsertBudget(String userId, String summaryId, Budget budget);
  Future<void> updateCategoryCount(String userId, String summaryId, int change);
  Future<void> deleteBudget(String userId, String summaryId, String budgetId);
  Stream<List<MonthlySummary>> watchAllSummaries(String userId);
}
