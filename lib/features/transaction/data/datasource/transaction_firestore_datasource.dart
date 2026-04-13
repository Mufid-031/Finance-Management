import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> createTransaction({
    required String userId,
    required String walletId,
    required String categoryId,
    required Map<String, dynamic> txData,
    required double amount,
    required bool isExpense,
    required DateTime date,
  }) async {
    final userDocRef = _firestore.collection('users').doc(userId);
    final walletRef = userDocRef.collection('wallets').doc(walletId);
    final txRef = userDocRef.collection('transactions').doc();

    final month = date.month.toString().padLeft(2, '0');
    final summaryId = "${date.year}_$month"; // Hasil: 2026_04
    final budgetId = "${summaryId}_$categoryId";

    final budgetRef = userDocRef
        .collection('monthly_summaries')
        .doc(summaryId)
        .collection('budgets')
        .doc(budgetId);

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) throw Exception("Wallet tidak ditemukan!");

      DocumentSnapshot? budgetDoc;
      if (isExpense) {
        budgetDoc = await transaction.get(budgetRef);
      }

      double currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();
      double newBalance = isExpense
          ? currentBalance - amount
          : currentBalance + amount;

      transaction.set(txRef, txData);

      transaction.update(walletRef, {'balance': newBalance});

      if (isExpense && budgetDoc != null && budgetDoc.exists) {
        double currentSpent =
            (budgetDoc.data() as Map<String, dynamic>)['spentAmount'] ?? 0.0;
        transaction.update(budgetRef, {'spentAmount': currentSpent + amount});
      }
    });
  }
}
