import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/ai_assistant/presentation/providers/ai_insight_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIInsightCard extends ConsumerWidget {
  const AIInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(aiInsightProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.main.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.main.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.main),
              const SizedBox(width: 10),
              const Text(
                "AI Financial Insight",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (insightAsync is! AsyncLoading)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.main),
                  onPressed: () => ref.read(aiInsightProvider.notifier).generateInsight(),
                ),
            ],
          ),
          const SizedBox(height: 10),
          insightAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text("Error: $err", style: const TextStyle(color: Colors.red)),
            data: (advice) => Text(
              advice,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
