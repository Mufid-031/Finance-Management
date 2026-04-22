import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/analysis/presentation/providers/analysis_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/profile/presentation/widgets/logout_button.dart';
import 'package:finance_management/features/profile/presentation/widgets/profile_item_card.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
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
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 0.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
                ProfileItemCard(
                  icon: Icons.dashboard,
                  title: "Appearance",
                  subtitle: "Dark mode, theme",
                  color: AppColors.purple,
                  onTap: () => context.pushNamed('appearance-settings'),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
                ProfileItemCard(
                  icon: Icons.menu,
                  title: "General",
                  subtitle: "Currency, locale",
                  color: AppColors.green,
                  onTap: () => context.pushNamed('general-settings'),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
                ProfileItemCard(
                  icon: Icons.settings,
                  title: "Settings",
                  subtitle: "About app & info",
                  color: AppColors.blue,
                  onTap: () => context.pushNamed('about-app'),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
            const SizedBox(height: 30),
            LogoutButton()
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) async {
    final reportService = ref.read(reportServiceProvider);
    final transactions = ref.read(transactionsStreamProvider).value ?? [];
    final wallets = ref.read(walletsStreamProvider).value ?? [];
    final categories = ref.read(categoriesStreamProvider).value ?? [];

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("BOSS, tidak ada data transaksi untuk diekspor."),
        ),
      );
      return;
    }

    try {
      await reportService.exportTransactionsToCsv(
        transactions: transactions,
        wallets: wallets,
        categories: categories,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal ekspor: $e")));
    }
  }
}
