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
    required String categoryId,
    required double limit,
    DateTime? targetDate, // Tambahkan parameter ini
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _ref.read(authNotifierProvider).user;
      final date =
          targetDate ??
          DateTime.now(); // Gunakan tanggal yang dipilih dari modal

      final budget = Budget(
        id: '',
        categoryId: categoryId,
        userId: user!.id,
        limitAmount: limit,
        startDate: DateTime(date.year, date.month, 1),
        endDate: DateTime(date.year, date.month + 1, 0),
      );

      await _service.addBudget(budget);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
