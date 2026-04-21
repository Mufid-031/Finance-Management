import 'package:finance_management/features/ai_assistant/application/ai_assistant_service.dart';
import 'package:finance_management/features/ai_assistant/presentation/providers/ai_assistant_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final aiInsightProvider = StateNotifierProvider<AIInsightNotifier, AsyncValue<String>>((ref) {
  final service = ref.watch(aiAssistantServiceProvider);
  return AIInsightNotifier(service, ref);
});

class AIInsightNotifier extends StateNotifier<AsyncValue<String>> {
  final AIAssistantService _service;
  final Ref _ref;

  AIInsightNotifier(this._service, this._ref) : super(const AsyncValue.data("Klik untuk analisa BOSS!"));

  Future<void> generateInsight() async {
    state = const AsyncValue.loading();
    try {
      // PERBAIKAN: Menggunakan transactionsStreamProvider
      final transactions = _ref.read(transactionsStreamProvider).value ?? [];
      final categories = _ref.read(categoriesStreamProvider).value ?? [];
      
      if (transactions.isEmpty) {
        state = const AsyncValue.data("Belum ada transaksi bulan ini, BOSS.");
        return;
      }

      final advice = await _service.analyzeFinances(
        transactions: transactions,
        categories: categories,
        mainCurrency: "IDR", // Bisa diambil dari settings nanti
      );

      state = AsyncValue.data(advice);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
