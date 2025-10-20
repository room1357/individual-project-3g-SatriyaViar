import 'dart:io';
import 'package:flutter/material.dart';
import '../Services/auth_services.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'edit_profil_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _authService.loadData();
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilScreen()),
    );
    if (result == true) _loadUserData(); // reload setelah update
  }

  Future<void> _navigateToChangePassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // 🧩 Foto profil dinamis
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: user.profileImage != null &&
                            user.profileImage!.isNotEmpty
                        ? FileImage(File(user.profileImage!))
                        : null,
                    child: user.profileImage == null ||
                            user.profileImage!.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.blue)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.username,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      child: Column(
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.edit, color: Colors.blueAccent),
                            title: const Text('Edit Profil'),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            onTap: _navigateToEditProfile,
                          ),
                          const Divider(),
                          ListTile(
                            leading:
                                const Icon(Icons.lock, color: Colors.orange),
                            title: const Text('Ubah Password'),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            onTap: _navigateToChangePassword,
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
