import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> watchSettings(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      return (data?['settings'] as Map<String, dynamic>?) ?? {};
    });
  }

  // Ambil data sekali saja
  Future<Map<String, dynamic>> getSettings(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    return (data?['settings'] as Map<String, dynamic>?) ?? {};
  }

  Future<void> updateSettings(
    String userId,
    Map<String, dynamic> settingsData,
  ) {
    return _firestore.collection('users').doc(userId).update({
      'settings': settingsData,
    });
  }
}
