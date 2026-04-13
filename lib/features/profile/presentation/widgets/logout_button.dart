import 'package:finance_management/core/shared/widgets/confirm_dialog.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showLogoutConfirmation(context, ref),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.red),
            SizedBox(width: 12),
            Text(
              "Logout Account",
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    ConfirmDialog.show(
      context,
      title: "Logout",
      message: "Are you sure you want to sign out?",
      confirmLabel: "Logout",
      onConfirm: () => ref.read(authNotifierProvider.notifier).logout(),
    );
  }
}
