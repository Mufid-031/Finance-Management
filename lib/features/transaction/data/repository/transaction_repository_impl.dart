import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/features/transaction/data/datasource/transaction_firestore_datasource.dart';
import 'package:finance_management/features/transaction/data/dto/transaction_dto.dart';
import 'package:finance_management/features/transaction/data/repository/transaction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:finance_management/features/transaction/domain/transaction.dart'
    as TransactionDomain;

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDatasource datasource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionRepositoryImpl(this.datasource);

  @override
  Stream<List<TransactionDomain.Transaction>> watchTransactions(String userId) {
    return datasource
        .watchTransactions(userId)
        .map(
          (list) => list
              .map((map) => TransactionDTO.fromMap(map['id'], map).toDomain())
              .toList(),
        );
  }

  @override
  Future<void> addTransaction(TransactionDomain.Transaction tx) async {
    // Kita jalankan Transaction di level Repository Impl
    // agar bisa mengontrol wallet & transaction sekaligus
    final userRef = _firestore.collection('users').doc(tx.userId);
    final walletRef = userRef.collection('wallets').doc(tx.walletId);
    final txRef = userRef.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      // 1. Ambil data wallet terbaru
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) throw Exception("Wallet tidak ditemukan!");

      double currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();

      // 2. Hitung saldo baru
      double newBalance = tx.type == TransactionDomain.TransactionType.income
          ? currentBalance + tx.amount
          : currentBalance - tx.amount;

      // 3. Validasi: Jangan biarkan saldo negatif jika itu pengeluaran (Opsional)
      // if (newBalance < 0 && tx.type == TransactionType.expense) {
      //   throw Exception("Saldo tidak mencukupi!");
      // }

      // 4. Eksekusi simpan transaksi (menggunakan DTO)
      final dto = TransactionDTO.fromDomain(tx);
      transaction.set(txRef, dto.toMap());

      // 5. Update saldo di dokumen wallet
      transaction.update(walletRef, {'balance': newBalance});
    });
  }
}
