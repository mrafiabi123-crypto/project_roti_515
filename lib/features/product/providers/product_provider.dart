import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart'; 

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'All'; 
  String _searchQuery = ''; 

  // Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // Filter local untuk UI Home
  List<ProductModel> get bestsellers => 
      _products.where((p) => p.isBestseller == true).toList();

  List<ProductModel> get newMenus => 
      _products.where((p) => p.isBestseller == false).toList();

  // ✅ Menggunakan 127.0.0.1 (Lebih stabil untuk local development)
  final String _baseUrl = 'http://127.0.0.1:8080/api/foods';
  final String _staticUrl = 'http://127.0.0.1:8080/static/';

  Future<void> fetchProducts({String? query}) async {
    _isLoading = true;
    _errorMessage = '';
    
    if (query != null) {
      _searchQuery = query;
    }
    
    // Jangan notifyListeners di awal initState untuk menghindari 'build marked as needing to settle'
    // notifyListeners(); 

    try {
      final Map<String, String> queryParameters = {};
      
      if (_selectedCategory != 'All') {
        queryParameters['category'] = _selectedCategory;
      }
      
      if (_searchQuery.isNotEmpty) {
        queryParameters['search'] = _searchQuery;
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
      debugPrint("📡 Memulai Fetching: $uri");

      // Set timeout 10 detik agar tidak blank selamanya jika server hang
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        
        // ✅ KRUSIAL: Ambil list dari key 'data' sesuai format main.go
        final List<dynamic> listData = decodedData['data'] ?? [];
        
        _products = listData.map((json) {
          // Mapping URL Gambar agar mengarah ke folder static backend
          String fileName = json['image_url'] ?? '';
          if (fileName.isNotEmpty && !fileName.startsWith('http')) {
            json['image_url'] = '$_staticUrl$fileName';
          }
          return ProductModel.fromJson(json);
        }).toList();

        debugPrint("✅ Berhasil memuat ${_products.length} produk.");
      } else {
        _errorMessage = "Gagal memuat data (Status: ${response.statusCode})";
        debugPrint("❌ Server Error: ${response.body}");
      }
    } catch (e) {
      _errorMessage = "Koneksi ke server gagal. Pastikan Backend Golang sudah jalan.";
      debugPrint("❌ Provider Crash: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return; 
    _selectedCategory = category;
    notifyListeners(); 
    fetchProducts(); 
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    fetchProducts();
  }
}