import 'package:finance_management/features/transaction/application/transaction_service.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'transaction_state.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionService _service;
  final Ref _ref;

  TransactionNotifier(this._service, this._ref) : super(TransactionState());

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String walletId,
    required String categoryId,
    required TransactionType type,
    DateTime? date,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final user = _ref.read(authNotifierProvider).user;
      if (user == null) throw Exception("User tidak terautentikasi");

      final tx = Transaction(
        id: '', // Firestore akan generate ID otomatis
        userId: user.id,
        walletId: walletId,
        categoryId: categoryId,
        title: title,
        amount: amount,
        type: type,
        date: date ?? DateTime.now(),
      );

      await _service.saveTransaction(tx);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
