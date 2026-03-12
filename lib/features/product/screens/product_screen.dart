import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';

// --- IMPORT PROVIDER & MODEL LOKAL ---
import '../providers/product_provider.dart';
import '../models/product_model.dart'; 
import 'product_detail_screen.dart'; 

// --- IMPORT FITUR LAIN ---
import '../../cart/providers/cart_provider.dart';
import '../../favorite/providers/favorite_provider.dart'; 
import '../../cart/screens/cart_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
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
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          _buildTopNavigationBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildCategorySection(provider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    "Produk Kami",
                    style: GoogleFonts.pragatiNarrow(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
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

  Widget _buildTopNavigationBar() {
    final cart = Provider.of<CartProvider>(context);
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      color: AppColors.bgColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("515", style: GoogleFonts.dmSerifDisplay(fontSize: 30, color: AppColors.textBrown)),
                _buildCartIcon(cart),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildCartIcon(CartProvider cart) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.divider)),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textBrown, size: 22),
          ),
          if (cart.totalItems > 0)
            Positioned(
              right: -2, top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text('${cart.totalItems}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: AppColors.primaryOrange.withOpacity(0.7), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Cari Roti Pia Susu...",
                hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(radius: 16, backgroundColor: AppColors.primaryOrange, child: Icon(Icons.tune, color: AppColors.white, size: 14)),
          )
        ],
      ),
    );
  }

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
                color: isSelected ? AppColors.primaryOrange : AppColors.white,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: isSelected ? AppColors.primaryOrange : AppColors.divider),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? AppColors.white : AppColors.textGrey,
                  fontWeight: FontWeight.bold, fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider provider, List<ProductModel> products) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        childAspectRatio: 0.72, // ✅ Kunci Agar Kotak Tidak Gepeng
        crossAxisSpacing: 15, 
        mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductAnimation(
        index: index, child: _buildProductCard(products[index]),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final bool isFav = favProvider.isFavorite(product);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(32), // ✅ Identik dengan Home
            border: Border.all(color: AppColors.divider),
            boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk
              Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          product.imageUrl, 
                          height: 130, // ✅ Tinggi Gambar Tetap (Pas)
                          width: double.infinity, 
                          fit: BoxFit.cover // ✅ Memotong Gambar Tanpa Gepeng
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: _buildBadge("${product.rating}"),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: _HeartAnimation(isFavorite: isFav, onTap: () => favProvider.toggleFavorite(product)),
                    ),
                  ],
                ),
              ),
              // Info Teks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textGrey)),
                  ],
                ),
              ),
              const Spacer(), // Menjaga Harga di Bawah Namun dalam Rasio yang Pas
              // Harga & Button
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rp ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
                    _buildAddButton(context, product),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: AppColors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.primaryOrange, size: 12),
          const SizedBox(width: 2),
          Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () {
        Provider.of<CartProvider>(context, listen: false).addToCart(product);
        _showSuccessSnackBar(context, product.name);
      },
      child: Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: AppColors.textDark, shape: BoxShape.circle),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 18),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String productName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0, behavior: SnackBarBehavior.floating, backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryOrange)),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text("$productName ditambahkan!", style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Animasi Heart (Love)
class _HeartAnimation extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const _HeartAnimation({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: AppColors.white.withOpacity(0.9), shape: BoxShape.circle),
        child: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: isFavorite ? AppColors.error : AppColors.textHint, size: 16),
      ),
    );
  }
}

// Animasi Fade-In
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    Future.delayed(Duration(milliseconds: widget.index * 40), () {
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