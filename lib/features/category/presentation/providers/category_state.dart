import 'package:finance_management/features/category/domain/category.dart';

class CategoryState {
  final bool isLoading;
  final String? errorMessage;
  final List<Category> categories;

  CategoryState({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
  });

  CategoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Category>? categories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
    );
  }
}
