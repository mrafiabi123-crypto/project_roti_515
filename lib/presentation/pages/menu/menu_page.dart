import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT STATE & ENTITY ---
import '../../../presentation/state/product_provider.dart';
import '../../../presentation/state/cart_provider.dart';
import '../../../domain/entities/product.dart';
import '../../pages/cart/cart_page.dart';

// IMPORT HALAMAN DETAIL
import 'menu_detail_page.dart'; 

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Palet Warna
  final Color bgColor = const Color(0xFFFCFAF8);
  final Color primaryOrange = const Color(0xFFD47311);
  final Color textBrown = const Color(0xFF5D4037);
  final Color textDark = const Color(0xFF292524);
  final Color textGrey = const Color(0xFF78716C);

  final List<String> categories = ["Semua", "Roti", "Biskuit"];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(query: query);
    });
  }

  String formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.products;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildTopNavigationBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildCategorySection(provider),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    "Produk Kami",
                    style: GoogleFonts.pragatiNarrow(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1B140D)),
                  ),
                ),
                _buildProductGrid(provider, products),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. HEADER & ICON KERANJANG (DENGAN ANIMASI ANGKA) ---
  Widget _buildTopNavigationBar() {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(color: bgColor),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("515", style: GoogleFonts.dmSerifDisplay(fontSize: 30, color: textBrown)),
                
                // Icon Keranjang
                GestureDetector(
                  onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const CartPage()),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _circleButton(Icons.shopping_cart_outlined, Colors.white, textBrown),
                      
                      // ANIMASI ANGKA KERANJANG MUNCUL (POP UP SCALE)
                      if (cart.totalItems > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Container(
                              key: ValueKey<int>(cart.totalItems), // Kunci penting agar animasi jalan saat angka berubah
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${cart.totalItems}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFF5F5F4)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, color: primaryOrange.withOpacity(0.7), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Cari Roti Pia Susu...",
                      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFFA8A29E), fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: primaryOrange, shape: BoxShape.circle),
                  child: const Icon(Icons.tune, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. KATEGORI ---
  Widget _buildCategorySection(ProductProvider provider) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final name = categories[index];
          final String categoryValue = (name == "Semua") ? "All" : name;
          final isSelected = provider.selectedCategory == categoryValue;

          return GestureDetector(
            onTap: () => provider.setCategory(categoryValue),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: isSelected ? primaryOrange : const Color(0xFFF5F5F4)),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                style: GoogleFonts.pragatiNarrow(
                  color: isSelected ? Colors.white : const Color(0xFF57534E),
                  fontWeight: FontWeight.bold, fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 3. GRID PRODUK ---
  Widget _buildProductGrid(ProductProvider provider, List<Product> products) {
    if (provider.isLoading) return Center(child: CircularProgressIndicator(color: primaryOrange));
    if (products.isEmpty) return const Center(child: Text("Menu tidak ditemukan"));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.58, crossAxisSpacing: 15, mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductAnimation(
        index: index, child: _buildProductCard(products[index]),
      ),
    );
  }

  // --- 4. KARTU PRODUK ---
  Widget _buildProductCard(Product product) {
    String formattedPrice = formatPrice(product.price);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFF5F5F4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MenuDetailPage(product: product))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.network(product.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFEA580C), size: 10),
                        const SizedBox(width: 4),
                        Text("4.8", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFFEA580C), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border, color: Color(0xFFA8A29E), size: 14),
                  ),
                ),
                Positioned(
                  bottom: 10, right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MenuDetailPage(product: product))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(9999)),
                      child: Center(
                        child: Text("Detail", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF475569))),
                      ),
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
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                const SizedBox(height: 4),
                Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.pontanoSans(fontSize: 11, color: textGrey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rp. $formattedPrice", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                
                // TOMBOL TAMBAH KE KERANJANG
                GestureDetector(
                  onTap: () {
                    Provider.of<CartProvider>(context, listen: false).addToCart(product);
                    
                    // Sembunyikan snackbar yang lama agar tidak delay
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
                              border: Border.all(color: const Color(0xFFD47311), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFD47311).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Berhasil Ditambahkan!", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFFD47311))),
                                      Text("${product.name} masuk ke keranjang.", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF5D4037), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: Color(0xFF1C1917), shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF5F5F4))),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}

class _ProductAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  const _ProductAnimation({required this.child, required this.index});

  @override
  State<_ProductAnimation> createState() => _ProductAnimationState();
}

class _ProductAnimationState extends State<_ProductAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: widget.child);
  }
}