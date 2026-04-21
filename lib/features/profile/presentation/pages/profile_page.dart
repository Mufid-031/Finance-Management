import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/profile/presentation/widgets/logout_button.dart';
import 'package:finance_management/features/profile/presentation/widgets/profile_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                ProfileItemCard(
                  icon: Icons.person,
                  title: "Profile",
                  subtitle: "Login, account info",
                  color: AppColors.main,
                  onTap: () => context.pushNamed('profile-detail'),
                ),
                ProfileItemCard(
                  icon: Icons.dashboard,
                  title: "Appearance",
                  subtitle: "Dark mode, theme",
                  color: AppColors.purple,
                  onTap: () => context.pushNamed('appearance-settings'),
                ),
                ProfileItemCard(
                  icon: Icons.menu,
                  title: "General",
                  subtitle: "Currency, locale",
                  color: AppColors.green,
                  onTap: () => context.pushNamed('general-settings'),
                ),
                ProfileItemCard(
                  icon: Icons.settings,
                  title: "Settings",
                  subtitle: "Account & alerts",
                  color: AppColors.blue,
                  onTap: () {},
                ),
                ProfileItemCard(
                  icon: Icons.stacked_line_chart_sharp,
                  title: "Data",
                  subtitle: "Export & import",
                  color: AppColors.orange,
                  onTap: () {},
                ),
                ProfileItemCard(
                  icon: Icons.privacy_tip,
                  title: "Privacy",
                  subtitle: "Password & privacy",
                  color: AppColors.red,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),
            LogoutButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
