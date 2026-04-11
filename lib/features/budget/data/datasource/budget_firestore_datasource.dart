import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetFirestoreDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Watch ringkasan bulanan
  Stream<List<Map<String, dynamic>>> watchSummaries(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries')
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Watch detail kategori di bulan tertentu
  Stream<List<Map<String, dynamic>>> watchBudgets(String userId, int m, int y) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .where('month', isEqualTo: m)
        .where('year', isEqualTo: y)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> saveBudgetWithSummary(
    String userId,
    Map<String, dynamic> budgetData,
    Map<String, dynamic> summaryData,
    String summaryId,
  ) async {
    final batch = _db.batch();

    // 1. Dokumen Budget Kategori
    final budgetRef = _db
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc();
    batch.set(budgetRef, budgetData);

    // 2. Dokumen Monthly Summary (Update total limit menggunakan Increment)
    final summaryRef = _db
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries')
        .doc(summaryId);

    batch.set(summaryRef, {
      'month': summaryData['month'],
      'year': summaryData['year'],
      'totalLimit': FieldValue.increment(summaryData['totalLimit']),
      'categoryCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
