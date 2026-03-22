import 'package:finance_management/features/transaction/data/datasource/transaction_firestore_datasource.dart';
import 'package:finance_management/features/transaction/data/dto/transaction_dto.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionFirestoreDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Future<List<Transaction>> getAll(String userId) async {
    final data = await datasource.getAll(userId);
    return data.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> create(String userId, Transaction transaction) async {
    final dto = TransactionDTO.fromDomain(transaction);
    await datasource.create(userId, dto);
  }

  @override
  Future<void> update(String userId, String id, Transaction transaction) async {
    final dto = TransactionDTO.fromDomain(transaction);
    await datasource.update(userId, id, dto);
  }

  @override
  Future<void> delete(String userId, String id) async {
    await datasource.delete(userId, id);
  }
}
