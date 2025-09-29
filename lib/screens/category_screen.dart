import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/models/category.dart';
import '../models/category_manager.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  // 🔹 Dialog Tambah / Edit Kategori
  void _showCategoryDialog({Category? category}) {
    if (category != null) {
      _nameController.text = category.name;
      _descController.text = category.description;
    } else {
      _nameController.clear();
      _descController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              category == null ? Icons.add_box : Icons.edit,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              category == null ? "Tambah Kategori" : "Edit Kategori",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nama Kategori",
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nama kategori wajib diisi !";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Deskripsi wajib diisi !";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel, color: Colors.grey),
            label: const Text("Batal"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  if (category == null) {
                    // Tambah
                    CategoryManager.addCategory(
                      Category(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        name: _nameController.text.trim(),
                        description: _descController.text.trim(),
                      ),
                    );
                  } else {
                    // Edit
                    CategoryManager.editCategory(
                      Category(
                        id: category.id,
                        name: _nameController.text.trim(),
                        description: _descController.text.trim(),
                      ),
                    );
                  }
                });
                Navigator.pop(context);
              }
            },
            icon: Icon(category == null ? Icons.save : Icons.update),
            label: Text(category == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    );
  }

  // 🔹 Konfirmasi sebelum hapus
  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Hapus Kategori",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah kamu yakin ingin menghapus kategori \"${category.name}\"?",
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel, color: Colors.grey),
            label: const Text("Batal"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                CategoryManager.removeCategory(category.id);
              });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete, color: Colors.white,),
            label: const Text("Hapus", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryManager.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Kategori'.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lucida Sans',
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                "Belum ada kategori",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(category.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showCategoryDialog(category: category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        tooltip: "Tambah Kategori",
        onPressed: () => _showCategoryDialog(),
        elevation: 10,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
