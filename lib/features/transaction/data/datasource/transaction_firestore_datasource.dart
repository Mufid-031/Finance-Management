import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/features/transaction/data/dto/transaction_dto.dart';

class TransactionFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Future<List<TransactionDTO>> getAll(String userId) async {
    final snapshot = await _ref(userId).get();

    return snapshot.docs
        .map((doc) => TransactionDTO.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> create(String userId, TransactionDTO dto) async {
    await _ref(userId).add(dto.toMap());
  }

  Future<void> update(String userId, String id, TransactionDTO dto) async {
    await _ref(userId).doc(id).update(dto.toMap());
  }

  Future<void> delete(String userId, String id) async {
    await _ref(userId).doc(id).delete();
  }
}
