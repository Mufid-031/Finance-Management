import 'package:finance_management/features/transaction/domain/transaction.dart'
    as TransactionDomain;

abstract class TransactionRepository {
  Stream<List<TransactionDomain.Transaction>> watchTransactions(String userId);
  Future<void> addTransaction(TransactionDomain.Transaction tx);
}
