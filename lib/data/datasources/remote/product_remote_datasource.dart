// lib/data/datasources/remote/product_remote_datasource.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/product_model.dart';

class ProductRemoteDataSource {
  // GANTI '192.168.x.x' dengan IPv4 kamu hasil ipconfig tadi
  // Gunakan port 8080 sesuai rute di main.go kamu
 final String baseUrl = 'http://localhost:8080/api/foods'; 

  Future<List<ProductModel>> getProducts({String? category, String? search}) async {
    try {
      String url = '$baseUrl?';
      if (category != null && category != 'All') url += 'category=$category&';
      if (search != null) url += 'search=$search';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productList = data['data'];
        return productList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      print("Network Error: $e");
      rethrow;
    }
  }
}