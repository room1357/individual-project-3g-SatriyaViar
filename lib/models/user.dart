import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserAccount {
  final String id;
  final String username;
  final String email;
  final String password; // Dalam bentuk HASH
  final String? profileImage; // path atau base64 string gambar profil

  UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profileImage,
  });

  factory UserAccount.create({
    required String id,
    required String username,
    required String email,
    required String rawPassword,
    String? profileImage,
  }) {
    return UserAccount(
      id: id,
      username: username,
      email: email,
      password: _hashPassword(rawPassword),
      profileImage: profileImage,
    );
  }


  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }


  bool verifyPassword(String inputPassword) {
    return password == _hashPassword(inputPassword);
  }


  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'password': password,
        'profileImage': profileImage, // ✅ tambahkan
      };


  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      profileImage: map['profileImage'], // ✅ tambahkan
    );
  }

  /// 🔁 JSON encode/decode
  String toJson() => jsonEncode(toMap());

  factory UserAccount.fromJson(String source) =>
      UserAccount.fromMap(jsonDecode(source));

 
  UserAccount copyWith({
    String? username,
    String? email,
    String? password,
    String? profileImage,
  }) {
    return UserAccount(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
