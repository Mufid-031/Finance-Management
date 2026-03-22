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
  String type = 'Expense';

  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      type = widget.category!.type;
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
            decoration: InputDecoration(labelText: "Category Name"),
          ),
          DropdownButton(
            value: type,
            items: [
              DropdownMenuItem(value: "Income", child: Text("Income")),
              DropdownMenuItem(value: "Expense", child: Text("Expense")),
            ],
            onChanged: (value) {
              setState(() {
                type = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              Category(
                id: widget.category?.id ?? DateTime.now().toString(),
                name: _nameController.text,
                type: type,
                icon: "📁",
              ),
            );
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
