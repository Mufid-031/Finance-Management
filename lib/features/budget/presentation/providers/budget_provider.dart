import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/budget/application/budget_service.dart';
import 'package:finance_management/features/budget/data/datasource/budget_firestore_datasource.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository_impl.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_notifier.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final budgetDatasourceProvider = Provider((ref) => BudgetFirestoreDatasource());

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(budgetDatasourceProvider));
});

final budgetServiceProvider = Provider((ref) {
  return BudgetService(
    ref.watch(budgetRepositoryProvider) as BudgetRepositoryImpl,
  );
});

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
      return BudgetNotifier(ref.watch(budgetServiceProvider), ref);
    });

final remainingAllocationProvider = Provider((ref) {
  final state = ref.watch(budgetNotifierProvider);
  if (state.activeSummary == null) return 0.0;

  final totalAllocated = state.categoryBudgets.fold(
    0.0,
    (sum, b) => sum + b.limitAmount,
  );
  return state.activeSummary!.totalLimit - totalAllocated;
});

final monthlySummariesStreamProvider = StreamProvider<List<MonthlySummary>>((
  ref,
) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return Stream.value([]);

  final service = ref.watch(budgetServiceProvider);
  return service.watchAllSummaries(user.id);
});
