import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminProductProvider extends ChangeNotifier {
  List<dynamic> _allProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = "";
  int _selectedTab = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedTab => _selectedTab;

  String get _baseUrl {
    const String port = '8080';
    if (kIsWeb) return 'http://localhost:$port';
    return Platform.isAndroid ? 'http://10.0.2.2:$port' : 'http://localhost:$port';
  }

  String get _apiUrl => '$_baseUrl/api/foods';

  List<dynamic> get filteredProducts {
    var list = _allProducts.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    if (_selectedTab == 1) list = list.where((p) => (p['stock'] ?? 0) == 0).toList();
    else if (_selectedTab == 2) list = list.where((p) => (p['stock'] ?? 0) > 0 && (p['stock'] ?? 0) <= 15).toList();
    
    return list;
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners(); 
  }

  void setTab(int index) {
    _selectedTab = index;
    notifyListeners(); 
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> rawProducts = data['data'] ?? [];

        _allProducts = rawProducts.map((p) {
          // 1. Ambil nama file dari DB (contoh: "onde_onde.png")
          String rawImage = p['image_url'] ?? '';
          
          if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
            // 2. Jika di DB belum ada kata "/static", kita tambahkan manual
            if (!rawImage.startsWith('/static')) {
              // Pastikan path diawali '/'
              if (!rawImage.startsWith('/')) rawImage = '/$rawImage';
              
              // HASIL: http://localhost:8080/static/onde_onde.png
              p['image_url'] = '$_baseUrl/static$rawImage';
            } else {
              p['image_url'] = '$_baseUrl$rawImage';
            }
          }
          return p;
        }).toList();

      } else {
        _errorMessage = "Gagal memuat produk. Kode: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Gagal terhubung ke server.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambahkan import di paling atas jika belum ada
// import 'dart:convert';

  // --- FUNGSI TAMBAH PRODUK ---
  Future<bool> addProduct({
    required String name,
    required String category,
    required int price,
    required int stock,
    required String imageUrl, // Sementara kita kirim nama file dulu
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Siapkan data JSON
      final body = jsonEncode({
        "name": name,
        "category": category,
        "price": price,
        "stock": stock,
        "image_url": imageUrl, // Contoh: "/static/roti_baru.png"
      });

      // 2. Kirim ke API Admin (Pastikan rutenya /api/admin/foods)
      // Note: Jika login sudah aktif, tambahkan header Authorization: Bearer <token>
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/foods'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 3. Jika berhasil, ambil data terbaru agar list di depan terupdate
        await fetchProducts(); 
        return true;
      } else {
        _errorMessage = "Gagal simpan: ${response.body}";
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan koneksi.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}