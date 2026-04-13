import 'package:finance_management/core/shared/widgets/confirm_dialog.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: themeBackground,
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // MENGGUNAKAN GRIDVIEW BUILDER (LEBIH KONSISTEN)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1, // Mengatur rasio tinggi/lebar item
              children: [
                _buildProfileItem(
                  Icons.person,
                  "Profile",
                  "Login, authenticator",
                  AppColors.main,
                ),
                _buildProfileItem(
                  Icons.dashboard,
                  "Appearance",
                  "Widget, theme",
                  AppColors.purple,
                ),
                _buildProfileItem(
                  Icons.menu,
                  "General",
                  "Currency, clear data",
                  AppColors.green,
                ),
                _buildProfileItem(
                  Icons.settings,
                  "Settings",
                  "Account & alerts",
                  AppColors.blue,
                ),
                _buildProfileItem(
                  Icons.stacked_line_chart_sharp,
                  "Data",
                  "Export & import",
                  AppColors.orange,
                ),
                _buildProfileItem(
                  Icons.privacy_tip,
                  "Privacy",
                  "Password & privacy",
                  AppColors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // TOMBOL LOGOUT
            _buildLogoutButton(context, ref),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 34),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
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
      confirmLabel: "Logout", // Label kustom
      onConfirm: () => ref.read(authNotifierProvider.notifier).logout(),
    );
  }
}
