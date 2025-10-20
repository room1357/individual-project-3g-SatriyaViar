import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _uuid = const Uuid();
  UserAccount? _currentUser;
  List<UserAccount> _users = [];

  UserAccount? get currentUser => _currentUser;

  // Load data dari SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('user_list');
    final currentJson = prefs.getString('active_user');

    if (usersJson != null) {
      final data = jsonDecode(usersJson) as List;
      _users = data.map((e) => UserAccount.fromMap(e)).toList();
    }

    if (currentJson != null) {
      _currentUser = UserAccount.fromMap(jsonDecode(currentJson));
    }
  }

  // Register user baru
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final exists = _users.any((u) => u.email == email);
    if (exists) return false;

    final newUser = UserAccount(
      id: _uuid.v4(),
      username: username,
      email: email,
      password: password,
    );

    _users.add(newUser);
    _currentUser = newUser;

    await prefs.setString(
        'user_list', jsonEncode(_users.map((e) => e.toMap()).toList()));
    await prefs.setString('active_user', jsonEncode(newUser.toMap()));
    return true;
  }

  // Login user
  Future<bool> signIn(String username,String password) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final foundUser = _users.firstWhere(
          (u) => u.username == username && u.password == password);
      _currentUser = foundUser;
      await prefs.setString('active_user', jsonEncode(foundUser.toMap()));
      return true;
    } catch (_) {
      return false;
    }
  }

  // Logout user
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = null;
    await prefs.remove('active_user');
  }

  // Update data user aktif
  Future<void> updateProfile(UserAccount updatedUser) async {
    final prefs = await SharedPreferences.getInstance();

    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      _currentUser = updatedUser;

      await prefs.setString(
          'user_list', jsonEncode(_users.map((e) => e.toMap()).toList()));
      await prefs.setString('active_user', jsonEncode(updatedUser.toMap()));
    }
  }

  List<UserAccount> getAllUsers() => _users;
}
