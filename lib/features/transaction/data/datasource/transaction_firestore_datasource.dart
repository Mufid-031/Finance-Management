import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TransactionDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(50) 
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTransactionsPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  Future<void> createTransaction({
    required String userId,
    required String walletId,
    String? toWalletId,
    required String categoryId,
    required Map<String, dynamic> txData,
    required double amount,
    required String type,
    required DateTime date,
  }) async {
    final userDocRef = _firestore.collection('users').doc(userId);
    final walletRef = userDocRef.collection('wallets').doc(walletId);
    final txRef = userDocRef.collection('transactions').doc();

    final month = date.month.toString().padLeft(2, '0');
    final summaryId = "${date.year}_$month";
    final budgetId = "${summaryId}_$categoryId";

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) throw Exception("Source Wallet not found!");

      DocumentSnapshot? toWalletDoc;
      if (type == 'transfer' && toWalletId != null) {
        toWalletDoc = await transaction.get(userDocRef.collection('wallets').doc(toWalletId));
      }

      DocumentSnapshot? budgetDoc;
      if (type == 'expense') {
        final budgetRef = userDocRef.collection('monthly_summaries').doc(summaryId).collection('budgets').doc(budgetId);
        budgetDoc = await transaction.get(budgetRef);
      }

      final walletData = walletDoc.data() as Map<String, dynamic>?;
      double walletBalance = (walletData?['balance'] ?? 0.0).toDouble();

      if (type == 'transfer' && toWalletDoc != null) {
        if (!toWalletDoc.exists) throw Exception("Destination Wallet not found!");
        final toWalletData = toWalletDoc.data() as Map<String, dynamic>?;
        double toWalletBalance = (toWalletData?['balance'] ?? 0.0).toDouble();
        
        final String fromCurrency = walletData?['currency'] ?? 'USD';
        final String toCurrency = toWalletData?['currency'] ?? 'USD';
        
        double amountToAdd = amount;
        if (fromCurrency != toCurrency) {
          amountToAdd = (amount / _getStaticRate(fromCurrency)) * _getStaticRate(toCurrency);
        }

        transaction.update(walletRef, {'balance': walletBalance - amount});
        transaction.update(toWalletDoc.reference, {'balance': toWalletBalance + amountToAdd});
      } else {
        bool isExpense = type == 'expense';
        transaction.update(walletRef, {'balance': isExpense ? walletBalance - amount : walletBalance + amount});
        if (isExpense && budgetDoc != null && budgetDoc.exists) {
          double currentSpent = (budgetDoc.data() as Map?)?['spentAmount'] ?? 0.0;
          transaction.update(budgetDoc.reference, {'spentAmount': currentSpent + amount});
        }
      }
      transaction.set(txRef, txData);
    });
  }

  Future<void> updateTransaction({
    required String userId,
    required String transactionId,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  }) async {
    final userDocRef = _firestore.collection('users').doc(userId);
    final txRef = userDocRef.collection('transactions').doc(transactionId);

    await _firestore.runTransaction((transaction) async {
      // --- 1. PREPARE REFS & VALUES ---
      final String oldWalletId = oldData['walletId'];
      final String? oldToWalletId = oldData['toWalletId'];
      final double oldAmount = (oldData['amount'] as num).toDouble();
      final String oldType = oldData['type'];

      final String newWalletId = newData['walletId'];
      final String? newToWalletId = newData['toWalletId'];
      final double newAmount = (newData['amount'] as num).toDouble();
      final String newType = newData['type'];

      final oldWalletRef = userDocRef.collection('wallets').doc(oldWalletId);
      final newWalletRef = userDocRef.collection('wallets').doc(newWalletId);

      // --- 2. PHASE: READS ---
      final oldWalletDoc = await transaction.get(oldWalletRef);
      final newWalletDoc = (oldWalletId == newWalletId) ? oldWalletDoc : await transaction.get(newWalletRef);

      DocumentSnapshot? oldToWalletDoc;
      if (oldType == 'transfer' && oldToWalletId != null) {
        oldToWalletDoc = await transaction.get(userDocRef.collection('wallets').doc(oldToWalletId));
      }

      DocumentSnapshot? newToWalletDoc;
      if (newType == 'transfer' && newToWalletId != null) {
        newToWalletDoc = (newToWalletId == oldToWalletId) ? oldToWalletDoc : await transaction.get(userDocRef.collection('wallets').doc(newToWalletId));
      }

      DocumentSnapshot? oldBudgetDoc;
      if (oldType == 'expense') {
        final String sumId = _getSummaryId(oldData['date']);
        oldBudgetDoc = await transaction.get(userDocRef.collection('monthly_summaries').doc(sumId).collection('budgets').doc("${sumId}_${oldData['categoryId']}"));
      }

      DocumentSnapshot? newBudgetDoc;
      if (newType == 'expense') {
        final String sumId = _getSummaryId(newData['date']);
        newBudgetDoc = await transaction.get(userDocRef.collection('monthly_summaries').doc(sumId).collection('budgets').doc("${sumId}_${newData['categoryId']}"));
      }

      // --- 3. PHASE: WRITES ---
      
      // 3a. Update Wallet Balances (Source)
      if (oldWalletDoc.exists) {
        double bal = (oldWalletDoc.data() as Map?)?['balance'] ?? 0.0;
        final currency = (oldWalletDoc.data() as Map?)?['currency'] ?? 'USD';
        
        // Kembalikan saldo lama (Undo)
        bal += (oldType == 'income') ? -oldAmount : oldAmount;
        
        // Jika wallet sama, langsung terapkan nilai baru
        if (oldWalletId == newWalletId) {
          bal += (newType == 'income') ? newAmount : -newAmount;
        }
        transaction.update(oldWalletRef, {'balance': bal});
      }

      if (oldWalletId != newWalletId && newWalletDoc.exists) {
        double bal = (newWalletDoc.data() as Map?)?['balance'] ?? 0.0;
        bal += (newType == 'income') ? newAmount : -newAmount;
        transaction.update(newWalletRef, {'balance': bal});
      }

      // 3b. Update Destination Wallets (Transfer)
      if (oldToWalletDoc != null && oldToWalletDoc.exists) {
        double bal = (oldToWalletDoc.data() as Map?)?['balance'] ?? 0.0;
        final fromCurrency = (oldWalletDoc.data() as Map?)?['currency'] ?? 'USD';
        final toCurrency = (oldToWalletDoc.data() as Map?)?['currency'] ?? 'USD';
        
        double convertedOld = (fromCurrency == toCurrency) ? oldAmount : (oldAmount / _getStaticRate(fromCurrency)) * _getStaticRate(toCurrency);
        bal -= convertedOld;

        if (oldToWalletId == newToWalletId) {
          final newFromWalletDoc = (oldWalletId == newWalletId) ? oldWalletDoc : newWalletDoc;
          final newFromCurrency = (newFromWalletDoc.data() as Map?)?['currency'] ?? 'USD';
          double convertedNew = (newFromCurrency == toCurrency) ? newAmount : (newAmount / _getStaticRate(newFromCurrency)) * _getStaticRate(toCurrency);
          bal += convertedNew;
        }
        transaction.update(oldToWalletDoc.reference, {'balance': bal});
      }

      if (newToWalletId != null && newToWalletId != oldToWalletId && newToWalletDoc != null && newToWalletDoc.exists) {
        double bal = (newToWalletDoc.data() as Map?)?['balance'] ?? 0.0;
        final newFromWalletDoc = (oldWalletId == newWalletId) ? oldWalletDoc : newWalletDoc;
        final fromCurr = (newFromWalletDoc.data() as Map?)?['currency'] ?? 'USD';
        final toCurr = (newToWalletDoc.data() as Map?)?['currency'] ?? 'USD';
        
        double convertedNew = (fromCurr == toCurr) ? newAmount : (newAmount / _getStaticRate(fromCurr)) * _getStaticRate(toCurr);
        bal += convertedNew;
        transaction.update(newToWalletDoc.reference, {'balance': bal});
      }

      // 3c. Update Budgets
      if (oldBudgetDoc != null && oldBudgetDoc.exists) {
        double spent = (oldBudgetDoc.data() as Map?)?['spentAmount'] ?? 0.0;
        spent -= oldAmount;
        if (oldBudgetDoc.id == newBudgetDoc?.id) spent += newAmount;
        transaction.update(oldBudgetDoc.reference, {'spentAmount': spent});
      }

      if (newBudgetDoc != null && newBudgetDoc.exists && newBudgetDoc.id != oldBudgetDoc?.id) {
        double spent = (newBudgetDoc.data() as Map?)?['spentAmount'] ?? 0.0;
        spent += newAmount;
        transaction.update(newBudgetDoc.reference, {'spentAmount': spent});
      }

      // Final: Update Transaction Document
      transaction.update(txRef, newData);
    });
  }

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
    required String walletId,
    String? toWalletId,
    required String categoryId,
    required double amount,
    required String type,
    required DateTime date,
  }) async {
    final userDocRef = _firestore.collection('users').doc(userId);
    final walletRef = userDocRef.collection('wallets').doc(walletId);
    final txRef = userDocRef.collection('transactions').doc(transactionId);
    final sumId = _getSummaryId(date);

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) throw Exception("Wallet not found!");

      DocumentSnapshot? toWalletDoc;
      if (type == 'transfer' && toWalletId != null) {
        toWalletDoc = await transaction.get(userDocRef.collection('wallets').doc(toWalletId));
      }

      DocumentSnapshot? budgetDoc;
      if (type == 'expense') {
        budgetDoc = await transaction.get(userDocRef.collection('monthly_summaries').doc(sumId).collection('budgets').doc("${sumId}_$categoryId"));
      }

      double currentBalance = (walletDoc.data() as Map?)?['balance'] ?? 0.0;
      if (type == 'transfer' && toWalletDoc != null && toWalletDoc.exists) {
        double toBalance = (toWalletDoc.data() as Map?)?['balance'] ?? 0.0;
        transaction.update(walletRef, {'balance': currentBalance + amount});
        transaction.update(toWalletDoc.reference, {'balance': toBalance - amount});
      } else {
        bool isExpense = type == 'expense';
        transaction.update(walletRef, {'balance': isExpense ? currentBalance + amount : currentBalance - amount});
        if (isExpense && budgetDoc != null && budgetDoc.exists) {
          double currentSpent = (budgetDoc.data() as Map?)?['spentAmount'] ?? 0.0;
          transaction.update(budgetDoc.reference, {'spentAmount': currentSpent - amount});
        }
      }
      transaction.delete(txRef);
    });
  }

  String _getSummaryId(dynamic date) {
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else {
      dt = DateTime.now();
    }
    return "${dt.year}_${dt.month.toString().padLeft(2, '0')}";
  }

  double _getStaticRate(String code) {
    switch (code) {
      case 'IDR': return 16000.0;
      case 'EUR': return 0.92;
      case 'GBP': return 0.79;
      case 'JPY': return 150.0;
      default: return 1.0;
    }
  }
}
