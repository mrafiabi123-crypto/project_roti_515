class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final double rating;
  final String category;
  final bool isBestseller; // Ganti badge menjadi isBestseller

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.isBestseller,
  });
}