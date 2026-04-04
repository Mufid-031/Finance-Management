import 'package:flutter/material.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _nameController = TextEditingController();
  // Gunakan enum sebagai default value
  CategoryType selectedType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      selectedType = widget.category!.type; // Tipe data sekarang cocok (enum)
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Category Name"),
          ),
          const SizedBox(height: 16),
          // Dropdown menggunakan enum
          DropdownButton<CategoryType>(
            value: selectedType,
            isExpanded: true,
            items: CategoryType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type.name.toUpperCase(),
                ), // .name mengambil string dari enum
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => selectedType = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // Validasi sederhana
            if (_nameController.text.isEmpty) return;

            Navigator.pop(
              context,
              Category(
                id: widget.category?.id ?? '',
                name: _nameController.text,
                type: selectedType, // Kirim enum kembali
                icon: Icons.category,
              ),
            );
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
