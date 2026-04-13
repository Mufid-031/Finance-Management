import 'dart:async';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/budget/application/budget_service.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_state.dart';
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
    final user = _ref.read(authNotifierProvider).user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    _summarySubscription?.cancel();
    _budgetsSubscription?.cancel();

    final now = DateTime.now();

    _summarySubscription = _service.watchSummary(user.id, now).listen((
      summary,
    ) {
      state = state.copyWith(activeSummary: summary, isLoading: false);
    });

    _budgetsSubscription = _service.watchBudgets(user.id, now).listen((
      budgets,
    ) {
      state = state.copyWith(categoryBudgets: budgets, isLoading: false);
    });
  }

  Future<void> setupMonthlyBudget(double limit) async {
    try {
      final user = _ref.read(authNotifierProvider).user;
      if (user == null) return;

      state = state.copyWith(isLoading: true);
      await _service.setupMonthlyBudget(user.id, limit);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addCategoryBudget(String categoryId, double limit) async {
    try {
      final user = _ref.read(authNotifierProvider).user;
      if (user == null) return;

      await _service.addCategoryBudget(user.id, categoryId, limit);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> removeCategoryBudget(String summaryId, String budgetId) async {
    try {
      final user = _ref.read(authNotifierProvider).user;
      if (user == null) return;

      await _service.deleteCategoryBudget(user.id, summaryId, budgetId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  @override
  void dispose() {
    _summarySubscription?.cancel();
    _budgetsSubscription?.cancel();
    super.dispose();
  }
}
