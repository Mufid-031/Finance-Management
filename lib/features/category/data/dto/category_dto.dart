import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:flutter/material.dart';

class CategoryDTO {
  final String id;
  final String name;
  final String type;
  final int iconCode; // Ubah String menjadi int (codePoint)

  CategoryDTO({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
  });

  factory CategoryDTO.fromMap(String id, Map<String, dynamic> json) {
    return CategoryDTO(
      id: id,
      name: json['name'] ?? '',
      // Ambil codePoint dari Firestore, default ke icon category jika kosong
      iconCode: json['iconCode'] ?? 57585,
      type: json['type'] ?? 'expense',
    );
  }

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      // Rekonstruksi IconData menggunakan codePoint dan fontFamily
      icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
      type: type == 'income' ? CategoryType.income : CategoryType.expense,
    );
  }

  factory CategoryDTO.fromDomain(Category category) {
    return CategoryDTO(
      id: category.id,
      name: category.name,
      type: category.type.name, // 'income' atau 'expense'
      iconCode: category.icon.codePoint, // Ambil codePoint dari IconData
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'iconCode': iconCode, // Simpan sebagai integer
      'createdAt':
          FieldValue.serverTimestamp(), // Typo fixed: 'craetedAt' -> 'createdAt'
    };
  }
}
