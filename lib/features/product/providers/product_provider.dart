import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../../../core/network/api_service.dart';

/// Provider untuk mengelola state data Produk/Katalog.
class ProductProvider extends ChangeNotifier {
  // State variables
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Getters untuk diakses oleh UI
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  /// Memfilter produk unggulan (Bestseller)
  List<ProductModel> get bestsellers =>
      _products.where((p) => p.isBestseller == true).toList();

  /// Memfilter produk menu baru (Non-Bestseller)
  List<ProductModel> get newMenus =>
      _products.where((p) => p.isBestseller == false).toList();

  // Endpoint konfigurasi dari ApiService terpusat
  final String _baseUrl = ApiService.foods;
  final String _staticUrl = ApiService.staticFiles;

  /// Mengambil data produk dari backend REST API dengan opsi pencarian/filter.
  Future<void> fetchProducts({String? query}) async {
    _isLoading = true;
    _errorMessage = '';

    if (query != null) {
      _searchQuery = query;
    }

    try {
      // Menyusun parameter query untuk URL (opsional: category & search)
      final Map<String, String> queryParameters = {};

      if (_selectedCategory != 'All') {
        queryParameters['category'] = _selectedCategory;
      }

      if (_searchQuery.isNotEmpty) {
        queryParameters['search'] = _searchQuery;
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
      debugPrint("📡 Memeriksa API: $uri");

      // Modifikasi timeout 10 detik untuk mencegah aplikasi menggantung (hang)
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        // Ekstraksi array JSON dari prop 'data' sesuai format standar response backend
        final List<dynamic> listData = decodedData['data'] ?? [];

        _products = listData.map((json) {
          // Menyesuaikan path gambar relatif dari database menjadi absolute URL static files
          String fileName = json['image_url'] ?? '';
          if (fileName.isNotEmpty && !fileName.startsWith('http')) {
            json['image_url'] = '$_staticUrl$fileName';
          }
          return ProductModel.fromJson(json);
        }).toList();

        debugPrint("✅ Berhasil memuat ${_products.length} produk.");
      } else {
        // Penanganan jika server mengembalikan HTTP Error (misal 500 / 404)
        _errorMessage = "Gagal memuat data (Status HTTP: ${response.statusCode})";
        debugPrint("❌ Server Error: ${response.body}");
      }
    } catch (e) {
      // Penanganan error network / putus koneksi
      _errorMessage = "Koneksi ke server gagal. Periksa koneksi backend.";
      debugPrint("❌ Provider Error: $e");
    } finally {
      // Menghentikan state loading dan meminta UI untuk merender ulang perubahan state
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui kategori produk yang sedang aktif dan menjalankan ulang request API.
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    fetchProducts();
  }

  /// Membersihkan seluruh filter pencarian & kategori ke posisi awal.
  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    fetchProducts();
  }
}
