import 'package:finance_management/features/category/data/datasource/category_firestore_datasource.dart';
import 'package:finance_management/features/category/data/dto/category_dto.dart';
import 'package:finance_management/features/category/data/repository/category_repository.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryFirestoreDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Future<List<Category>> getAll(String userId) async {
    final dtos = await datasource.getAll(userId);
    return dtos.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> addCategory(String userId, Category category) async {
    final dto = CategoryDTO.fromDomain(category);
    await datasource.create(userId, dto);
  }

  @override
  Future<void> updateCategory(String userId, Category category) async {
    final dto = CategoryDTO.fromDomain(category);
    await datasource.update(userId, category.id, dto);
  }

  @override
  Future<void> deleteCategory(String userId, String id) async {
    await datasource.delete(userId, id);
  }
}
