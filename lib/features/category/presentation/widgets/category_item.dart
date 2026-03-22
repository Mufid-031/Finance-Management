import 'package:flutter/material.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryItem({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
  });

  Color getTypeColor() {
    return category.type == 'Expense' ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: getTypeColor().withOpacity(0.2),
          child: Text(category.icon, style: TextStyle(fontSize: 20)),
        ),
        title: Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(category.type),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.type == 'Expense'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: getTypeColor(),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
