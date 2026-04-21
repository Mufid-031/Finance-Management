import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final List<Transaction> transactions;
  final dynamic lastCursor;

  TransactionState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.transactions = const [],
    this.lastCursor,
  });

  TransactionState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    List<Transaction>? transactions,
    dynamic lastCursor,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      transactions: transactions ?? this.transactions,
      lastCursor: lastCursor ?? this.lastCursor,
    );
  }
}
