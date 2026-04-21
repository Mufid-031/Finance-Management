import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<(List<domain.Transaction>, dynamic)> getTransactionsPaginated(
    String userId, {
    dynamic lastCursor,
    int limit = 20,
  }) async {
    final snapshot = await datasource.getTransactionsPaginated(
      userId: userId,
      lastDocument: lastCursor as DocumentSnapshot?,
      limit: limit,
    );

    final transactions = snapshot.docs.map((doc) {
      return TransactionDTO.fromMap(doc.id, doc.data()).toDomain();
    }).toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return (transactions, lastDoc);
  }

  @override
  Future<void> addTransaction(domain.Transaction tx) async {
    final dto = TransactionDTO.fromDomain(tx);
    return datasource.createTransaction(
      userId: tx.userId,
      walletId: tx.walletId,
      toWalletId: tx.toWalletId,
      categoryId: tx.categoryId,
      txData: dto.toMap(),
      amount: tx.amount,
      type: tx.type.name,
      date: tx.date,
    );
  }

  @override
  Future<void> updateTransaction(domain.Transaction oldTx, domain.Transaction newTx) async {
    final oldDto = TransactionDTO.fromDomain(oldTx);
    final newDto = TransactionDTO.fromDomain(newTx);
    return datasource.updateTransaction(
      userId: newTx.userId,
      transactionId: newTx.id,
      oldData: oldDto.toMap(),
      newData: newDto.toMap(),
    );
  }

  @override
  Future<void> deleteTransaction(domain.Transaction tx) async {
    return datasource.deleteTransaction(
      userId: tx.userId,
      transactionId: tx.id,
      walletId: tx.walletId,
      toWalletId: tx.toWalletId,
      categoryId: tx.categoryId,
      amount: tx.amount,
      type: tx.type.name,
      date: tx.date,
    );
  }
}
