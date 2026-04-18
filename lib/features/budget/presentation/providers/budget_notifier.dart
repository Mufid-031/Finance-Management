import 'dart:async';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/budget/application/budget_service.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_state.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetService _service;
  final Ref _ref;

  StreamSubscription? _summarySubscription;
  StreamSubscription? _budgetsSubscription;

  BudgetNotifier(this._service, this._ref) : super(BudgetState()) {
    initCurrentMonth();
  }

  void initCurrentMonth() {
    final userId = _ref.read(authStateChangesProvider).value?.uid;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    _summarySubscription?.cancel();
    _budgetsSubscription?.cancel();

    final now = DateTime.now();

    _summarySubscription = _service.watchSummary(userId, now).listen((summary) {
      state = state.copyWith(activeSummary: summary);
    });

    _budgetsSubscription = _service.watchBudgets(userId, now).listen((budgets) {
      _updateBudgetsWithTransactions(budgets);
    });
  }

  void _updateBudgetsWithTransactions(List<Budget> budgets) {
    final transactionsAsync = _ref.watch(transactionsStreamProvider);

    transactionsAsync.whenData((transactions) {
      final updatedBudgets = budgets.map((budget) {
        final actualSpent = _service.calculateSpentForCategory(
          transactions,
          budget.categoryId,
        );

        return budget.copyWith(spentAmount: actualSpent);
      }).toList();

      state = state.copyWith(categoryBudgets: updatedBudgets, isLoading: false);
    });
  }

  Future<void> setupMonthlyBudget(double limit) async {
    try {
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      state = state.copyWith(isLoading: true);
      await _service.setupMonthlyBudget(userId, limit);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addCategoryBudget(String categoryId, double limit) async {
    try {
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await _service.addCategoryBudget(userId, categoryId, limit);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> removeCategoryBudget(String summaryId, String budgetId) async {
    try {
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await _service.deleteCategoryBudget(userId, summaryId, budgetId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }


  Future<void> refreshAndSync() async {
    final userId = _ref.read(authStateChangesProvider).value?.uid;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    final transactions = _ref.read(transactionsStreamProvider).value ?? [];
    final summaryId = _service.generateSummaryId(DateTime.now());

    await _service.syncBudgetSpentAmounts(
      userId,
      summaryId,
      transactions,
      state.categoryBudgets,
    );

    initCurrentMonth();
    state = state.copyWith(isLoading: false);
  }

  @override
  void dispose() {
    _summarySubscription?.cancel();
    _budgetsSubscription?.cancel();
    super.dispose();
  }
}
