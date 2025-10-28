import 'dart:convert';
import 'package:pemrograman_mobile/models/expense_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/shared_expenses.dart'; 
import '../models/shared_expenses_manager.dart'; 

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _uuid = const Uuid();
  UserAccount? _currentUser;
  List<UserAccount> _users = [];
  List<SharedExpense> _sharedExpenses = []; // daftar shared expense milik user

  UserAccount? get currentUser => _currentUser;
  List<SharedExpense> get sharedExpenses => _sharedExpenses; 

  // 🔹 Load data dari SharedPreferences
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

    // ⬅️ Sekalian load shared expenses
    await loadUserSharedExpenses();
  }

  // ✅ Tambahan: Load hanya shared expenses yang relevan dengan user aktif
  Future<void> loadUserSharedExpenses() async {
    if (_currentUser == null) return;
    final manager = SharedExpenseManager();
    final allExpenses = await manager.getAllExpenses();

    // Filter hanya expense yang dibuat oleh user ini atau user termasuk member-nya
    _sharedExpenses = allExpenses.where((e) =>
        e.createdBy == _currentUser!.username ||
        e.members.contains(_currentUser!.username)).toList();
  }

  // ✅ Ambil semua expense gabungan (personal + shared)
Future<List<Map<String, dynamic>>> getCombinedExpenses() async {
  final personal = ExpenseManager.expenses
      .map((e) => {
            'title': e.title,
            'amount': e.amount,
            'category': e.category,
            'date': e.date,
            'type': 'personal',
          })
      .toList();

  final shared = _sharedExpenses
      .map((s) => {
            'title': s.title,
            'amount': s.amount,
            'category': 'Pengeluaran Bersama',
            'date': s.date,
            'type': 'shared',
          })
      .toList();

  return [...personal, ...shared];
}


  // 🔹 Register user baru (hash password)
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final exists = _users.any((u) => u.username == username);
    if (exists) return false;

    final newUser = UserAccount.create(
      id: _uuid.v4(),
      username: username,
      email: email,
      rawPassword: password,
    );

    _users.add(newUser);
    _currentUser = newUser;

    await prefs.setString(
      'user_list',
      jsonEncode(_users.map((e) => e.toMap()).toList()),
    );
    await prefs.setString('active_user', jsonEncode(newUser.toMap()));
    return true;
  }

  // 🔹 Login user (dengan verifikasi hash)
  Future<bool> signIn(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final foundUser = _users.firstWhere((u) => u.username == username);
      if (!foundUser.verifyPassword(password)) {
        return false;
      }

      _currentUser = foundUser;
      await prefs.setString('active_user', jsonEncode(foundUser.toMap()));

      // ⬅️ Load shared expense setiap kali user login
      await loadUserSharedExpenses();

      return true;
    } catch (_) {
      return false;
    }
  }

  // 🔹 Logout user
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = null;
    _sharedExpenses = []; // ⬅️ Kosongkan juga shared expense
    await prefs.remove('active_user');
  }

  // 🔹 Ambil user yang sedang aktif
  Future<UserAccount?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final currentJson = prefs.getString('active_user');
    if (currentJson != null) {
      _currentUser = UserAccount.fromMap(jsonDecode(currentJson));
      await loadUserSharedExpenses(); // ⬅️ Tambahkan di sini juga
    }
    return _currentUser;
  }

  // 🔹 Update data profil user aktif
  Future<void> updateProfile(UserAccount updatedUser) async {
    final prefs = await SharedPreferences.getInstance();

    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      _currentUser = updatedUser;

      await prefs.setString(
        'user_list',
        jsonEncode(_users.map((e) => e.toMap()).toList()),
      );
      await prefs.setString('active_user', jsonEncode(updatedUser.toMap()));
    }
  }

  // 🔹 Ambil semua user (misalnya untuk fitur "pengeluaran bersama")
  List<UserAccount> getAllUsers() => _users;
}
