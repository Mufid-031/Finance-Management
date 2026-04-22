import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_management/core/shared/widgets/confirm_dialog.dart';
import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
import 'package:finance_management/core/utils/error_utils.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (mounted) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categoryState = ref.watch(categoryNotifierProvider);

    ref.listen(categoryNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ErrorUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Categories"), elevation: 0),
      body: Column(
        children: [
          CustomFilterTabs(
            labels: const ["EXPENSE", "INCOME"],
            currentIndex: _currentTabIndex,
            onTabChanged: (index) {
              _tabController.animateTo(index);
              setState(() => _currentTabIndex = index);
            },
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          Expanded(
            child: Stack(
              children: [
                categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text("Error: $err")),
                  data: (categories) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCategoryList(categories, CategoryType.expense),
                        _buildCategoryList(categories, CategoryType.income),
                      ],
                    );
                  },
                ),
                if (categoryState.isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ).animate().scale(delay: 400.ms, curve: Curves.easeInBack),
    );
  }

  Widget _buildCategoryList(List<Category> categories, CategoryType type) {
    final filtered = categories.where((c) => c.type == type).toList();

    if (filtered.isEmpty) {
      return Center(
        child:
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 60,
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "No categories found",
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final category = filtered[index];
        final iconColor = category.type == CategoryType.income
            ? AppColors.main
            : AppColors.red;
        final bgColor = iconColor.withValues(alpha: 0.1);

        return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: Key(category.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      title: "Delete Category",
                      message:
                          "Are you sure you want to delete '${category.name}'?",
                      confirmLabel: "Delete",
                      onConfirm: () {},
                    ),
                  ).then((value) => value ?? false);
                },
                onDismissed: (_) {
                  ref
                      .read(categoryNotifierProvider.notifier)
                      .deleteCategory(category.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.widgetColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    onTap: () =>
                        _showAddCategoryDialog(context, category: category),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(category.icon, color: iconColor, size: 24),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 50).ms)
            .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, {Category? category}) {
    final nameController = TextEditingController(text: category?.name);

    CategoryType selectedType =
        category?.type ??
        (_tabController.index == 0
            ? CategoryType.expense
            : CategoryType.income);

    // Ikon default berbeda berdasarkan tipe jika kategori baru
    IconData selectedIcon =
        category?.icon ??
        (selectedType == CategoryType.expense
            ? Icons.fastfood
            : Icons.payments);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final List<IconData> expenseIcons = [
            Icons.fastfood,
            Icons.shopping_cart,
            Icons.directions_car,
            Icons.house,
            Icons.movie,
            Icons.medical_services,
            Icons.school,
            Icons.fitness_center,
            Icons.electrical_services,
            Icons.local_cafe,
            Icons.shopping_bag,
            Icons.flight,
          ];

          final List<IconData> incomeIcons = [
            Icons.work,
            Icons.payments,
            Icons.account_balance_wallet,
            Icons.trending_up,
            Icons.savings,
            Icons.redeem,
            Icons.monetization_on,
            Icons.add_business,
            Icons.volunteer_activism,
            Icons.sell,
            Icons.interests,
            Icons.auto_graph,
          ];

          final List<IconData> currentPresets =
              selectedType == CategoryType.expense ? expenseIcons : incomeIcons;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              left: 24,
              right: 24,
              top: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  category == null ? "New Category" : "Edit Category",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                // TYPE SELECTOR
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.widgetColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _TypeButton(
                        label: "Expense",
                        isSelected: selectedType == CategoryType.expense,
                        color: AppColors.red,
                        onTap: () => setModalState(() {
                          selectedType = CategoryType.expense;
                          selectedIcon = Icons.fastfood;
                        }),
                      ),
                      _TypeButton(
                        label: "Income",
                        isSelected: selectedType == CategoryType.income,
                        color: AppColors.main,
                        onTap: () => setModalState(() {
                          selectedType = CategoryType.income;
                          selectedIcon = Icons.payments;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // NAME INPUT
                TextField(
                  controller: nameController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    labelStyle: const TextStyle(color: AppColors.grey),
                    hintText: "e.g. Food, Salary, etc.",
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.main,
                    ),
                    filled: true,
                    fillColor: AppColors.widgetColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  "Visual Icon",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 15),

                // ICON GRID
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.widgetColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    itemCount: currentPresets.length,
                    itemBuilder: (context, index) {
                      final icon = currentPresets[index];
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.main
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: isSelected ? Colors.black : Colors.white38,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (nameController.text.isNotEmpty) {
                        await ref
                            .read(categoryNotifierProvider.notifier)
                            .saveCategory(
                              id: category?.id,
                              name: nameController.text,
                              icon: selectedIcon,
                              type: selectedType,
                            );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(
                      category == null ? "Create Category" : "Update Category",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
