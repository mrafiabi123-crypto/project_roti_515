import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _token; 
  
  String? get token => _token;
  // Tiket masuk user

  // Cek status: Apakah punya token?
  bool get isLoggedIn => _token != null;

  // Fungsi Login (Simpan Token)
  void loginSuccess(String newToken) {
    _token = newToken;
    notifyListeners(); // Kabari semua halaman: "User sudah masuk!"
  }

  // Fungsi Logout (Hapus Token)
  void logout() {
    _token = null;
    notifyListeners(); // Kabari semua halaman: "User sudah keluar!"
  }
}