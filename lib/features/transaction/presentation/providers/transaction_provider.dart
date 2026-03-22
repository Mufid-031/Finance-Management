import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/transaction/application/transaction_service.dart';
import 'package:finance_management/features/transaction/data/datasource/transaction_firestore_datasource.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository_impl.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_notifier.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_state.dart';

final transactionDataSource = Provider<TransactionFirestoreDatasource>((ref) {
  return TransactionFirestoreDatasource();
});

final transactionRepository = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.read(transactionDataSource));
});

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(ref.read(transactionRepository));
});

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref.read(transactionServiceProvider), ref);
    });
