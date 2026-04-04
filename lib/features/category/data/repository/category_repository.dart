import 'package:finance_management/features/category/domain/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories(String userId);
  Future<void> addCategory(String userId, Category category);
  Future<void> updateCategory(String userId, Category category);
  Future<void> deleteCategory(String userId, String categoryId);
}
