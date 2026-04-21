import 'package:finance_management/features/ai_assistant/application/ai_assistant_service.dart';
import 'package:finance_management/features/ai_assistant/presentation/providers/ai_assistant_state.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIAssistantNotifier extends StateNotifier<AIAssistantState> {
  final AIAssistantService _service;
  final Ref _ref;
  final stt.SpeechToText _speech = stt.SpeechToText();

  AIAssistantNotifier(this._service, this._ref) : super(AIAssistantState());

  Future<void> toggleListening() async {
    if (state.isListening) {
      await _speech.stop();
      state = state.copyWith(isListening: false);
      await _processAI(state.speechText);
    } else {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize();
        if (available) {
          state = state.copyWith(isListening: true, speechText: "Listening...");
          _speech.listen(onResult: (result) {
            state = state.copyWith(speechText: result.recognizedWords);
          });
        }
      } else {
        state = state.copyWith(resultMessage: "Microphone permission denied.");
      }
    }
  }

  Future<void> _processAI(String text) async {
    if (text.isEmpty || text == "Listening..." || text == "Press the mic to start speaking") return;

    state = state.copyWith(isProcessing: true, resultMessage: "DeepSeek is analyzing...");

    try {
      final user = _ref.read(authStateChangesProvider).value;
      if (user == null) throw Exception("User not found.");

      // Ambil data terbaru secara async
      final categories = await _ref.read(categoryServiceProvider).getCategories(user.uid).first;
      final wallets = await _ref.read(walletServiceProvider).getWalletsStream(user.uid).first;
      final settings = await _ref.read(settingsServiceProvider).watchSettings(user.uid).first;

      if (categories.isEmpty || wallets.isEmpty) throw Exception("Setup data first.");

      final result = await _service.processSpeechToTransaction(
        text: text,
        categories: categories,
        wallets: wallets,
      ).timeout(const Duration(seconds: 20));

      // KONVERSI MATA UANG (Ke Base USD jika diperlukan, atau simpan apa adanya)
      // BOSS, karena kita sudah punya multi-currency wallet, kita bisa simpan sesuai wallet yang dipilih AI.
      // Namun kita tetap sesuaikan dengan exchange rate settings jika itu adalah mata uang utama.
      final double rate = settings.exchangeRate ?? 1.0;
      final double safeRate = rate == 0 ? 1.0 : rate;
      final double baseAmount = result.amount / safeRate;

      debugPrint("DEBUG: AI Extracted -> ${result.title}, RAW: ${result.amount}, Base: $baseAmount, Type: ${result.type}");

      await _ref.read(transactionNotifierProvider.notifier).addTransaction(
            title: result.title,
            amount: baseAmount,
            walletId: result.walletId ?? wallets.first.id,
            toWalletId: result.toWalletId,
            categoryId: result.categoryId ?? (result.type == TransactionType.transfer ? "TRANSFER_CAT" : categories.first.id),
            type: result.type,
          );

      state = state.copyWith(
        isProcessing: false,
        resultMessage: "Recorded: ${result.title}!",
      );
    } catch (e) {
      debugPrint("DEBUG: AI Notifier Error: $e");
      state = state.copyWith(isProcessing: false, resultMessage: "Error: $e");
    }
  }
}
