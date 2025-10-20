import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/models/category_manager.dart';
import 'package:pemrograman_mobile/models/expense_manager.dart';
import 'package:pemrograman_mobile/screens/advanced_expense_list_screen.dart';
import 'package:pemrograman_mobile/screens/category_screen.dart';
import 'package:pemrograman_mobile/screens/statistik_screen.dart';
import 'login_screen.dart';
import 'expense_list_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';
import 'setting_screen.dart';
import '../Services/auth_services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = AuthService();
              await auth
                  .signOut(); // Hapus sesi login dari SharedPreferences

              // Kembali ke halaman login, dan hapus semua route sebelumnya
              if (!context.mounted) return; // pastikan context masih aktif
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'Pengeluaran',
                    Icons.attach_money,
                    Colors.green,
                    () {
                      // Navigasi ke ExpenseListScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenseListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    'Advanced Pengeluaran',
                    Icons.attach_money,
                    Colors.lightGreen,
                    () {
                      // Navigasi ke ExpenseListScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const AdvancedExpenseListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    'Kategori',
                    Icons.category,
                    Colors.red,
                    () {
                      // Navigasi ke CategoryScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard('Profil', Icons.person, Colors.blue, () {
                    // Navigasi ke ProfileScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }),
                  _buildDashboardCard(
                    'Statistik',
                    Icons.bar_chart,
                    Colors.purple,
                    () {
                      // Navigasi ke StatisticsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StatisticsScreen(
                                expenses: ExpenseManager.getAllExpenses(),
                                categories: CategoryManager.getAllCategories(),
                              ),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    'Pesan',
                    Icons.message,
                    Colors.orange,
                    () {
                      // Navigasi ke MessageScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MessageScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    'Pengaturan',
                    Icons.settings,
                    Colors.purple,
                    () {
                      // Navigasi Ke SettingScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (content) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 4,
      child: Builder(
        builder:
            (context) => InkWell(
              onTap:
                  onTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fitur $title segera hadir!')),
                    );
                  },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 48, color: color),
                    SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
