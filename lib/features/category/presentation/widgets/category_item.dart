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

  // Helper untuk menentukan warna berdasarkan enum
  Color getTypeColor() {
    return category.type == CategoryType.expense ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: getTypeColor().withOpacity(0.1),
          child: Icon(
            // Anda bisa buat helper getIconData(category.icon) nanti
            Icons.category,
            color: getTypeColor(),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          category.type.name
              .toUpperCase(), // Menampilkan 'INCOME' atau 'EXPENSE'
          style: TextStyle(color: getTypeColor(), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.type == CategoryType.expense
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: getTypeColor(),
              size: 18,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
