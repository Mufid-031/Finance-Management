import 'package:finance_management/features/category/data/repository/category_repository.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryService {
  final CategoryRepository repository;
  CategoryService(this.repository);

  Stream<List<Category>> getCategories(String userId) =>
      repository.watchCategories(userId);
  Future<void> addCategory(String userId, Category cat) =>
      repository.addCategory(userId, cat);
  Future<void> updateCategory(String userId, Category cat) =>
      repository.updateCategory(userId, cat);
  Future<void> deleteCategory(String userId, String id) =>
      repository.deleteCategory(userId, id);
}
