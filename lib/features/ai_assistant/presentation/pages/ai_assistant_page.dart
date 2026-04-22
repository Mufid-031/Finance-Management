import 'package:finance_management/features/ai_assistant/presentation/providers/ai_chat_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AIAssistantPage extends ConsumerStatefulWidget {
  const AIAssistantPage({super.key});

  @override
  ConsumerState<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends ConsumerState<AIAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    // BOSS, kita deteksi apakah keyboard sedang muncul atau tidak
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Vantage AI Chat"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- 1. CHAT AREA ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.main,
              ),
            ),

          // --- 2. INPUT FIELD CERDAS ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            // Jika keyboard buka: margin bawah kecil (10)
            // Jika keyboard tutup: margin bawah besar (85) agar di atas FAB MainPage
            margin: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10,
              bottom: isKeyboardOpen ? 10 : 85,
            ),
            decoration: BoxDecoration(
              color: AppColors.widgetColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Ask Vantage AI anything...",
                          hintStyle: TextStyle(
                            color: AppColors.grey,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) {
                          ref.read(aiChatProvider.notifier).sendMessage(val);
                          _messageController.clear();
                          _scrollToBottom();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        chatState.isLoading
                            ? Icons.stop_rounded
                            : Icons.send_rounded,
                        color: AppColors.main,
                      ),
                      onPressed: () {
                        ref
                            .read(aiChatProvider.notifier)
                            .sendMessage(_messageController.text);
                        _messageController.clear();
                        _scrollToBottom();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child:
          Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppColors.main
                      : AppColors.widgetColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isUser ? 20 : 0),
                    bottomRight: Radius.circular(message.isUser ? 0 : 20),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.black : Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideX(begin: message.isUser ? 0.05 : -0.05),
    );
  }
}
