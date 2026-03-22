import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/category/application/category_service.dart';
import 'package:finance_management/features/category/data/datasource/category_firestore_datasource.dart';
import 'package:finance_management/features/category/data/repository/category_repository.dart';
import 'package:finance_management/features/category/data/repository/category_repository_impl.dart';
import 'package:finance_management/features/category/presentation/providers/category_notifier.dart';
import 'package:finance_management/features/category/presentation/providers/category_state.dart';

final categoryDataSourceProvider = Provider<CategoryFirestoreDatasource>((ref) {
  return CategoryFirestoreDatasource();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.read(categoryDataSourceProvider));
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(categoryRepositoryProvider));
});

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
      return CategoryNotifier(ref.read(categoryServiceProvider), ref);
    });
