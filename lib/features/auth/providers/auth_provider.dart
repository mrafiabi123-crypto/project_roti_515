import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthProvider: Pusat manajemen status autentikasi di seluruh aplikasi.
/// Kelas ini memberitahu UI saat user login atau logout.
class AuthProvider extends ChangeNotifier {
  // Variabel privat untuk menyimpan data sesi di memori (selama aplikasi berjalan)
  String? _token;
  String? _role;
  String? _name;
  String? _photoUrl;

  // Getter: Cara aman untuk mengakses data autentikasi dari luar kelas
  String? get token => _token;
  String? get role => _role;
  String? get name => _name;
  String? get photoUrl => _photoUrl;

  // Fungsi helper: Mengecek status apakah user sudah login atau bertindak sebagai admin
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _role == 'admin';

  // --- KUNCI PENYIMPANAN PERMANEN ---
  // Nama label (key) untuk menyimpan data di memori HP (Shared Preferences)
  static final String _keyToken = "auth_token";
  static final String _keyRole = "user_role";
  static final String _keyName = "user_name";
  static final String _keyPhotoUrl = "user_photo_url";

  /// MEMUAT SESI (Fungsi Auto-Login):
  /// Dipanggil saat aplikasi pertama kali dibuka untuk mengecek data login lama.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengambil data dari penyimpanan permanen HP
    _token = prefs.getString(_keyToken);
    _role = prefs.getString(_keyRole);
    _name = prefs.getString(_keyName);
    _photoUrl = prefs.getString(_keyPhotoUrl);
    
    // Memberitahu UI (Listener) bahwa data sesi sudah siap digunakan
    notifyListeners();
  }

  /// UPDATE PHOTO URL:
  /// Memperbarui URL foto profil secara global tanpa harus login ulang.
  Future<void> updatePhotoUrl(String? url) async {
    _photoUrl = url;
    final prefs = await SharedPreferences.getInstance();
    if (url != null) {
      await prefs.setString(_keyPhotoUrl, url);
    } else {
      await prefs.remove(_keyPhotoUrl);
    }
    notifyListeners();
  }

  /// LOGIN (Simpan Sesi):
  /// Dipanggil setelah user berhasil melakukan request login ke server.
  Future<void> login(String newToken, {String? role, String? name, String? photoUrl}) async {
    _token = newToken;
    _role = role;
    _name = name;
    _photoUrl = photoUrl;

    // Menyimpan data secara permanen ke memori HP (Persistence)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, newToken);
    if (role != null) await prefs.setString(_keyRole, role);
    if (name != null) await prefs.setString(_keyName, name);
    if (photoUrl != null) await prefs.setString(_keyPhotoUrl, photoUrl);

    // Memicu perubahan UI di seluruh aplikasi (misal: tombol 'Daftar' jadi 'Profil')
    notifyListeners();
  }

  /// LOGOUT (Hapus Sesi):
  /// Menghapus semua data sesi baik dari memori aplikasi maupun penyimpanan HP.
  Future<void> logout() async {
    _token = null;
    _role = null;
    _name = null;
    _photoUrl = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhotoUrl);

    // Mengembalikan status aplikasi ke kondisi 'Belum Login'
    notifyListeners();
  }
}