import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/transaction/application/transaction_service.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_state.dart';

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionService service;
  final Ref ref;

  TransactionNotifier(this.service, this.ref) : super(TransactionState());

  String get userId => ref.read(authNotifierProvider).user!.id;

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);

    final transactions = await service.getTransactions(userId);

    state = state.copyWith(transactions: transactions, isLoading: false);
  }

  Future<void> createTransaction(Transaction transaction) async {
    await service.createTransaction(userId, transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(String id, Transaction transaction) async {
    await service.updateTransaction(userId, id, transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await service.deleteTransaction(userId, id);
    await loadTransactions();
  }
}
