class AIAssistantState {
  final bool isListening;
  final String speechText;
  final bool isProcessing;
  final String? resultMessage;

  AIAssistantState({
    this.isListening = false,
    this.speechText = "Press the mic to start speaking",
    this.isProcessing = false,
    this.resultMessage,
  });

  AIAssistantState copyWith({
    bool? isListening,
    String? speechText,
    bool? isProcessing,
    String? resultMessage,
  }) {
    return AIAssistantState(
      isListening: isListening ?? this.isListening,
      speechText: speechText ?? this.speechText,
      isProcessing: isProcessing ?? this.isProcessing,
      resultMessage: resultMessage ?? this.resultMessage,
    );
  }
}
