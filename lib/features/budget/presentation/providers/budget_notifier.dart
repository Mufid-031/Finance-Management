import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/budget/application/budget_service.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetService _service;
  final Ref _ref;

  BudgetNotifier(this._service, this._ref) : super(BudgetState());

  Future<void> saveBudget({
    String? id,
    required String categoryId,
    required double limit,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _ref.read(authNotifierProvider).user;
      final now = DateTime.now();

      final budget = Budget(
        id: id ?? '',
        categoryId: categoryId,
        userId: user!.id,
        limitAmount: limit,
        startDate: DateTime(now.year, now.month, 1), // Awal bulan
        endDate: DateTime(now.year, now.month + 1, 0), // Akhir bulan
      );

      await _service.createOrUpdateBudget(budget);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
