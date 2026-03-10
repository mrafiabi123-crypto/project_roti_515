import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../presentation/state/product_provider.dart';
import '../../../presentation/state/cart_provider.dart';
import '../../../domain/entities/product.dart';
import '../cart/cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Warna Utama Sesuai Kode HTML & Warna Roti 515
  final Color primaryOrange = const Color(0xFFD47311);
  final Color textBrown = const Color(0xFF5D4037);
  final Color bgColor = const Color(0xFFFCFAF8);
  final Color textDark = const Color(0xFF1B140D);
  final Color textGrey = const Color(0xFF57534E);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts()
    );
  }

  // PERBAIKAN: Fungsi Helper Format Harga (Menerima 'num' agar tidak error)
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
      backgroundColor: bgColor,
      body: provider.isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
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

  // --- 1. NAVBAR & SEARCH (IDENTIK DENGAN MENU PAGE) ---
  Widget _buildTopNavigationBar() {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.95),
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
                    color: textBrown,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                _buildCartIcon(cart),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Search Bar Sesuai HTML
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFF5F5F4)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, color: primaryOrange.withOpacity(0.7), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Untuk Roti Pia Susu...",
                      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFFA8A29E), fontSize: 14, fontWeight: FontWeight.w200),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: primaryOrange, shape: BoxShape.circle),
                  child: const Icon(Icons.tune, color: Colors.white, size: 14),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage())),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              border: Border.all(color: const Color(0xFFF5F5F4)),
            ),
            child: Icon(Icons.shopping_cart_outlined, color: textBrown, size: 24),
          ),
          if (cart.totalItems > 0)
            Positioned(
              right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            )
        ],
      ),
    );
  }

  // --- 2. PROMO BANNER (SESUAI HTML) ---
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 10))],
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.25),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                ),
                child: Text(
                  "Pesan Sekarang", 
                  style: GoogleFonts.plusJakartaSans(color: primaryOrange, fontWeight: FontWeight.w500, fontSize: 14)
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
            style: GoogleFonts.pragatiNarrow(fontSize: 18, color: textDark, fontWeight: FontWeight.normal),
          ),
          if (showArrows)
            Row(
              children: [
                _buildSmallArrow(Icons.chevron_left),
                const SizedBox(width: 4),
                _buildSmallArrow(Icons.chevron_right),
              ],
            )
          else
            Text("Lihat", style: GoogleFonts.plusJakartaSans(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSmallArrow(IconData icon) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
      ),
      child: Icon(icon, size: 20, color: textDark),
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

  Widget _buildBestsellerCard(Product product) {
    return Container(
      width: 192,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFF5F5F4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
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
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFEA580C), size: 10),
                        const SizedBox(width: 4),
                        Text("4.8", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w200, color: const Color(0xFFEA580C))),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1B140D)), maxLines: 1),
                Text(product.description, style: GoogleFonts.pontanoSans(fontSize: 12, color: textGrey, fontWeight: FontWeight.bold), maxLines: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rp. ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(color: Color(0xFF1C1917), shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
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

  // --- 5. MENU BARU LIST (HORIZONTAL SCROLL LIST TILE) ---
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

  Widget _buildNewMenuCard(Product product) {
    return Container(
      width: 285,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFF5F5F4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
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
                Text(product.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF292524)), maxLines: 1),
                Text(product.description, style: GoogleFonts.pontanoSans(fontSize: 12, color: const Color(0xFF78716C), fontWeight: FontWeight.w500), maxLines: 1),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rp. ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 16, color: Color(0xFF1C1917)),
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