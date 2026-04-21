import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:finance_management/features/ai_assistant/data/datasource/ai_assistant_remote_datasource.dart';
import 'package:finance_management/features/ai_assistant/domain/ai_transaction_result.dart';

abstract class AIAssistantRepository {
  Future<AITransactionResult> parseTransaction(
    String text,
    String contextPrompt,
  );
  Future<String> getAIAdvice(String prompt);
}

class AIAssistantRepositoryImpl implements AIAssistantRepository {
  final AIAssistantRemoteDatasource _datasource;

  AIAssistantRepositoryImpl(this._datasource);

  @override
  Future<String> getAIAdvice(String prompt) async {
    final response = await _datasource.getCompletion(prompt);
    final String content = response['choices'][0]['message']['content'];
    return content;
  }

  @override
  Future<AITransactionResult> parseTransaction(
    String text,
    String contextPrompt,
  ) async {
    final prompt =
        """
    Extract finance transaction from this: "$text".
    $contextPrompt
    
    RULES:
    1. If the sentence implies moving money between wallets (e.g., "tarik tunai", "pindah", "transfer"), use type: "transfer".
    2. For transfer, identify "walletId" (Source) and "toWalletId" (Destination).
    3. Return ONLY JSON.
    
    JSON Format:
    {"title": "string", "amount": double, "type": "income/expense/transfer", "categoryId": "id", "walletId": "id", "toWalletId": "id or null"}
    """;

    final response = await _datasource.getCompletion(prompt);
    final String content = response['choices'][0]['message']['content'];

    try {
      final int startIndex = content.indexOf('{');
      final int endIndex = content.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1)
        throw Exception("AI did not return a valid JSON.");

      final String jsonStr = content.substring(startIndex, endIndex + 1);
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return AITransactionResult.fromJson(data);
    } catch (e) {
      debugPrint("DEBUG: AI Parser Error: $e");
      throw Exception("AI failed to extract transaction data.");
    }
  }
}
