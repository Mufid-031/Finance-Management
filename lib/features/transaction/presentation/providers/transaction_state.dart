import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionState {
  final List<Transaction> transactions;
  final bool isLoading;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
