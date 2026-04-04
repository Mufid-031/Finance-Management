class CategoryState {
  final bool isLoading;
  final String? errorMessage;

  CategoryState({this.isLoading = false, this.errorMessage});

  CategoryState copyWith({bool? isLoading, String? errorMessage}) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
