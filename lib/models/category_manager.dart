// category_manager.dart
import 'category.dart';

class CategoryManager {
  static final List<Category> _categories = [
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

  // READ: ambil semua kategori
  static List<Category> getAllCategories() {
    return List.unmodifiable(_categories); // tidak bisa diubah dari luar
  }

  // READ: cari kategori berdasarkan ID
  static Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // READ: cari kategori berdasarkan nama
  static Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // CREATE: tambah kategori baru
  static void addCategory(Category category) {
    // cek apakah id sudah ada
    if (_categories.any((c) => c.id == category.id)) {
      throw Exception("Kategori dengan ID ${category.id} sudah ada!");
    }
    _categories.add(category);
  }

  // UPDATE: edit kategori berdasarkan ID
  static void editCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    } else {
      throw Exception("Kategori dengan ID ${category.id} tidak ditemukan!");
    }
  }

  // DELETE: hapus kategori
  static void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
  }

  
}
