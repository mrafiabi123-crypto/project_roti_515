import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; 

// --- IMPORT STATE & PROVIDER ---
import '../../../presentation/state/cart_provider.dart';

class MenuDetailPage extends StatefulWidget {
  final dynamic product; 

  const MenuDetailPage({super.key, required this.product});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  int _quantity = 1;

  final Color bgColor = const Color(0xFFFCFAF8);
  final Color textDarkBrown = const Color(0xFF5D4037);
  final Color primaryOrange = const Color(0xFFD47311);
  final Color starOrange = const Color(0xFFC2410C);
  final Color starBg = const Color(0xFFFFEDD5);
  final Color textGrey = const Color(0xFF78716C);
  final Color cardBg = const Color(0xFFF3EDE7);
  final Color borderGrey = const Color(0xFFE7E5E4);

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
      backgroundColor: bgColor,
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(Icons.arrow_back_ios_new, () => Navigator.pop(context), size: 18),
                _buildGlassButton(Icons.favorite_border, () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Ditambahkan ke Favorit!"),
                      backgroundColor: primaryOrange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }),
              ],
            ),
          ),
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
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 8)),
        ],
        image: DecorationImage(
          image: NetworkImage(widget.product.imageUrl ?? "https://placehold.co/440x400"),
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
                  style: GoogleFonts.dmSerifDisplay(fontSize: 30, color: textDarkBrown, height: 1.2),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: starBg, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: starOrange, size: 14),
                          const SizedBox(width: 4),
                          Text("4.8", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: starOrange)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("(120 ulasan)", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textGrey, decoration: TextDecoration.underline)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "Rp. ${formatPrice(widget.product.price)}",
            style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: Colors.black),
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
          Text("Deskripsi", style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: textDarkBrown)),
          const SizedBox(height: 8),
          Text(
            widget.product.description ?? "Deskripsi produk belum tersedia.",
            style: GoogleFonts.notoSans(fontSize: 14, color: const Color(0xFF57534E), height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _buildTag("Roti Keju"),
              _buildTag("Roti Pia Susu"),
              _buildTag("Roti Kacang"),
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
        color: cardBg, borderRadius: BorderRadius.circular(999), border: Border.all(color: borderGrey),
      ),
      child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textDarkBrown, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Jumlah", style: GoogleFonts.pragatiNarrow(fontSize: 18, fontWeight: FontWeight.bold, color: textDarkBrown)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFF5F5F4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _decreaseQty,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.remove, color: Color(0xFFA8A29E), size: 18),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: Text(
                      "$_quantity",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textDarkBrown),
                    ),
                  ),
                  GestureDetector(
                    onTap: _increaseQty,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: textDarkBrown, borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
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
            color: Colors.white.withOpacity(0.9),
            border: const Border(top: BorderSide(color: Color(0xFFF5F5F4))),
          ),
          child: GestureDetector(
            onTap: () {
              final cart = Provider.of<CartProvider>(context, listen: false);
              for (int i = 0; i < _quantity; i++) {
                cart.addToCart(widget.product);
              }
              
              // Sembunyikan snackbar lama & jalankan yang baru
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
                    curve: Curves.easeOutBack, // Memberikan efek membal (bouncy)
                    tween: Tween<double>(begin: 0.5, end: 1.0),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: primaryOrange, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.2),
                            blurRadius: 15, offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF25D366),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Berhasil Ditambahkan!",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold, fontSize: 14, color: primaryOrange,
                                  ),
                                ),
                                Text(
                                  "${_quantity}x ${widget.product.name} masuk ke keranjang.",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: textDarkBrown, fontWeight: FontWeight.w500,
                                  ),
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
                color: primaryOrange,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: textDarkBrown.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "Masukkan Keranjang  Rp ${formatPrice(totalPrice)}",
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.black87, size: size),
          ),
        ),
      ),
    );
  }
}