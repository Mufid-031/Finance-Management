import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIAssistantRemoteDatasource {
  static const String _baseUrl = "https://openrouter.ai/api/v1/chat/completions";
  
  // BOSS, API Key sekarang diambil dari --dart-define=OPENROUTER_API_KEY=xxx
  static const String _apiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
  static const String _model = "deepseek/deepseek-chat";

  Future<Map<String, dynamic>> getCompletion(String prompt) async {
    debugPrint("DEBUG: Sending request to OpenRouter...");
    debugPrint("DEBUG: Model: $_model");
    debugPrint("DEBUG: Prompt: $prompt");

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://boss-finance.app",
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {"role": "user", "content": prompt},
          ],
        }),
      );

      debugPrint("DEBUG: OpenRouter Response Status: ${response.statusCode}");
      debugPrint("DEBUG: OpenRouter Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("OpenRouter HTTP Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("DEBUG: Network/HTTP Error in getCompletion: $e");
      rethrow;
    }
  }
}
