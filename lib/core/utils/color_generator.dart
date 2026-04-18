import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class ColorGenerator {
  // BOSS, ini palette warna tetap kita
  static final List<Color> _palette = [
    AppColors.main,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
    Colors.indigoAccent,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
  ];

  /// Menghasilkan warna konsisten berdasarkan string ID
  static Color fromId(String id) {
    if (id.isEmpty) return AppColors.main;

    // Gunakan abs() agar tidak menghasilkan angka negatif dari hash
    final index = id.hashCode.abs() % _palette.length;
    return _palette[index];
  }

  /// Menghasilkan warna transparan/background berdasarkan string ID
  static Color fromIdLowOpacity(String id, {double opacity = 0.1}) {
    return fromId(id).withValues(alpha: opacity);
  }
}
