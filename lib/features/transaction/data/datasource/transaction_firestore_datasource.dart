import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Query transaksi berdasarkan range waktu (untuk Chart nantinya)
  Stream<List<Map<String, dynamic>>> watchTransactions(
    String userId, {
    DateTime? start,
    DateTime? end,
  }) {
    var query = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true);

    return query.snapshots().map(
      (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  // ATOMIC TRANSACTION: Simpan Transaksi + Update Saldo Wallet
  Future<void> createTransaction(
    String userId,
    Map<String, dynamic> txData,
    String walletId,
    double amount,
    bool isIncome,
  ) async {
    final userRef = _firestore.collection('users').doc(userId);
    final walletRef = userRef.collection('wallets').doc(walletId);
    final txRef = userRef.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) throw Exception("Wallet tidak ditemukan!");

      double currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();
      double newBalance = isIncome
          ? currentBalance + amount
          : currentBalance - amount;

      transaction.set(txRef, txData); // Simpan transaksi
      transaction.update(walletRef, {'balance': newBalance}); // Update saldo
    });
  }
}
