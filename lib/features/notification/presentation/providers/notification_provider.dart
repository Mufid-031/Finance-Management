import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/notification/application/notification_application_service.dart';
import 'package:finance_management/features/notification/data/datasource/notification_firestore_datasource.dart';
import 'package:finance_management/features/notification/data/repository/notification_repository_impl.dart';
import 'package:finance_management/features/notification/domain/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationDatasourceProvider = Provider((ref) => NotificationFirestoreDatasource());

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(notificationDatasourceProvider));
});

final notificationApplicationServiceProvider = Provider((ref) {
  return NotificationApplicationService(ref.watch(notificationRepositoryProvider));
});

final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  final user = authStateAsync.value;

  if (user == null) return Stream.value([]);

  final service = ref.watch(notificationApplicationServiceProvider);
  return service.getNotifications(user.uid);
});

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
