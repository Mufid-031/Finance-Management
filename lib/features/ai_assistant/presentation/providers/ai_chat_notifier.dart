import 'package:finance_management/features/ai_assistant/application/ai_assistant_service.dart';
import 'package:finance_management/features/ai_assistant/presentation/providers/ai_assistant_provider.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  AIChatState({this.messages = const [], this.isLoading = false});

  AIChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final aiChatProvider =
    StateNotifierProvider.autoDispose<AIChatNotifier, AIChatState>((ref) {
      final service = ref.watch(aiAssistantServiceProvider);
      return AIChatNotifier(service, ref);
    });

class AIChatNotifier extends StateNotifier<AIChatState> {
  final AIAssistantService _service;
  final Ref _ref;

  AIChatNotifier(this._service, this._ref)
    : super(
        AIChatState(
          messages: [
            ChatMessage(
              text:
                  "Halo BOSS! Ada yang bisa saya bantu seputar keuangan Anda hari ini?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final wallets = _ref.read(walletsStreamProvider).value ?? [];
      final categories = _ref.read(categoriesStreamProvider).value ?? [];
      final transactions = _ref.read(transactionsStreamProvider).value ?? [];
      final budgets = _ref.read(computedBudgetsProvider);
      final totalBalance = _ref.read(totalBalanceProvider);

      final response = await _service.chatWithAI(
        userMessage: text,
        wallets: wallets,
        categories: categories,
        transactions: transactions,
        budgets: budgets,
        totalBalance: totalBalance,
        mainCurrency: "IDR",
      );

      final aiMsg = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        text: "Mohon maaf, sistem sedang mengalami gangguan teknis: $e",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
      );
    }
  }
}
