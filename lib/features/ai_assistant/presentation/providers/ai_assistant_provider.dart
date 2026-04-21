import 'package:finance_management/features/ai_assistant/application/ai_assistant_service.dart';
import 'package:finance_management/features/ai_assistant/data/datasource/ai_assistant_remote_datasource.dart';
import 'package:finance_management/features/ai_assistant/data/repository/ai_assistant_repository_impl.dart';
import 'package:finance_management/features/ai_assistant/presentation/providers/ai_assistant_notifier.dart';
import 'package:finance_management/features/ai_assistant/presentation/providers/ai_assistant_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final aiAssistantDatasourceProvider = Provider((ref) => AIAssistantRemoteDatasource());

final aiAssistantRepositoryProvider = Provider<AIAssistantRepository>((ref) {
  return AIAssistantRepositoryImpl(ref.watch(aiAssistantDatasourceProvider));
});

final aiAssistantServiceProvider = Provider((ref) {
  return AIAssistantService(ref.watch(aiAssistantRepositoryProvider));
});

final aiAssistantProvider =
    StateNotifierProvider.autoDispose<AIAssistantNotifier, AIAssistantState>((ref) {
      final service = ref.watch(aiAssistantServiceProvider);
      return AIAssistantNotifier(service, ref);
    });
