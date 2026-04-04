import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String userId) =>
      _firestore.collection('users').doc(userId).collection('categories');

  Stream<List<Map<String, dynamic>>> watchAll(String userId) {
    return _ref(userId).snapshots().map(
      (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  Future<void> create(String userId, Map<String, dynamic> data) =>
      _ref(userId).add(data);
  Future<void> update(String userId, String id, Map<String, dynamic> data) =>
      _ref(userId).doc(id).update(data);
  Future<void> delete(String userId, String id) =>
      _ref(userId).doc(id).delete();
}
