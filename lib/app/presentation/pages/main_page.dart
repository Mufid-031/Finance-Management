import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/theme/theme_provider.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/dashboard/presentation/pages/home_page.dart';
import 'package:finance_management/features/profile/presentation/pages/profile_page.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
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

  // MODAL ADD TRANSACTION (Tetap seperti kode Anda sebelumnya)
  void _showAddTransactionModal(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    // Gunakan variabel lokal di dalam fungsi ini agar bisa diakses StatefulBuilder
    TransactionType selectedType = TransactionType.expense;
    String? selectedWalletId;
    String? selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          // Ambil data dari provider
          final walletsAsync = ref.watch(walletsStreamProvider);
          final categoriesAsync = ref.watch(categoriesStreamProvider);
          final txState = ref.watch(transactionNotifierProvider);

          return StatefulBuilder(
            builder: (context, setModalState) {
              // Kita filter kategori berdasarkan tipe yang dipilih (Expense/Income)
              final allCategories = categoriesAsync.value ?? [];
              final filteredCategories = allCategories
                  .where((c) => c.type.index == selectedType.index)
                  .toList();

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle Bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "New Transaction",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Tipe Selector (PENTING: Gunakan setModalState untuk update UI modal)
                      Row(
                        children: [
                          _typeButton(
                            setModalState,
                            "Expense",
                            TransactionType.expense,
                            selectedType,
                            (type) {
                              setModalState(() {
                                selectedType = type;
                                selectedCategoryId =
                                    null; // Reset kategori saat pindah tipe
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          _typeButton(
                            setModalState,
                            "Income",
                            TransactionType.income,
                            selectedType,
                            (type) {
                              setModalState(() {
                                selectedType = type;
                                selectedCategoryId =
                                    null; // Reset kategori saat pindah tipe
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Input Amount & Title
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.main,
                        ),
                        decoration: const InputDecoration(
                          hintText: "0.00",
                          prefixText: "\$ ",
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Notes (e.g. Lunch with friends)",
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(),

                      // 3. Pilihan Wallet
                      const Text(
                        "Source Wallet",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      walletsAsync.when(
                        data: (list) => SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: list
                                .map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(w.name),
                                      selected: selectedWalletId == w.id,
                                      onSelected: (selected) => setModalState(
                                        () => selectedWalletId = w.id,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text("Error loading wallets"),
                      ),

                      const SizedBox(height: 20),

                      // 4. Pilihan Category (INI YANG ANDA MAKSUD)
                      const Text(
                        "Category",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (filteredCategories.isEmpty)
                        const Text(
                          "No categories found. Please create one first.",
                          style: TextStyle(color: AppColors.red, fontSize: 12),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredCategories.map((c) {
                            final isSelected = selectedCategoryId == c.id;
                            return ChoiceChip(
                              avatar: Icon(
                                c.icon,
                                size: 16,
                                color: isSelected
                                    ? Colors.black
                                    : AppColors.main,
                              ),
                              label: Text(c.name),
                              selected: isSelected,
                              selectedColor: AppColors.main,
                              onSelected: (selected) => setModalState(
                                () => selectedCategoryId = c.id,
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 30),

                      // 5. Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.main,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: txState.isLoading
                              ? null
                              : () async {
                                  if (selectedWalletId == null ||
                                      selectedCategoryId == null ||
                                      amountController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please select wallet, category, and enter amount",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await ref
                                      .read(
                                        transactionNotifierProvider.notifier,
                                      )
                                      .addTransaction(
                                        title: nameController.text.isEmpty
                                            ? "Untitled"
                                            : nameController.text,
                                        amount:
                                            double.tryParse(
                                              amountController.text,
                                            ) ??
                                            0,
                                        walletId: selectedWalletId!,
                                        categoryId: selectedCategoryId!,
                                        type: selectedType,
                                      );

                                  if (context.mounted) Navigator.pop(context);
                                },
                          child: txState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  "Confirm Transaction",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  // Helper untuk Toggle Button Expense/Income
  Widget _typeButton(
    StateSetter setModalState,
    String label,
    TransactionType type,
    TransactionType current,
    Function(TransactionType) onTap,
  ) {
    final isSelected = type == current;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.main : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.main
                  : AppColors.grey.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
