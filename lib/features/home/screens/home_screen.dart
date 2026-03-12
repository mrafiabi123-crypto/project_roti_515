import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';

// --- IMPORT PROVIDER & MODEL LOKAL ---
import '../../product/providers/product_provider.dart';
import '../../product/models/product_model.dart'; // Ganti dari domain/entities
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts()
    );
  }

  // Fungsi Helper Format Harga
  String formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: provider.isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopNavigationBar(),
                  const SizedBox(height: 10),
                  _buildPromoBanner(),
                  const SizedBox(height: 32),

                  // --- SECTION BESTSELLERS ---
                  _buildSectionHeader("Bestsellers", true),
                  const SizedBox(height: 16),
                  _buildBestsellerList(provider),

                  const SizedBox(height: 32),

                  // --- SECTION MENU BARU ---
                  _buildSectionHeader("Menu Baru", false),
                  const SizedBox(height: 16),
                  _buildNewMenuList(provider),
                ],
              ),
            ),
    );
  }

  // --- 1. NAVBAR & SEARCH ---
  Widget _buildTopNavigationBar() {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.bgColor.withOpacity(0.95),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "515",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 30,
                    color: AppColors.textBrown,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                _buildCartIcon(cart),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 2)],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded, color: AppColors.primaryOrange.withOpacity(0.7), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Roti Pia Susu...",
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 14, fontWeight: FontWeight.w300),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                  child: const Icon(Icons.tune_rounded, color: AppColors.white, size: 14),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCartIcon(CartProvider cart) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 10)],
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textBrown, size: 24),
          ),
          if (cart.totalItems > 0)
            Positioned(
              right: 8, top: 8,
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
    );
  }

  // --- 2. PROMO BANNER ---
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 10))],
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [AppColors.textDark.withOpacity(0.8), Colors.transparent],
              begin: Alignment.centerLeft,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 320,
                child: Text(
                  "\"Roti 515: Hangat dari oven, hadir untuk harimu.\"",
                  style: GoogleFonts.plusJakartaSans(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.25),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.1), blurRadius: 4)],
                ),
                child: Text(
                  "Pesan Sekarang", 
                  style: GoogleFonts.plusJakartaSans(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 14)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. SECTION HEADER ---
  Widget _buildSectionHeader(String title, bool showArrows) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.pragatiNarrow(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
          if (showArrows)
            Row(
              children: [
                _buildSmallArrow(Icons.chevron_left_rounded),
                const SizedBox(width: 4),
                _buildSmallArrow(Icons.chevron_right_rounded),
              ],
            )
          else
            Text("Lihat Semua", style: GoogleFonts.plusJakartaSans(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSmallArrow(IconData icon) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 2)],
        border: Border.all(color: AppColors.divider),
      ),
      child: Icon(icon, size: 20, color: AppColors.textDark),
    );
  }

  // --- 4. BESTSELLER LIST ---
  Widget _buildBestsellerList(ProductProvider provider) {
    final list = provider.bestsellers;
    return SizedBox(
      height: 277,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildBestsellerCard(list[index]),
      ),
    );
  }

  Widget _buildBestsellerCard(ProductModel product) {
    return Container(
      width: 192,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(product.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primaryOrange, size: 10),
                        const SizedBox(width: 4),
                        Text("${product.rating}", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: AppColors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border_rounded, color: AppColors.textHint, size: 14),
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
                Text(product.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product.description, style: GoogleFonts.pontanoSans(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rp ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(color: AppColors.textDark, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: AppColors.white, size: 16),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 5. MENU BARU LIST ---
  Widget _buildNewMenuList(ProductProvider provider) {
    final list = provider.newMenus;
    return SizedBox(
      height: 106,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildNewMenuCard(list[index]),
      ),
    );
  }

  Widget _buildNewMenuCard(ProductModel product) {
    return Container(
      width: 285,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 2)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.network(product.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product.description, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rp ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                    Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: AppColors.divider, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, size: 16, color: AppColors.textDark),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}