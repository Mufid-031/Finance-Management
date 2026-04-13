import 'package:finance_management/features/budget/data/datasource/budget_firestore_datasource.dart';
import 'package:finance_management/features/budget/data/dto/budget_dto.dart';
import 'package:finance_management/features/budget/data/dto/monthly_summary_dto.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetFirestoreDatasource datasource;

  BudgetRepositoryImpl(this.datasource);

  @override
  Stream<MonthlySummary?> watchMonthlySummary(String userId, String summaryId) {
    return datasource.getMonthlySummaryStream(userId, summaryId).map((doc) {
      if (!doc.exists) return null;
      return MonthlySummaryDTO.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      ).toDomain();
    });
  }

  @override
  Stream<List<Budget>> watchCategoryBudgets(String userId, String summaryId) {
    return datasource
        .getBudgetsBySummary(userId, summaryId, {})
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => BudgetDTO.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ).toDomain(),
              )
              .toList(),
        );
  }

  @override
  Future<void> createMonthlySummary(String userId, MonthlySummary summary) {
    final dto = MonthlySummaryDTO.fromDomain(summary);
    return datasource.createMonthlySummary(userId, dto.toMap());
  }

  @override
  Future<void> upsertBudget(String userId, String summaryId, Budget budget) {
    final dto = BudgetDTO.fromDomain(budget);
    return datasource.upsertBudget(userId, summaryId, dto.toMap());
  }

  @override
  Future<void> updateCategoryCount(
    String userId,
    String summaryId,
    int change,
  ) {
    return datasource.updateCategoryCount(userId, summaryId, change);
  }

  @override
  Future<void> deleteBudget(String userId, String summaryId, String budgetId) {
    return datasource.removeCategoryBudget(userId, summaryId, budgetId);
  }

  @override
  Stream<List<MonthlySummary>> watchAllSummaries(String userId) {
    return datasource
        .getAllSummaries(userId)
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MonthlySummaryDTO.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ).toDomain(),
              )
              .toList(),
        );
  }
}
