class WalletState {
  final bool isLoading;
  final String? errorMessage;

  WalletState({this.isLoading = false, this.errorMessage});

  WalletState copyWith({bool? isLoading, String? errorMessage}) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Kita biarkan null jika tidak ada error
    );
  }
}
