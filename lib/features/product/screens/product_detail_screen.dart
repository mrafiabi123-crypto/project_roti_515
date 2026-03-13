import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; 

// --- IMPORT PONDASI & MODEL ---
import '../../../core/constants/app_colors.dart';
import '../models/product_model.dart';

// --- IMPORT STATE (Sementara mengarah ke folder lama) ---
import '../../cart/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product; // Tipe data sudah kuat, bukan dynamic lagi

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  String formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
  }

  void _increaseQty() {
    setState(() => _quantity++);
  }

  void _decreaseQty() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = (widget.product.price * _quantity).toInt();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageHeader(),
                _buildProductInfo(),
                _buildDescription(),
                _buildQuantitySelector(),
              ],
            ),
          ),
          
          // Tombol Kembali & Favorit (Floating Glassmorphism)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context), size: 18),
                _buildGlassButton(Icons.favorite_border_rounded, () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Ditambahkan ke Favorit!", style: GoogleFonts.plusJakartaSans(color: AppColors.white)),
                      backgroundColor: AppColors.error, // Menggunakan warna merah untuk notif favorit
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Sticky Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStickyBottomBar(totalPrice),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.textDark.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 8)),
        ],
        image: DecorationImage(
          // Pengecekan aman jika URL gambar kosong
          image: NetworkImage(widget.product.imageUrl.isNotEmpty ? widget.product.imageUrl : "https://placehold.co/440x400"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: GoogleFonts.dmSerifDisplay(fontSize: 30, color: AppColors.textBrown, height: 1.2),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.primaryOrange, size: 14),
                          const SizedBox(width: 4),
                          Text("${widget.product.rating}", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("(120 ulasan)", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textGrey, decoration: TextDecoration.underline)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "Rp ${formatPrice(widget.product.price)}",
            style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Deskripsi", style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: AppColors.textBrown)),
          const SizedBox(height: 8),
          Text(
            widget.product.description.isNotEmpty ? widget.product.description : "Deskripsi produk belum tersedia.",
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textGrey, height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _buildTag(widget.product.category.isNotEmpty ? widget.product.category : "Roti"),
              if (widget.product.isBestseller) _buildTag("Bestseller 🔥"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.divider),
      ),
      child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textBrown, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Jumlah", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBrown)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white, borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _decreaseQty,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.remove_rounded, color: AppColors.textHint, size: 18),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: Text(
                      "$_quantity",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBrown),
                    ),
                  ),
                  GestureDetector(
                    onTap: _increaseQty,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.textBrown, borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.add_rounded, color: AppColors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(int totalPrice) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            border: const Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: GestureDetector(
            onTap: () {
              final cart = Provider.of<CartProvider>(context, listen: false);
              for (int i = 0; i < _quantity; i++) {
                cart.addToCart(widget.product);
              }
              
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              
              // CUSTOM POP UP NOTIFIKASI BOUNCING
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  duration: const Duration(milliseconds: 1500),
                  margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  content: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack, 
                    tween: Tween<double>(begin: 0.5, end: 1.0),
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primaryOrange, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: AppColors.primaryOrange.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, color: AppColors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Berhasil Ditambahkan!",
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryOrange),
                                ),
                                Text(
                                  "$_quantity x ${widget.product.name} masuk ke keranjang.",
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textBrown, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              
              Navigator.pop(context);
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryOrange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "Masukkan Keranjang  Rp ${formatPrice(totalPrice)}",
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap, {double size = 20}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: AppColors.textDark, size: size),
          ),
        ),
      ),
    );
  }
}