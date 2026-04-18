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
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref.watch(transactionServiceProvider), ref);
    });

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  final user = authStateAsync.value;

  if (user == null) return Stream.value([]);

  return ref.watch(transactionServiceProvider).getRecentTransactions(user.uid);
});

enum TransactionFilter { all, spending, income }

final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.all,
);

final transactionSearchProvider = StateProvider<String>((ref) => "");

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final filter = ref.watch(transactionFilterProvider);
  final searchQuery = ref.watch(transactionSearchProvider).toLowerCase();

  return transactions.applyFilter(
    selectedFilter: filter,
    searchQuery: searchQuery,
  );
});
