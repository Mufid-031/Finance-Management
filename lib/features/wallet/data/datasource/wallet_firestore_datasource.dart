import 'package:cloud_firestore/cloud_firestore.dart';

class WalletFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return _firestore.collection('users').doc(userId).collection('wallets');
  }

  Stream<List<Map<String, dynamic>>> watchAll(String userId) {
    return _ref(userId).snapshots().map(
      (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  Future<void> create(String userId, Map<String, dynamic> data) async {
    await _ref(userId).add(data);
  }

  Future<void> update(String userId, String walletId, Map<String, dynamic> data) async {
    await _ref(userId).doc(walletId).update(data);
  }

  Future<void> delete(String userId, String walletId) async {
    await _ref(userId).doc(walletId).delete();
  }
}
