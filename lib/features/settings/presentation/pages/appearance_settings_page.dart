import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Appearance")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Application Theme",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: AppColors.widgetColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildThemeTile(ref, "Dark Mode", Icons.dark_mode, ThemeMode.dark, currentTheme),
                const Divider(height: 1, indent: 60, color: Colors.white10),
                _buildThemeTile(ref, "Light Mode", Icons.light_mode, ThemeMode.light, currentTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(WidgetRef ref, String title, IconData icon, ThemeMode mode, ThemeMode current) {
    final isSelected = mode == current;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.main : AppColors.grey),
      title: Text(title),
      trailing: isSelected 
          ? const Icon(Icons.check_circle, color: AppColors.main) 
          : const Icon(Icons.circle_outlined, color: AppColors.grey),
      onTap: () {
        ref.read(themeModeProvider.notifier).state = mode;
      },
    );
  }
}
