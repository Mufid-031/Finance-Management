import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTransactionsByRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
