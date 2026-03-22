import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/features/category/data/dto/category_dto.dart';

class CategoryFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  Future<List<CategoryDTO>> getAll(String userId) async {
    try {
      final snapshot = await _ref(
        userId,
      ).orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map((doc) => CategoryDTO.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<void> create(String userId, CategoryDTO dto) async {
    await _ref(userId).add(dto.toMap());
  }

  Future<void> update(String userId, String id, CategoryDTO dto) async {
    await _ref(userId).doc(id).update(dto.toMap());
  }

  Future<void> delete(String userId, String id) async {
    await _ref(userId).doc(id).delete();
  }
}
