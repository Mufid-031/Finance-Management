import 'package:finance_management/core/shared/widgets/confirm_dialog.dart';
import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.red,
          ),
        );
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
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, CategoryType type) {
    final filtered = categories.where((c) => c.type == type).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "No categories found",
          style: TextStyle(color: AppColors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final category = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.type == CategoryType.income
                  ? AppColors.income.withValues(alpha: 0.1)
                  : AppColors.expense.withValues(alpha: 0.1),
              child: Icon(
                category.icon,
                color: category.type == CategoryType.income
                    ? AppColors.income
                    : AppColors.expense,
              ),
            ),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.grey),
                  onPressed: () =>
                      _showAddCategoryDialog(context, category: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                  onPressed: () => _showDeleteConfirmation(context, category),
                ),
              ],
            ),
          ),
        );
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // --- LOGIKA ICON PRESETS BERDASARKAN TIPE ---
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
          ];

          // Pilih list yang sesuai
          final List<IconData> currentPresets =
              selectedType == CategoryType.expense ? expenseIcons : incomeIcons;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 24,
              right: 24,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),

                Text(
                  category == null ? "Create Category" : "Edit Category",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                CustomFilterTabs(
                  labels: const ["EXPENSE", "INCOME"],
                  currentIndex: selectedType == CategoryType.expense ? 0 : 1,
                  onTabChanged: (index) {
                    setModalState(() {
                      selectedType = index == 0
                          ? CategoryType.expense
                          : CategoryType.income;

                      selectedIcon = selectedType == CategoryType.expense
                          ? Icons.fastfood
                          : Icons.payments;
                    });
                  },
                ),
                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.widgetColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Category Name",
                      hintStyle: TextStyle(color: AppColors.grey),
                      border: InputBorder.none,
                      icon: Icon(Icons.edit_note, color: AppColors.main),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Visual Icon",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- GRID ICON YANG SUDAH TERFILTER ---
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.widgetColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: currentPresets.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.main
                              : Colors.transparent,
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.black : AppColors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),

                // Button Save tetap sama...
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      category == null ? "Save Category" : "Update Category",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    ConfirmDialog.show(
      context,
      title: "Delete Category",
      message: "Are you sure you want to delete '${category.name}'?",
      onConfirm: () => ref
          .read(categoryNotifierProvider.notifier)
          .deleteCategory(category.id),
    );
  }
}
