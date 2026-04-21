import 'package:finance_management/features/ai_assistant/data/repository/ai_assistant_repository_impl.dart';
import 'package:finance_management/features/ai_assistant/domain/ai_transaction_result.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:flutter/material.dart';

class AIAssistantService {
  final AIAssistantRepository _repository;

  AIAssistantService(this._repository);

  /// Memproses suara/teks menjadi objek transaksi (Fitur Input)
  Future<AITransactionResult> processSpeechToTransaction({
    required String text,
    required List<Category>? categories,
    required List<Wallet>? wallets,
  }) {
    final contextPrompt = """
    Categories: ${categories?.map((c) => "${c.id}:${c.name}").join(", ")}
    Wallets: ${wallets?.map((w) => "${w.id}:${w.name}").join(", ")}
    """;

    return _repository.parseTransaction(text, contextPrompt);
  }

  /// Menganalisa riwayat transaksi untuk memberikan saran (Fitur Insight)
  Future<String> analyzeFinances({
    required List<Transaction> transactions,
    required List<Category> categories,
    required String mainCurrency,
  }) async {
    final summary = transactions.map((t) {
      final categoryName = categories
          .firstWhere((c) => c.id == t.categoryId,
              orElse: () => Category(
                  id: '',
                  name: 'Other',
                  icon: Icons.help,
                  type: CategoryType.expense))
          .name;
      return "- ${t.title}: ${t.amount} ${t.type.name} (Category: $categoryName)";
    }).join("\n");

    final prompt = """
    You are a professional financial advisor BOSS AI. 
    Analyze the following transactions for this month:
    $summary

    Provide a concise analysis (max 3 sentences) in Indonesian. 
    Give one specific advice to save money or improve financial health. 
    Address the user as 'BOSS'.
    Use the currency $mainCurrency in your analysis.
    """;

    return _repository.getAIAdvice(prompt);
  }

  /// Fitur Chatbot: Tanya-tanya seputar keuangan
  Future<String> chatWithAI({
    required String userMessage,
    required List<Wallet> wallets,
    required List<Category> categories,
    required List<Transaction> transactions,
    required double totalBalance,
    required String mainCurrency,
  }) async {
    final walletInfo = wallets
        .map((w) => "- ${w.name}: ${w.balance} ${w.currency}")
        .join("\n");

    final transactionSummary = transactions.take(10).map((t) {
      final categoryName = categories
          .firstWhere((c) => c.id == t.categoryId,
              orElse: () => Category(
                  id: '',
                  name: 'Other',
                  icon: Icons.help,
                  type: CategoryType.expense))
          .name;
      return "- ${t.title}: ${t.amount} ${t.type.name} ($categoryName)";
    }).join("\n");

    final prompt = """
    You are BOSS AI, a helpful financial personal assistant.
    Current Financial Context:
    - Total Balance: $totalBalance $mainCurrency
    - Wallets:
    $walletInfo
    
    Recent Transactions:
    $transactionSummary

    User asked: "$userMessage"
    
    Instructions:
    1. Answer in Indonesian.
    2. Be concise but professional.
    3. Refer to the user as 'BOSS'.
    4. If asked about balance, wallets, or transactions, use the provided context.
    5. If asked about something unrelated to finance, politely bring the conversation back to their money management.
    """;

    return _repository.getAIAdvice(prompt);
  }
}
