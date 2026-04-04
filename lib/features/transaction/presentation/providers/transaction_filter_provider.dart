import 'package:flutter_riverpod/legacy.dart';

enum TransactionFilter { all, spending, income }

final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.all,
);
