import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';

class ReportState {
  final DateTime? lastExportDate;
  final int totalTransactions;
  final bool isExporting;

  ReportState({
    this.lastExportDate,
    this.totalTransactions = 0,
    this.isExporting = false,
  });

  ReportState copyWith({
    DateTime? lastExportDate,
    int? totalTransactions,
    bool? isExporting,
  }) {
    return ReportState(
      lastExportDate: lastExportDate ?? this.lastExportDate,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier(this._ref) : super(ReportState()) {
    _loadLastExportDate();
    _watchTransactions();
  }

  final Ref _ref;
  static const _prefKey = 'last_export_date';

  Future<void> _loadLastExportDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_prefKey);
    if (dateStr != null) {
      state = state.copyWith(lastExportDate: DateTime.parse(dateStr));
    }
  }

  void _watchTransactions() {
    _ref.listen(transactionsStreamProvider, (previous, next) {
      final transactions = next.value ?? [];
      state = state.copyWith(totalTransactions: transactions.length);
    }, fireImmediately: true);
  }

  Future<void> updateLastExportDate() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, now.toIso8601String());
    state = state.copyWith(lastExportDate: now);
  }

  void setExporting(bool value) {
    state = state.copyWith(isExporting: value);
  }
}

final reportNotifierProvider =
    StateNotifierProvider.autoDispose<ReportNotifier, ReportState>((ref) {
      return ReportNotifier(ref);
    });
