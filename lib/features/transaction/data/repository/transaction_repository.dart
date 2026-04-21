import 'package:finance_management/features/transaction/domain/transaction.dart'
    as TransactionDomain;

abstract class TransactionRepository {
  Stream<List<TransactionDomain.Transaction>> watchTransactions(String userId);

  /// BOSS, ambil data dengan paginasi
  Future<(List<TransactionDomain.Transaction>, dynamic)>
  getTransactionsPaginated(String userId, {dynamic lastCursor, int limit = 20});

  Future<void> addTransaction(TransactionDomain.Transaction tx);
  Future<void> updateTransaction(
    TransactionDomain.Transaction oldTx,
    TransactionDomain.Transaction newTx,
  );
  Future<void> deleteTransaction(TransactionDomain.Transaction tx);
}
