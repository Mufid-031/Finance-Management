import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/transaction/application/transaction_service.dart';
import 'package:finance_management/features/transaction/data/datasource/transaction_firestore_datasource.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository_impl.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_notifier.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 1. Datasource
final transactionDatasourceProvider = Provider(
  (ref) => TransactionDatasource(),
);

// 2. Repository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(transactionDatasourceProvider));
});

// 3. Service
final transactionServiceProvider = Provider((ref) {
  return TransactionService(ref.watch(transactionRepositoryProvider));
});

// 4. Notifier (Untuk Action Save)
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref.watch(transactionServiceProvider), ref);
    });

// 5. Stream (Untuk Tampilan Real-time di Home)
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return Stream.value([]);

  return ref.watch(transactionServiceProvider).getRecentTransactions(user.id);
});
