import 'package:finance_management/features/transaction/domain/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll(String userId);
  Future<void> create(String userId, Transaction data);
  Future<void> update(String userId, String id, Transaction data);
  Future<void> delete(String userId, String id);
}
