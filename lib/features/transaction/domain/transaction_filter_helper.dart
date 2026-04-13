import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';

extension TransactionListFilter on List<Transaction> {
  List<Transaction> applyFilter({
    TransactionFilter? selectedFilter,
    String? searchQuery,
  }) {
    return where((tx) {
      bool matchesSearch = true;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        matchesSearch = tx.title.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
      }

      bool matchesTab = true;
      if (selectedFilter != null) {
        if (selectedFilter == TransactionFilter.income) {
          matchesTab = tx.type == TransactionType.income;
        } else if (selectedFilter == TransactionFilter.spending) {
          matchesTab = tx.type == TransactionType.expense;
        }
      }

      return matchesSearch && matchesTab;
    }).toList();
  }
}
