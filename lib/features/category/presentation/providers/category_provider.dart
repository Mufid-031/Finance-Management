import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/category/application/category_service.dart';
import 'package:finance_management/features/category/data/datasource/category_firestore_datasource.dart';
import 'package:finance_management/features/category/data/repository/category_repository.dart';
import 'package:finance_management/features/category/data/repository/category_repository_impl.dart';
import 'package:finance_management/features/category/presentation/providers/category_notifier.dart';
import 'package:finance_management/features/category/presentation/providers/category_state.dart';

final categoryDatasourceProvider = Provider((ref) => CategoryDatasource());

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryDatasourceProvider));
});

final categoryServiceProvider = Provider((ref) {
  return CategoryService(ref.watch(categoryRepositoryProvider));
});

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
      final service = ref.watch(categoryServiceProvider);
      return CategoryNotifier(service, ref);
    });

// Provider untuk Data Stream (Tampilan Real-time)
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  final user = authStateAsync.value;

  if (user == null) return Stream.value([]);

  final service = ref.watch(categoryServiceProvider);
  return service.getCategories(user.uid);
});
