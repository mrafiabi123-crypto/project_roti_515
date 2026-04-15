import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/admin_product_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/utils/premium_snackbar.dart';
//  Import halaman tambah produk
import 'add_product_screen.dart';

class ProductAdminScreen extends StatefulWidget {
  const ProductAdminScreen({super.key});

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProductProvider>(context, listen: false).fetchProducts();
    });

    _searchController.addListener(() {
      Provider.of<AdminProductProvider>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 16),
          _buildFilterTabs(provider),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBodyContent(provider),
          ),
        ],
      ),
      // --- 🔘 FLOATING ACTION BUTTON (DIPERBAIKI POSISINYA) ---
      floatingActionButton: Padding(
        // Berikan jarak bawah sekitar 90-100 agar tombol naik di atas navbar
        padding: const EdgeInsets.only(bottom: 90), 
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryOrange,
          elevation: 6,
          onPressed: () {
            // ✅ Navigasi ke Halaman Tambah Produk
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            );
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildBodyContent(AdminProductProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(provider.errorMessage!, style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchProducts(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange, shape: const StadiumBorder()),
              child: Text("Coba Lagi", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }

    final products = provider.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Text("Tidak ada produk ditemukan.", style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey)),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryOrange,
      onRefresh: () => provider.fetchProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), // Tambahkan padding bawah agar list tidak tertutup navbar
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          
          final String name = product["name"] ?? "Tanpa Nama";
          final String priceStr = (product["price"] ?? 0).toString();
          final int stock = product["stock"] ?? 0;
          
          final String imageUrl = (product["image_url"] != null && product["image_url"].toString().isNotEmpty)
              ? product["image_url"] 
              : "https://via.placeholder.com/150"; 

          return _buildProductCard(
            name: name,
            price: "Rp $priceStr",
            stock: stock,
            imageUrl: imageUrl,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(initialProduct: product),
                ),
              );
            },
            onDelete: () => _confirmDelete(context, product),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgColor.withValues(alpha: 0.9),
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryOrange, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("roti515", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text("Portal Admin", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryOrange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Cari Produk",
          hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryOrange, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(AdminProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.primaryOrange.withValues(alpha: 0.1)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem("Semua Produk", 0, provider),
          _buildTabItem("Stok Habis", 1, provider),
          _buildTabItem("Stok Menipis", 2, provider),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, AdminProductProvider provider) {
    bool isActive = provider.selectedTab == index;
    return GestureDetector(
      onTap: () => provider.setTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? AppColors.primaryOrange : Colors.transparent, width: 3)),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primaryOrange : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String name, required String price, required int stock, required String imageUrl,
    required VoidCallback onEdit, required VoidCallback onDelete,
  }) {
    Color stockBgColor = stock == 0 ? const Color(0xFFFEE2E2) : stock <= 15 ? const Color(0xFFFFEDD5) : const Color(0xFFDCFCE7);
    Color stockTextColor = stock == 0 ? const Color(0xFFB91C1C) : stock <= 15 ? const Color(0xFFC2410C) : const Color(0xFF15803D);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl, width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 80, height: 80, color: Colors.grey[200], 
                child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey)
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryOrange)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text("Stok: ", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: stockBgColor, borderRadius: BorderRadius.circular(9999)),
                      child: Text("$stock unit", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: stockTextColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(Icons.edit_rounded, const Color(0xFF16A34A), onEdit),
              const SizedBox(width: 8),
              _buildActionButton(Icons.delete_outline_rounded, const Color(0xFFEF4444), onDelete),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Produk?", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus ${product['name']}? Tindakan ini tidak dapat dibatalkan.", style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<AdminProductProvider>(context, listen: false);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final token = auth.token ?? '';
              
              bool success = await provider.deleteProduct(product['id'], token);
              if (mounted) {
                if (success) {
                  PremiumSnackbar.showSuccess(context, "Produk berhasil dihapus");
                } else {
                  PremiumSnackbar.showError(context, "Gagal menghapus produk: ${provider.errorMessage}");
                }
              }
            },
            child: Text("Hapus", style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}