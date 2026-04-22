import 'package:finance_management/features/notification/data/repository/notification_repository_impl.dart';
import 'package:finance_management/features/notification/domain/notification_model.dart';

class NotificationApplicationService {
  final NotificationRepository _repository;

  NotificationApplicationService(this._repository);

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _repository.watchNotifications(userId);
  }

  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    final notification = NotificationModel(
      id: '',
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    await _repository.addNotification(userId, notification);
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _repository.markAsRead(userId, notificationId);
  }

  Future<void> clearAll(String userId) async {
    await _repository.clearAll(userId);
  }
}
