import 'package:finance_management/features/budget/data/datasource/budget_firestore_datasource.dart';
import 'package:finance_management/features/budget/data/dto/monthly_summary_dto.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/data/dto/budget_dto.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetFirestoreDatasource datasource;
  BudgetRepositoryImpl(this.datasource);

  @override // <--- Pastikan ada override
  Stream<List<MonthlySummary>> watchMonthlySummaries(String userId) {
    return datasource.watchSummaries(userId).map((list) {
      return list
          .map((e) => MonthlySummaryDTO.fromMap(e['id'], e).toDomain())
          .toList();
    });
  }

  // Lengkapi method lainnya agar tidak error...
  @override
  Stream<List<Budget>> watchBudgetsByMonth(String userId, int month, int year) {
    return datasource.watchBudgets(userId, month, year).map((list) {
      return list.map((e) => BudgetDTO.fromMap(e['id'], e).toDomain()).toList();
    });
  }

  @override
  Future<void> setBudget(Budget budget) async {
    // Logic setBudget yang menggunakan batch write ke summary
  }

  @override
  Future<void> deleteBudget(
    String userId,
    String budgetId,
    int month,
    int year,
  ) async {
    // Logic delete
  }
}
