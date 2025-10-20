import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserAccount {
  final String id;
  final String username;
  final String email;
  final String password; // Sudah dalam bentuk hash

  UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  /// Buat user baru dengan password mentah (otomatis di-hash)
  factory UserAccount.create({
    required String id,
    required String username,
    required String email,
    required String rawPassword,
  }) {
    return UserAccount(
      id: id,
      username: username,
      email: email,
      password: _hashPassword(rawPassword),
    );
  }

  /// Fungsi hashing SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Verifikasi password (membandingkan dengan hash)
  bool verifyPassword(String inputPassword) {
    return password == _hashPassword(inputPassword);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'password': password,
      };

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserAccount.fromJson(String source) =>
      UserAccount.fromMap(jsonDecode(source));
}
