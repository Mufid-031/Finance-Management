import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ErrorUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = AppColors.main,
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    // BOSS, kita pakai Overlay agar posisi selalu konsisten di atas layar
    // Tidak terpengaruh apakah sedang di modal atau halaman biasa
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Hapus otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showError(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: AppColors.red,
      icon: Icons.error_outline,
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: AppColors.main,
      icon: Icons.check_circle_outline,
      iconColor: Colors.black,
      textColor: Colors.black,
    );
  }
}
