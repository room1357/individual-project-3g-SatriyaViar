import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final List<String> categories = [
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Pendidikan',
    'Utilitas',
    'Kesehatan',
    'Belanja',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Kategori"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.category, color: Colors.blue),
            title: Text(categories[index]),
            onTap: () {
              Navigator.pop(context, categories[index]); 
              // ini biar kalau dipilih bisa kirim balik kategori yang dipilih
            },
          );
        },
      ),
    );
  }
}
