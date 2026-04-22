import 'package:finance_management/features/notification/data/datasource/notification_firestore_datasource.dart';
import 'package:finance_management/features/notification/domain/notification_model.dart';

class NotificationRepository {
  final NotificationFirestoreDatasource _datasource;

  NotificationRepository(this._datasource);

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _datasource.watchNotifications(userId).map((list) =>
        list.map((m) => NotificationModel.fromMap(m['id'], m)).toList());
  }

  Future<void> addNotification(String userId, NotificationModel notification) async {
    await _datasource.addNotification(userId, notification.toMap());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _datasource.markAsRead(userId, notificationId);
  }

  Future<void> clearAll(String userId) async {
    await _datasource.clearAll(userId);
  }
}
