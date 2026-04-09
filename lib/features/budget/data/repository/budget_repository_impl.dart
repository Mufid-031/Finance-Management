import 'package:finance_management/features/budget/data/datasource/budget_firestore_datasource.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/data/dto/budget_dto.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetFirestoreDatasource datasource;
  BudgetRepositoryImpl(this.datasource);

  @override
  Stream<List<Budget>> watchBudgets(String userId) {
    return datasource
        .watchBudgets(userId)
        .map(
          (list) => list
              .map((m) => BudgetDTO.fromMap(m['id'], m).toDomain())
              .toList(),
        );
  }

  @override
  Future<void> setBudget(Budget budget) async {
    final dto = BudgetDTO(
      id: budget.id,
      categoryId: budget.categoryId,
      userId: budget.userId,
      limitAmount: budget.limitAmount,
      startDate: budget.startDate,
      endDate: budget.endDate,
    );
    await datasource.saveBudget(
      budget.userId,
      dto.toMap(),
      id: budget.id.isEmpty ? null : budget.id,
    );
  }

  @override
  Future<void> deleteBudget(String budgetId) {
    return datasource.deleteBudget(budgetId);
  }
}
