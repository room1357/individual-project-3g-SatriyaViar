import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Aplikasi Catatan Pengeluaran',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aplikasi ini dibuat untuk mencatat dan memantau pengeluaran harian Anda.\n'
              'Dikembangkan menggunakan Flutter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}
