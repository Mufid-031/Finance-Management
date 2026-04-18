import 'dart:async';
import 'package:finance_management/features/analysis/application/analysis_service.dart';
import 'package:finance_management/features/analysis/data/repository/analysis_repository.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'analysis_state.dart';

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final AnalysisRepository _repository;
  final AnalysisService _service;
  final Ref _ref;
  StreamSubscription? _transactionSubscription;

  AnalysisNotifier(this._repository, this._service, this._ref)
    : super(AnalysisState()) {
    changeFilter(AnalysisTimeFilter.weekly);
  }

  void changeFilter(AnalysisTimeFilter filter) {
    state = state.copyWith(selectedFilter: filter, isLoading: true);
    _listenToTransactions(filter);
  }

  void _listenToTransactions(AnalysisTimeFilter filter) {
    _transactionSubscription?.cancel();

    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final now = DateTime.now();
    DateTime start;

    switch (filter) {
      case AnalysisTimeFilter.daily:
        start = DateTime(now.year, now.month, now.day);
        break;
      case AnalysisTimeFilter.weekly:
        start = now.subtract(const Duration(days: 7));
        break;
      case AnalysisTimeFilter.monthly:
        start = DateTime(now.year, now.month, 1);
        break;
      case AnalysisTimeFilter.yearly:
        start = DateTime(now.year, 1, 1);
        break;
    }

    _transactionSubscription = _repository
        .getTransactionsByRange(user.uid, start, now)
        .listen(
          (transactions) {
            final categories = _ref.read(categoriesStreamProvider).value ?? [];

            final reports = _service.calculateCategoryReports(
              transactions,
              categories,
            );
            final timeData = _service.calculateTimeSeriesData(
              transactions,
              start,
              now,
            );

            state = state.copyWith(
              isLoading: false,
              categoryReports: reports,
              timeSeriesData: timeData,
              errorMessage: null,
            );
          },
          onError: (e) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: e.toString(),
            );
          },
        );
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
