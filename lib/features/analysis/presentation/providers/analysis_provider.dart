import 'package:finance_management/features/analysis/application/analysis_service.dart';
import 'package:finance_management/features/analysis/data/datasource/analysis_firestore_datasorce.dart';
import 'package:finance_management/features/analysis/data/repository/analysis_repository.dart';
import 'package:finance_management/features/analysis/data/repository/analysis_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'analysis_notifier.dart';
import 'analysis_state.dart';

final analysisFirestoreDatasourceProvider = Provider((ref) {
  return AnalysisFirestoreDatasource();
});

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final datasource = ref.watch(analysisFirestoreDatasourceProvider);
  return AnalysisRepositoryImpl(datasource);
});

final analysisServiceProvider = Provider((ref) {
  return AnalysisService();
});

final analysisNotifierProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
      final repo = ref.watch(analysisRepositoryProvider);
      final service = ref.watch(analysisServiceProvider);
      return AnalysisNotifier(repo, service, ref);
    });
