// Dependency Injection
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/budget/application/budget_service.dart';
import 'package:finance_management/features/budget/data/datasource/budget_firestore_datasource.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository.dart';
import 'package:finance_management/features/budget/data/repository/budget_repository_impl.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_notifier.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final budgetDatasourceProvider = Provider((ref) => BudgetFirestoreDatasource());
final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepositoryImpl(ref.watch(budgetDatasourceProvider)),
);
final budgetServiceProvider = Provider(
  (ref) => BudgetService(ref.watch(budgetRepositoryProvider)),
);

// State Notifier
final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
      return BudgetNotifier(ref.watch(budgetServiceProvider), ref);
    });

// Stream Provider
final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return const Stream.empty();
  return ref.watch(budgetServiceProvider).getBudgets(user.id);
});
