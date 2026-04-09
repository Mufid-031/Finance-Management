class BudgetState {
  final bool isLoading;
  final String? errorMessage;
  BudgetState({this.isLoading = false, this.errorMessage});

  BudgetState copyWith({bool? isLoading, String? errorMessage}) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
