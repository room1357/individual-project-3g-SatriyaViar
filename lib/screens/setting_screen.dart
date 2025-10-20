import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text("Umum", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text("Mode Gelap"),
            value: false, // default (nanti bisa dibuat dinamis pakai state/provider)
            onChanged: (bool value) {
              // TODO: Implementasikan fitur dark mode
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Bahasa"),
            subtitle: const Text("Indonesia"),
            onTap: () {
              // TODO: Implementasikan pilihan bahasa
            },
          ),
          const Divider(),
          const ListTile(
            title: Text("Akun", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Keamanan"),
            onTap: () {
              // TODO: navigasi ke layar keamanan
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Tentang Aplikasi"),
            onTap: () {
              // Navigator To AboutScreen
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));  
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
