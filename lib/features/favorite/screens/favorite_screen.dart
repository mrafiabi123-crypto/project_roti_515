import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- IMPORT PONDASI & MODEL ---
import '../../../core/constants/app_colors.dart';
import '../../product/models/product_model.dart';

// --- IMPORT PROVIDER & SCREEN LAIN ---
import '../providers/favorite_provider.dart';
// (Import Cart sementara masih mengarah ke folder lama, tidak apa-apa)
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  String formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          _buildMainContent(context),
          _buildTopBar(context),
        ],
      ),
    );
  }

  // --- 1. HEADER (515 & ICON KERANJANG) ---
  Widget _buildTopBar(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColors.bgColor.withOpacity(0.95),
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            " 515",
            style: GoogleFonts.dmSerifDisplay(fontSize: 30, color: AppColors.textBrown),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _circleIcon(Icons.shopping_cart_outlined),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 2. KONTEN UTAMA (LIST PRODUK FAVORIT) ---
  Widget _buildMainContent(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final favorites = favProvider.favorites;

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  "Belum ada roti favoritmu.",
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) => _buildProductCard(context, favorites[index]),
        );
      },
    );
  }

  // --- 3. KARTU PRODUK ---
  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final favProvider = Provider.of<FavoriteProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(product.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => favProvider.toggleFavorite(product),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: AppColors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pontanoSans(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rp ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                _addIcon(context, product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addIcon(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () {
        // PERHATIAN: Baris di bawah ini mungkin akan merah jika CartProvider belum di-update!
        Provider.of<CartProvider>(context, listen: false).addToCart(product);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product.name} ditambah!", style: GoogleFonts.plusJakartaSans(color: AppColors.white)), 
            duration: const Duration(milliseconds: 500),
            backgroundColor: AppColors.success,
          ),
        );
      },
      child: Container(
        width: 32, height: 32,
        decoration: const BoxDecoration(color: AppColors.textDark, shape: BoxShape.circle),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 16),
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider),
      ),
      child: Icon(icon, color: AppColors.textBrown, size: 20),
    );
  }
}