import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = "Delete",
    this.confirmColor = AppColors.red,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: AppColors.grey)),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = "Delete",
    Color confirmColor = AppColors.red,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }
}
