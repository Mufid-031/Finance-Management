import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/category/application/category_service.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_state.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService service;
  final Ref ref;

  CategoryNotifier(this.service, this.ref) : super(CategoryState());

  String get userId => ref.read(authNotifierProvider).user!.id;

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true);

    final data = await service.getCategories(userId);

    state = state.copyWith(categories: data, isLoading: false);
  }

  Future<void> addCategory(Category category) async {
    await service.addCategory(userId, category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await service.updateCategory(userId, category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await service.deleteCategory(userId, id);
    await loadCategories();
  }
}
