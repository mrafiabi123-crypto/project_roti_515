// lib/presentation/state/product_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/datasources/remote/product_remote_datasource.dart';

class ProductProvider with ChangeNotifier {
  final ProductRemoteDataSource dataSource = ProductRemoteDataSource();
  
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  // Filter untuk Bestsellers di Home
  List<ProductModel> get bestsellers => 
      _products.where((p) => p.isBestseller).toList();

  Future<void> fetchProducts({String? query}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Memanggil data melalui DataSource yang sudah pakai IP Laptop
      _products = await dataSource.getProducts(search: query);
    } catch (e) {
      print("Error in Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}