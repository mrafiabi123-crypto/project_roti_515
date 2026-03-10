import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/product.dart';
import '../../data/models/product_model.dart'; 

class ProductProvider extends ChangeNotifier {
  // --- STATE UTAMA ---
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'All'; 
  String _searchQuery = ''; 

  // --- GETTERS ---
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // Filter local untuk Bestseller (isBestseller == true)
  List<ProductModel> get bestsellers => 
      _products.where((p) => p.isBestseller == true).toList();

  // Filter local untuk Menu Baru (isBestseller == false)
  List<ProductModel> get newMenus => 
      _products.where((p) => p.isBestseller == false).toList();

  // --- URL CONFIG ---
  // Gunakan 10.0.2.2 jika kamu menggunakan Emulator Android, atau IP asli jika HP fisik
  final String _baseUrl = 'http://localhost:8080/api/foods';
  final String _staticUrl = 'http://localhost:8080/static/';

  // --- FUNGSI AMBIL DATA ---
  Future<void> fetchProducts({String? query}) async {
    _isLoading = true;
    _errorMessage = '';
    
    // Jika ada query baru dari search bar, update state _searchQuery
    if (query != null) {
      _searchQuery = query;
    }
    
    notifyListeners();

    try {
      // 1. Menyusun Query Parameters secara dinamis
      final Map<String, String> queryParameters = {};
      
      if (_selectedCategory != 'All') {
        queryParameters['category'] = _selectedCategory;
      }
      
      if (_searchQuery.isNotEmpty) {
        queryParameters['search'] = _searchQuery;
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
      debugPrint("📡 Fetching: $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> listData = data['data'];
        
        // 2. PROSES MAPPING GAMBAR & KONVERSI MODEL
        _products = listData.map((json) {
          // Mapping URL Gambar agar menjadi URL lengkap
          String fileName = json['image_url'] ?? '';
          if (fileName.isNotEmpty && !fileName.startsWith('http')) {
            json['image_url'] = '$_staticUrl$fileName';
          }
          return ProductModel.fromJson(json);
        }).toList();

      } else {
        _errorMessage = "Gagal memuat data menu (Error: ${response.statusCode})";
      }
    } catch (e) {
      _errorMessage = "Koneksi gagal. Cek server Golang kamu.";
      debugPrint("❌ Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI UPDATE FILTER ---

  // Fungsi untuk mengganti kategori dan langsung ambil data baru
  void setCategory(String category) {
    if (_selectedCategory == category) return; // Hindari fetch ulang jika kategori sama
    
    _selectedCategory = category;
    
    // Reset search query saat ganti kategori (opsional, tergantung keinginanmu)
    // _searchQuery = ''; 
    
    notifyListeners(); 
    fetchProducts(); // Panggil fetch dengan kategori yang baru disimpan
  }

  // Fungsi untuk reset semua filter
  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    fetchProducts();
  }
}