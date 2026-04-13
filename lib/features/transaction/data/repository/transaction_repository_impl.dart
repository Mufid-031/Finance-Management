import 'package:finance_management/features/transaction/data/datasource/transaction_firestore_datasource.dart';
import 'package:finance_management/features/transaction/data/dto/transaction_dto.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart'
    as domain;

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Stream<List<domain.Transaction>> watchTransactions(String userId) {
    return datasource
        .watchTransactions(userId)
        .map(
          (list) => list
              .map((map) => TransactionDTO.fromMap(map['id'], map).toDomain())
              .toList(),
        );
  }

  @override
  Future<void> addTransaction(domain.Transaction tx) async {
    final dto = TransactionDTO.fromDomain(tx);

    return datasource.createTransaction(
      userId: tx.userId,
      walletId: tx.walletId,
      categoryId: tx.categoryId,
      txData: dto.toMap(),
      amount: tx.amount,
      isExpense: tx.type == domain.TransactionType.expense,
      date: tx.date,
    );
  }
}
