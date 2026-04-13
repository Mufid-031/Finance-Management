import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _summaryRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries');
  }

  Stream<DocumentSnapshot> getMonthlySummaryStream(
    String userId,
    String summaryId,
  ) {
    return _summaryRef(userId).doc(summaryId).snapshots();
  }

  Future<void> createMonthlySummary(String userId, Map<String, dynamic> data) {
    return _summaryRef(userId).doc(data['id']).set(data);
  }

  Stream<QuerySnapshot> getBudgetsBySummary(
    String userId,
    String summaryId,
    Map<String, dynamic> data,
  ) {
    return _summaryRef(userId).doc(summaryId).collection('budgets').snapshots();
  }

  Future<void> upsertBudget(
    String userId,
    String summaryId,
    Map<String, dynamic> data,
  ) {
    return _summaryRef(userId)
        .doc(summaryId)
        .collection('budgets')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  Future<void> updateCategoryCount(
    String userId,
    String summaryId,
    int change,
  ) {
    return _summaryRef(
      userId,
    ).doc(summaryId).update({'categoryCount': FieldValue.increment(change)});
  }

  Future<void> removeCategoryBudget(
    String userId,
    String summaryId,
    String budgetId,
  ) {
    return _summaryRef(
      userId,
    ).doc(summaryId).collection('budgets').doc(budgetId).delete();
  }

  Stream<QuerySnapshot> getAllSummaries(String userId) {
    return _summaryRef(userId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots();
  }
}
