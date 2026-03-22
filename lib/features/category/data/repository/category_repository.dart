import 'package:finance_management/features/category/domain/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAll(String userId);
  Future<void> addCategory(String userId, Category category);
  Future<void> updateCategory(String userId, Category category);
  Future<void> deleteCategory(String userId, String id);
}
