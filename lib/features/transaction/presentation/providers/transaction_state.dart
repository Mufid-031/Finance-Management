class TransactionState {
  final bool isLoading;
  final String? errorMessage;

  TransactionState({this.isLoading = false, this.errorMessage});

  TransactionState copyWith({bool? isLoading, String? errorMessage}) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
