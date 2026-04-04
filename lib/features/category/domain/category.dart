import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final IconData icon;
  final CategoryType type; // Tambahkan ini

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}
