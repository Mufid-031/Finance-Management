import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
  }

  Future<void> saveBudget(
    String userId,
    Map<String, dynamic> data, {
    String? id,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets');
    if (id != null) {
      await ref.doc(id).update(data);
    } else {
      await ref.add(data);
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    await _firestore.collection('budgets').doc(budgetId).delete();
  }
}
