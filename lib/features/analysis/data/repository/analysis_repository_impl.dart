import 'package:finance_management/features/analysis/data/datasource/analysis_firestore_datasorce.dart';
import 'package:finance_management/features/transaction/data/dto/transaction_dto.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'analysis_repository.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisFirestoreDatasource _datasource;

  AnalysisRepositoryImpl(this._datasource);

  @override
  Stream<List<Transaction>> getTransactionsByRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return _datasource
        .getTransactionsByRange(userId: userId, start: start, end: end)
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => TransactionDTO.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ).toDomain(),
              )
              .toList();
        });
  }
}
