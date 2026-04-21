import 'dart:async';
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

  /// BOSS, Muat batch pertama (panggil saat masuk halaman)
  Future<void> fetchInitialBatch() async {
    if (state.transactions.isNotEmpty) return; // Sudah ada data
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final (results, lastDoc) = await _service.getTransactionsPaginated(userId, limit: 20);
      
      state = state.copyWith(
        isLoading: false,
        transactions: results,
        lastCursor: lastDoc,
        hasMore: results.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// BOSS, Muat 20 data berikutnya saat scroll mencapai bawah
  Future<void> fetchNextBatch() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final (results, lastDoc) = await _service.getTransactionsPaginated(
        userId,
        lastCursor: state.lastCursor,
        limit: 20,
      );

      state = state.copyWith(
        isLoadingMore: false,
        transactions: [...state.transactions, ...results],
        lastCursor: lastDoc,
        hasMore: results.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    state = TransactionState(); // Reset state
    await fetchInitialBatch();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String walletId,
    String? toWalletId,
    required String categoryId,
    required TransactionType type,
    DateTime? date,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final tx = Transaction(
        id: '', 
        userId: userId,
        walletId: walletId,
        toWalletId: toWalletId,
        categoryId: categoryId,
        title: title,
        amount: amount,
        type: type,
        date: date ?? DateTime.now(),
      );

      await _service.saveTransaction(tx);
      // BOSS, setelah tambah baru, lebih aman refresh list atau masukkan ke index 0
      state = state.copyWith(isLoading: false, transactions: [tx, ...state.transactions]);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> editTransaction({
    required Transaction oldTx,
    required String title,
    required double amount,
    required String walletId,
    String? toWalletId,
    required String categoryId,
    required TransactionType type,
    required DateTime date,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final newTx = Transaction(
        id: oldTx.id,
        userId: oldTx.userId,
        walletId: walletId,
        toWalletId: toWalletId,
        categoryId: categoryId,
        title: title,
        amount: amount,
        type: type,
        date: date,
      );

      await _service.repository.updateTransaction(oldTx, newTx);
      
      final updatedList = state.transactions.map((t) => t.id == oldTx.id ? newTx : t).toList();
      state = state.copyWith(isLoading: false, transactions: updatedList);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteTransaction(Transaction tx) async {
    final previousTransactions = state.transactions;
    try {
      // BOSS, Update list secara lokal dulu agar Dismissible tidak error
      final updatedList =
          state.transactions.where((t) => t.id != tx.id).toList();
      state = state.copyWith(transactions: updatedList, errorMessage: null);

      await _service.removeTransaction(tx);
    } catch (e) {
      // Rollback jika gagal
      state = state.copyWith(
        transactions: previousTransactions,
        errorMessage: e.toString(),
      );
    }
  }
}
