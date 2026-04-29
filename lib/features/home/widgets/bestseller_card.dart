import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/price_formatter.dart';
import '../../product/models/product_model.dart';
import '../../../core/utils/premium_snackbar.dart';
import '../../product/screens/product_detail_screen.dart';
import '../../favorite/providers/favorite_provider.dart';
import '../../product/widgets/animated_favorite_button.dart';
import 'package:roti_515/core/theme/app_theme.dart';

/// Komponen UI berbentuk kartu untuk menampilkan produk terlaris di Home Screen.
class BestsellerCard extends StatelessWidget {
  // Properti model produk yang wajib dikirim saat menggunakan komponen ini
  final ProductModel product;
  const BestsellerCard({super.key, required this.product});

  void _showAddedSnackBar(BuildContext context, String productName) {
    PremiumSnackbar.showSuccess(context, "$productName ditambahkan!");
  }

  @override
  Widget build(BuildContext context) {
    // Container utama kartu pembungkus produk
    return Container(
      width: 170, // Sama seperti ukuran ideal ProductCard di layout grid 2 kolom
      margin: EdgeInsets.only(right: 16), // Jarak margin kanan antar kartu sebesar 16
      decoration: BoxDecoration(
        color: context.colors.white, // Latar belakang kartu berwarna putih
        borderRadius: BorderRadius.circular(32), // Sama dengan ProductCard
        border: Border.all(color: context.colors.divider), // Garis tepi pinggiran (border) transparan/ringan
        boxShadow: [
          BoxShadow(
            color: context.colors.textDark.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      // Konten disusun secara vertikal (gambar di atas, teks di bawah)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri text
        children: [
          // Area Gambar Produk (Thumbnail)
          Padding(
            padding: EdgeInsets.all(13), // Padding di sekeliling gambar
            // Menggunakan Stack untuk menumpuk elemen: [1]Gambar Roti, di atasnya ada [2]Rating, dan [3]Love
            child: Stack(
              children: [
                // Memotong sudut siku-siku gambar asli agar ikut melengkung sesuai tepi dalam kartu
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  // Memuat URL foto produk dari server melalui network
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: Image.network(
                      product.imageUrl,
                      height: 150, // Gambar menempati tinggi tetap
                      width: double.infinity, // Melebar penuh mengisi sisi memanjang
                      fit: BoxFit.cover, // Gambar dipotong menyesuaikan proporsi (tidak gepeng)
                    ),
                  ),
                ),
                
                // Elemen Mengambang Kiri Atas: Lencana Nilai Ulasan (Rating)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.white.withValues(alpha: 0.9), // Putih sedikit transparan
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ikon Bintang Kuning
                        Icon(Icons.star_rounded,
                            color: context.colors.primaryOrange, size: 10),
                        SizedBox(width: 4),
                        // Teks Angka Rating (contoh: 4.8)
                        Text(
                          "${product.rating}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.colors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Elemen Mengambang Kanan Atas: Tombol Favorit (Love/Heart)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final bool isFav = favProvider.isFavorite(product);
                      return AnimatedFavoriteButton(
                        isFavorite: isFav,
                        onTap: () => favProvider.toggleFavorite(product),
                      );
                    },
                  ),
                ),
                
                // Badge Stok (Animasi 2)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stock == 0 
                          ? context.colors.error.withValues(alpha: 0.9) 
                          : context.colors.primaryOrange.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.stock == 0 ? Icons.block_flipped : Icons.inventory_2_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          product.stock == 0 ? "Habis" : "${product.stock}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Elemen Mengambang Kanan Bawah: Badge Detail
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                      FadePageRoute(
                        page: ProductDetailScreen(product: product),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Detail",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF475569)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Area Teks Detail: Judul, Deskripsi, Harga (Bagian paruh bawah kartu)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri teks
              children: [
                // Label Judul "Nama Roti"
                Text(
                  product.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.colors.textDark,
                  ),
                  maxLines: 1, // Batasi 1 baris supaya layout rapi
                  overflow: TextOverflow.ellipsis, // Jika kepanjangan, potong dengan tanda "..."
                ),
                
                // Label Deskripsi Varian Roti (Kecil)
                Text(
                  product.description,
                  style: GoogleFonts.pontanoSans(
                    fontSize: 12,
                    color: context.colors.textGrey,
                    fontWeight: FontWeight.w500, // Ketebalan netral
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12), // Jeda atas sebelum area blok harga
                
                // Row untuk meletakkan "Label Harga" rata kiri dan "Tombol Plus" mentok di ujung kanan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nilai angka harga Rupiah dengan format string converter kustom
                    Text(
                      "Rp ${formatRupiah(product.price)}",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.colors.textDark,
                      ),
                    ),
                    
                    // Lingkaran Hitam bulat Tombol (+) Tambah ke keranjang belanja
                    GestureDetector(
                      onTap: () {
                        Provider.of<CartProvider>(context, listen: false).addToCart(product);
                        _showAddedSnackBar(context, product.name);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: context.colors.textDark, shape: BoxShape.circle),
                        child: Icon(Icons.add_rounded,
                            color: context.colors.white, size: 16), // Ikon panah simpul warna putih
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
