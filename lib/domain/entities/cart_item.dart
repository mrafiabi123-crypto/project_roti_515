// Lokasi file: lib/data/models/cart_item.dart 
// Atau jika di folder state: lib/presentation/state/cart_item.dart

import '../../domain/entities/product.dart'; 

class CartItem {
  final Product product; // Ganti dari Food menjadi Product
  int quantity;

  CartItem({
    required this.product, 
    this.quantity = 1,
  });

  // Hitung total harga per item (Harga x Jumlah)
  // Menggunakan int karena harga di database kamu (MySQL) adalah INT
  int get totalPrice => product.price * quantity;
}