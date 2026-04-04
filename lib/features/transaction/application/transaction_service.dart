import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionService {
  final TransactionRepository repository;
  TransactionService(this.repository);

  Future<void> saveTransaction(Transaction tx) async {
    return await repository.addTransaction(tx);
  }

  Stream<List<Transaction>> getRecentTransactions(String userId) {
    return repository.watchTransactions(userId);
  }
}
