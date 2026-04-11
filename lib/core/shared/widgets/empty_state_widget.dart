import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.icon,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: AppColors.grey.withOpacity(0.5)),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: AppColors.grey)),
            if (onActionPressed != null)
              TextButton(
                onPressed: onActionPressed,
                child: Text(actionLabel ?? "Add New"),
              ),
          ],
        ),
      ),
    );
  }
}
