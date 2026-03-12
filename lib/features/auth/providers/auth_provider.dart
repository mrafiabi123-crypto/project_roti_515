import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _token; 
  
  String? get token => _token;

  // Getter untuk cek status login
  bool get isLoggedIn => _token != null;

  // Fungsi Login
  // Saya ganti namanya jadi login agar lebih singkat
  void login(String newToken) {
    _token = newToken;
    notifyListeners(); 
  }

  // Fungsi Logout
  void logout() {
    _token = null;
    notifyListeners(); 
  }
}