import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/transaction/application/transaction_service.dart';
import 'package:finance_management/features/transaction/data/datasource/transaction_firestore_datasource.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository_impl.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/domain/transaction_filter_helper.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_notifier.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final transactionDatasourceProvider = Provider(
  (ref) => TransactionDatasource(),
);

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(transactionDatasourceProvider));
});

final transactionServiceProvider = Provider((ref) {
  return TransactionService(ref.watch(transactionRepositoryProvider));
});

final transactionNotifierProvider =
    StateNotifierProvider.autoDispose<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref.watch(transactionServiceProvider), ref);
    });

final transactionsStreamProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  final user = authStateAsync.value;

  if (user == null) return Stream.value([]);

  return ref.watch(transactionServiceProvider).getRecentTransactions(user.uid);
});

// BOSS, Tambah tipe transfer di filter
enum TransactionFilter { all, spending, income, transfer }

final transactionFilterProvider = StateProvider.autoDispose<TransactionFilter>(
  (ref) => TransactionFilter.all,
);

final transactionSearchProvider = StateProvider.autoDispose<String>((ref) => "");

final walletTransactionsProvider = Provider.autoDispose.family<List<Transaction>, String>((ref, walletId) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  return transactions.where((tx) => tx.walletId == walletId || tx.toWalletId == walletId).toList();
});

final totalMonthlyExpenseProvider = Provider.autoDispose<double>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final now = DateTime.now();
  
  return transactions
      .where((tx) => 
          tx.type == TransactionType.expense &&
          tx.date.month == now.month &&
          tx.date.year == now.year)
      .fold(0.0, (sum, tx) => sum + tx.amount);
});

final filteredTransactionsProvider = Provider.autoDispose<List<Transaction>>((ref) {
  final txState = ref.watch(transactionNotifierProvider);
  final transactions = txState.transactions;
  final filter = ref.watch(transactionFilterProvider);
  final searchQuery = ref.watch(transactionSearchProvider).toLowerCase();

  return transactions.applyFilter(
    selectedFilter: filter,
    searchQuery: searchQuery,
  );
});
