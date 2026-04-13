import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository.dart';

class BudgetService {
  final BudgetRepository _repository;

  BudgetService(this._repository);

  String generateSummaryId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return "${date.year}_$month";
  }

  Stream<MonthlySummary?> watchSummary(String userId, DateTime date) {
    final summaryId = generateSummaryId(date);
    return _repository.watchMonthlySummary(userId, summaryId);
  }

  Stream<List<Budget>> watchBudgets(String userId, DateTime date) {
    final summaryId = generateSummaryId(date);
    return _repository.watchCategoryBudgets(userId, summaryId);
  }

  Future<void> setupMonthlyBudget(String userId, double totalLimit) async {
    final now = DateTime.now();
    final summaryId = generateSummaryId(now);

    final summary = MonthlySummary(
      id: summaryId,
      userId: userId,
      totalLimit: totalLimit,
      month: now.month,
      year: now.year,
      categoryCount: 0,
    );

    await _repository.createMonthlySummary(userId, summary);
  }

  Future<void> addCategoryBudget(
    String userId,
    String categoryId,
    double limit,
  ) async {
    final now = DateTime.now();
    final summaryId = generateSummaryId(now);

    // ID Budget unik: 2026_04_IDKATEGORI
    final budgetId = "${summaryId}_$categoryId";

    final budget = Budget(
      id: budgetId,
      monthlySummaryId: summaryId,
      categoryId: categoryId,
      limitAmount: limit,
      spentAmount: 0.0,
    );

    await _repository.upsertBudget(userId, summaryId, budget);
    await _repository.updateCategoryCount(userId, summaryId, 1);
  }

  Future<void> deleteCategoryBudget(
    String userId,
    String summaryId,
    String budgetId,
  ) async {
    await _repository.deleteBudget(userId, summaryId, budgetId);
    await _repository.updateCategoryCount(userId, summaryId, -1);
  }

  Stream<List<MonthlySummary>> watchAllSummaries(String userId) {
    return _repository.watchAllSummaries(userId);
  }
}
