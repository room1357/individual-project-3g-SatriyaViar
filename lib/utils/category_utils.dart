import 'package:flutter/material.dart';

class CategoryUtils {
  // Ambil ikon sesuai kategori
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'utilitas':
        return Icons.home;
      case 'hiburan':
        return Icons.movie;
      case 'pendidikan':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  // Opsional: warna sesuai kategori
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.green;
      case 'utilitas':
        return Colors.purple;
      case 'hiburan':
        return Colors.redAccent;
      case 'pendidikan':
        return Colors.blue;
      default:
        return Colors.primaries[
          category.hashCode % Colors.primaries.length
        ].shade700;
    }
  }
}
