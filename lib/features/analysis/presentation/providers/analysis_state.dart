import 'package:finance_management/features/analysis/domain/category_report.dart';
import 'package:finance_management/features/analysis/domain/time_series_data.dart';

enum AnalysisTimeFilter { daily, weekly, monthly, yearly }

class AnalysisState {
  final bool isLoading;
  final List<CategoryReport> categoryReports;
  final List<TimeSeriesData> timeSeriesData;
  final AnalysisTimeFilter selectedFilter;
  final String? errorMessage;

  AnalysisState({
    this.isLoading = false,
    this.categoryReports = const [],
    this.timeSeriesData = const [],
    this.selectedFilter = AnalysisTimeFilter.weekly,
    this.errorMessage,
  });

  AnalysisState copyWith({
    bool? isLoading,
    List<CategoryReport>? categoryReports,
    List<TimeSeriesData>? timeSeriesData,
    AnalysisTimeFilter? selectedFilter,
    String? errorMessage,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      categoryReports: categoryReports ?? this.categoryReports,
      timeSeriesData: timeSeriesData ?? this.timeSeriesData,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
