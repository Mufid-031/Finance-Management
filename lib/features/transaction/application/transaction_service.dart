import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionService {
  final TransactionRepository repository;

  TransactionService(this.repository);

  Future<List<Transaction>> getTransactions(String userId) {
    return repository.getAll(userId);
  }

  Future<void> createTransaction(String userId, Transaction transaction) {
    if (transaction.amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    return repository.create(userId, transaction);
  }

  Future<void> updateTransaction(
    String userId,
    String id,
    Transaction transaction,
  ) {
    if (transaction.amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    return repository.update(userId, id, transaction);
  }

  Future<void> deleteTransaction(String userId, String id) {
    return repository.delete(userId, id);
  }
}
