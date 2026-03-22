import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/features/category/domain/category.dart';

class CategoryDTO {
  final String id;
  final String name;
  final String type;
  final String icon;

  CategoryDTO({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  // FROM FIRESTORE
  factory CategoryDTO.fromMap(String id, Map<String, dynamic> json) {
    return CategoryDTO(
      id: id,
      name: json['name'] ?? '',
      type: json['type'] ?? 'expense',
      icon: json['icon'] ?? '',
    );
  }

  // TO DOMAIN
  Category toDomain() {
    return Category(id: id, name: name, type: type, icon: icon);
  }

  // FROM DOMAIN
  factory CategoryDTO.fromDomain(Category category) {
    return CategoryDTO(
      id: category.id,
      name: category.name,
      type: category.type,
      icon: category.icon,
    );
  }

  // TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'craetedAt': FieldValue.serverTimestamp(),
    };
  }
}
