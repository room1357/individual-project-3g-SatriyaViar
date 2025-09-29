// category_manager.dart
import 'category.dart';

class CategoryManager {
  static List<Category> categories = [
    Category(
      id: '1',
      name: 'Makanan',
      description: 'Pengeluaran untuk kebutuhan makan & minum',
    ),
    Category(
      id: '2',
      name: 'Transportasi',
      description: 'Biaya perjalanan seperti bensin, ongkos bus, dll',
    ),
    Category(
      id: '3',
      name: 'Utilitas',
      description: 'Tagihan rutin seperti listrik, air, internet',
    ),
    Category(
      id: '4',
      name: 'Hiburan',
      description: 'Pengeluaran untuk hiburan & rekreasi',
    ),
    Category(
      id: '5',
      name: 'Pendidikan',
      description: 'Buku, kursus, dan kebutuhan belajar',
    ),
  ];

  // Cari kategori berdasarkan ID
  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Cari kategori berdasarkan nama
  static Category? getCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Menambah kategori baru
  static void addCategory(Category category) {
    categories.add(category);
  }

  // Menghapus kategori
  static void removeCategory(String id) {
    categories.removeWhere((category) => category.id == id);
  }

  // Mengedit Kategori
  static void editCategory(Category category) {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
    }
  }
}
