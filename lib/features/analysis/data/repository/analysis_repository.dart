import 'package:finance_management/features/transaction/domain/transaction.dart';

abstract class AnalysisRepository {

  Stream<List<Transaction>> getTransactionsByRange(
    String userId,
    DateTime start,
    DateTime end,
  );
}
