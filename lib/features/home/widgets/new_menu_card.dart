import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/price_formatter.dart';
import '../../product/models/product_model.dart';
import '../../../core/utils/premium_snackbar.dart';
import '../../product/screens/product_detail_screen.dart';

/// Komponen UI berbentuk kartu horizontal untuk daftar "Menu Baru".
class NewMenuCard extends StatelessWidget {
  final ProductModel product;
  const NewMenuCard({super.key, required this.product});

  void _showAddedSnackBar(BuildContext context, String productName) {
    PremiumSnackbar.showSuccess(context, "$productName masuk ke keranjang");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        FadePageRoute(
          page: ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        width: 285,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.05), blurRadius: 2)
          ],
        ),
        child: Row(
          children: [
            // Gambar Thumbnail Makanan
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Hero(
                tag: 'product-image-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Detail Teks (Nama, Deskripsi, Harga)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp ${formatRupiah(product.price)}",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      // Tombol Tambah Keranjang
                      GestureDetector(
                        onTap: () {
                          Provider.of<CartProvider>(context, listen: false).addToCart(product);
                          _showAddedSnackBar(context, product.name);
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: AppColors.divider, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded,
                              size: 16, color: AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
