import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/category/presentation/widgets/category_form_dialog.dart';
import 'package:finance_management/features/category/presentation/widgets/category_item.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryNotifierProvider);
    final notifier = ref.read(categoryNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Categories")),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: state.categories
                  .map(
                    (category) => CategoryItem(
                      category: category,
                      onTap: () async {
                        final updated = await showDialog<Category>(
                          context: context,
                          builder: (_) =>
                              CategoryFormDialog(category: category),
                        );

                        if (updated != null) {
                          await notifier.updateCategory(category);
                        }
                      },
                      onDelete: () async {
                        await notifier.deleteCategory(category.id);
                      },
                    ),
                  )
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final category = await showDialog<Category>(
            context: context,
            builder: (_) => CategoryFormDialog(),
          );

          if (category != null) {
            await notifier.addCategory(category);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
