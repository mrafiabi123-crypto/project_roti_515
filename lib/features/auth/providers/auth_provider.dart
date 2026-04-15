import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _name;

  String? get token => _token;
  String? get role => _role;
  String? get name => _name;

  bool get isLoggedIn => _token != null;
  bool get isAdmin => _role == 'admin';

  // --- PERSISTENCE KEYS ---
  static const String _keyToken = "auth_token";
  static const String _keyRole = "user_role";
  static const String _keyName = "user_name";

  /// Panggil ini saat aplikasi pertama kali dijalankan
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_keyToken);
    _role = prefs.getString(_keyRole);
    _name = prefs.getString(_keyName);
    notifyListeners();
  }

  /// Fungsi Login Baru: Menyimpan sesi ke storage
  Future<void> login(String newToken, {String? role, String? name}) async {
    _token = newToken;
    _role = role;
    _name = name;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, newToken);
    if (role != null) await prefs.setString(_keyRole, role);
    if (name != null) await prefs.setString(_keyName, name);

    notifyListeners();
  }

  /// Fungsi Logout: Menghapus sesi dari storage
  Future<void> logout() async {
    _token = null;
    _role = null;
    _name = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyName);

    notifyListeners();
  }
}