class ProductModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final double rating;
  final String category;
  final bool isBestseller;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.isBestseller,
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