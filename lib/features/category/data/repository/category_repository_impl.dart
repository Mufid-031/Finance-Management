import 'package:finance_management/features/category/data/datasource/category_firestore_datasource.dart';
import 'package:finance_management/features/category/data/dto/category_dto.dart';
import 'package:finance_management/features/category/data/repository/category_repository.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Stream<List<Category>> watchCategories(String userId) {
    return datasource
        .watchAll(userId)
        .map(
          (list) => list
              .map((map) => CategoryDTO.fromMap(map['id'], map).toDomain())
              .toList(),
        );
  }

  @override
  Future<void> addCategory(String userId, Category category) async {
    final dto = CategoryDTO(
      id: '',
      name: category.name,
      iconCode: category.icon.codePoint,
      type: category.type == CategoryType.income ? 'income' : 'expense',
    );
    await datasource.create(userId, dto.toMap());
  }

  @override
  Future<void> updateCategory(String userId, Category category) async {
    final dto = CategoryDTO(
      id: category.id,
      name: category.name,
      iconCode: category.icon.codePoint,
      type: category.type == CategoryType.income ? 'income' : 'expense',
    );
    await datasource.update(userId, category.id, dto.toMap());
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await datasource.delete(userId, categoryId);
  }
}
