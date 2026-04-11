import 'package:finance_management/core/shared/widgets/add_transaction_modal.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/theme/theme_provider.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/dashboard/presentation/pages/home_page.dart';
import 'package:finance_management/features/profile/presentation/pages/profile_page.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int index = 0;
  TransactionType selectedType = TransactionType.income;

  final pages = [
    const HomePage(),
    const Center(child: Text("Analytics Page")), // Tab 2
    const Center(child: Text("AI Assistant")), // Tab 3
    const ProfilePage(), // Tab 4 (Profile/Settings)
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final iconColor = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // APP BAR DI PINDAH KE SINI
      appBar: _buildAppBar(context, user?.email),
      body: pages[index],

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        shape: const CircleBorder(),
        onPressed: () => _showAddTransactionModal(context),
        child: const Icon(
          Icons.add,
          color: AppColors.backgroundColor,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 65,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround, // Lebih rapi untuk 4 item
          children: [
            // HOME
            IconButton(
              onPressed: () => setState(() => index = 0),
              icon: Icon(
                index == 0 ? Icons.home_rounded : Icons.home_outlined,
                color: index == 0 ? AppColors.main : AppColors.grey,
              ),
            ),
            // ANALYTICS
            IconButton(
              onPressed: () => setState(() => index = 1),
              icon: Icon(
                index == 1 ? Icons.bar_chart_rounded : Icons.bar_chart_outlined,
                color: index == 1 ? AppColors.main : AppColors.grey,
              ),
            ),
            const SizedBox(width: 40), // Spasi untuk FloatingActionButton
            // AI
            IconButton(
              onPressed: () => setState(() => index = 2),
              icon: Icon(
                index == 2 ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                color: index == 2 ? AppColors.main : AppColors.grey,
              ),
            ),
            // PROFILE / GRID
            IconButton(
              onPressed: () => setState(() => index = 3),
              icon: Icon(
                index == 3 ? Icons.grid_view_rounded : Icons.grid_view_outlined,
                color: index == 3 ? AppColors.main : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // APP BAR COMPONENT
  PreferredSizeWidget _buildAppBar(BuildContext context, String? email) {
    final displayEmail = email?.split("@")[0] ?? 'User';
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.only(left: 15),
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://ui-avatars.com/api/?name=User',
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello,", style: TextStyle(fontSize: 12, color: AppColors.grey)),
          Text(
            displayEmail,
            style: TextStyle(
              fontSize: 18,
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // TOMBOL TOGGLE THEME (Sangat disarankan tetap ada untuk kemudahan akses)
        IconButton(
          onPressed: () {
            ref
                .read(themeModeProvider.notifier)
                .update(
                  (state) => state == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                );
          },
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: iconColor,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none, color: iconColor),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const AddTransactionModal(),
    );
  }
}
