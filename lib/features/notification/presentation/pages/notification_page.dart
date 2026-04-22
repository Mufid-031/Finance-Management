import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/date_formatter.dart';
import 'package:finance_management/features/notification/presentation/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final service = ref.watch(notificationApplicationServiceProvider);
    final userId = ref.watch(authStateChangesProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (userId != null)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.red),
              onPressed: () => _showClearConfirm(context, ref, userId, service),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: AppColors.grey.withValues(alpha: 0.2)),
                  const SizedBox(height: 15),
                  const Text("No notifications yet", style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: n.isRead ? AppColors.widgetColor.withValues(alpha: 0.5) : AppColors.widgetColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: n.isRead ? Colors.transparent : AppColors.main.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    if (!n.isRead && userId != null) {
                      service.markAsRead(userId, n.id);
                    }
                  },
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: n.isRead ? AppColors.grey.withValues(alpha: 0.1) : AppColors.main.withValues(alpha: 0.1),
                    child: Icon(
                      n.title.contains('Exceeded') ? Icons.warning_amber_rounded : Icons.notifications_active_outlined,
                      color: n.isRead ? AppColors.grey : AppColors.main,
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                      color: n.isRead ? AppColors.grey : Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        n.body,
                        style: TextStyle(color: n.isRead ? AppColors.grey : Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormatter.getNiceDateLabel(n.timestamp),
                        style: const TextStyle(fontSize: 11, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearConfirm(BuildContext context, WidgetRef ref, String userId, dynamic service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All"),
        content: const Text("Are you sure you want to delete all notifications?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              service.clearAll(userId);
              Navigator.pop(context);
            },
            child: const Text("Clear", style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
