import 'package:finance_management/features/category/application/category_service.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService _service;
  final Ref _ref;

  CategoryNotifier(this._service, this._ref) : super(CategoryState());

  Future<void> saveCategory({
    String? id,
    required String name,
    required IconData icon,
    required CategoryType type,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final category = Category(
        id: id ?? '',
        name: name,
        icon: icon,
        type: type,
      );

      if (id == null) {
        await _service.addCategory(userId, category);
      } else {
        await _service.updateCategory(userId, category);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await _service.deleteCategory(userId, categoryId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
