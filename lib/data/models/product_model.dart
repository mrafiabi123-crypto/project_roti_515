import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.rating,
    required super.category,
    required super.isBestseller,
  });

  // Fungsi sakti untuk mengubah JSON dari Golang menjadi Object Flutter
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      
      // Price di DB MySQL adalah INT, kita pastikan di sini tetap int
      price: json['price'] ?? 0, 
      
      // Sesuaikan key dengan snake_case dari JSON Golang
      imageUrl: json['image_url'] ?? '', 
      
      // Handle rating agar selalu jadi double meskipun API kirim int
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      
      category: json['category'] ?? '',
      
      // Field baru sesuai database MySQL
      isBestseller: json['is_bestseller'] ?? false,
    );
  }
}