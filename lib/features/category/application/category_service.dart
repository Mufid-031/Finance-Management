import 'package:finance_management/features/category/data/repository/category_repository.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryService {
  final CategoryRepository repository;

  CategoryService(this.repository);

  Future<List<Category>> getCategories(String userId) {
    return repository.getAll(userId);
  }

  Future<void> addCategory(String userId, Category category) async {
    if (category.name.isEmpty) {
      throw Exception('Category name cannot be empty');
    }

    await repository.addCategory(userId, category);
  }

  Future<void> updateCategory(String userId, Category category) async {
    if (category.name.isEmpty) {
      throw Exception('Category name cannot be empty');
    }

    await repository.updateCategory(userId, category);
  }

  Future<void> deleteCategory(String userId, String id) async {
    await repository.deleteCategory(userId, id);
  }
}
