import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/admin_product_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/utils/premium_snackbar.dart';
//  Import halaman tambah produk
import 'add_product_screen.dart';
import '../../profile/screens/admin_profile_screen.dart';
import 'package:roti_515/core/theme/theme_provider.dart';
import 'package:roti_515/core/theme/app_theme.dart';
import 'package:roti_515/core/network/api_service.dart';

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
      backgroundColor: context.colors.bgColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(context),
          ),
          SizedBox(height: 16),
          _buildFilterTabs(context, provider),
          SizedBox(height: 16),
          Expanded(
            child: _buildBodyContent(context, provider),
          ),
        ],
      ),
      // --- 🔘 FLOATING ACTION BUTTON (DIPERBAIKI POSISINYA) ---
      floatingActionButton: Padding(
        // Berikan jarak bawah sekitar 90-100 agar tombol naik di atas navbar
        padding: EdgeInsets.only(bottom: 90), 
        child: FloatingActionButton(
          backgroundColor: context.colors.primaryOrange,
          elevation: 6,
          onPressed: () {
            // ✅ Navigasi ke Halaman Tambah Produk
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddProductScreen()),
            );
          },
          child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildBodyContent(BuildContext context, AdminProductProvider provider) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: context.colors.primaryOrange));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: context.colors.textHint),
            SizedBox(height: 16),
            Text(provider.errorMessage!, style: GoogleFonts.plusJakartaSans(color: context.colors.textGrey), textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchProducts(),
              style: ElevatedButton.styleFrom(backgroundColor: context.colors.primaryOrange, shape: StadiumBorder()),
              child: Text("Coba Lagi", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }

    final products = provider.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Text("Tidak ada produk ditemukan.", style: GoogleFonts.plusJakartaSans(color: context.colors.textGrey)),
      );
    }

    return RefreshIndicator(
      color: context.colors.primaryOrange,
      onRefresh: () => provider.fetchProducts(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 120), // Tambahkan padding bawah agar list tidak tertutup navbar
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          
          final String name = product["name"] ?? "Tanpa Nama";
          final String priceStr = (product["price"] ?? 0).toString();
          final int stock = product["stock"] ?? 0;
          
          final String imageUrl = (product["image_url"] != null && product["image_url"].toString().isNotEmpty)
              ? product["image_url"] 
              : "https://via.placeholder.com/150"; 
          
          return _buildProductCard(context, 
            name: name,
            price: "Rp $priceStr",
            stock: stock,
            imageUrl: imageUrl,
            onQuickRestock: () => _showQuickRestockDialog(context, product),
            onEdit: () {
              Navigator.push(context,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.bgColor.withValues(alpha: 0.9),
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: context.colors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.bakery_dining_rounded, color: context.colors.primaryOrange, size: 22),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("roti515", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textDark)),
              Text("Portal Admin", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.primaryOrange)),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, theme, _) => IconButton(
            icon: Icon(
              theme.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: context.colors.textDark,
            ),
            onPressed: () => theme.toggleTheme(!theme.isDarkMode),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => AdminProfileScreen()),
              );
            },
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final photoUrl = auth.photoUrl;
                final fullImageUrl = ApiService.getDisplayImage(photoUrl);

                return CircleAvatar(
                  backgroundColor: context.colors.primaryOrange.withValues(alpha: 0.1),
                  backgroundImage: fullImageUrl.isNotEmpty
                      ? NetworkImage(fullImageUrl)
                      : null,
                  child: fullImageUrl.isEmpty
                      ? Icon(Icons.account_circle_outlined, color: context.colors.primaryOrange)
                      : null,
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: context.colors.primaryOrange.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: context.colors.textDark),
        decoration: InputDecoration(
          hintText: "Cari Produk",
          hintStyle: GoogleFonts.plusJakartaSans(color: context.colors.textHint, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: context.colors.primaryOrange, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, AdminProductProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.primaryOrange.withValues(alpha: 0.1)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem(context, "Semua Produk", 0, provider),
          _buildTabItem(context, "Stok Habis", 1, provider),
          _buildTabItem(context, "Stok Menipis", 2, provider),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String title, int index, AdminProductProvider provider) {
    bool isActive = provider.selectedTab == index;
    return GestureDetector(
      onTap: () => provider.setTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? context.colors.primaryOrange : Colors.transparent, width: 3)),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.bold,
            color: isActive ? context.colors.primaryOrange : context.colors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, {
    required String name, required String price, required int stock, required String imageUrl,
    required VoidCallback onEdit, required VoidCallback onDelete, VoidCallback? onQuickRestock,
  }) {
    Color stockBgColor = stock == 0 ? Color(0xFFFEE2E2) : stock <= 15 ? Color(0xFFFFEDD5) : Color(0xFFDCFCE7);
    Color stockTextColor = stock == 0 ? Color(0xFFB91C1C) : stock <= 15 ? Color(0xFFC2410C) : Color(0xFF15803D);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.primaryOrange.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl, width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 80, height: 80, color: context.colors.divider, 
                child: Icon(Icons.image_not_supported_rounded, color: context.colors.textGrey)
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.primaryOrange)),
                SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Stok: ", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.colors.textGrey)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: stockBgColor, borderRadius: BorderRadius.circular(9999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (stock > 0 && stock <= 15)
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.warning_amber_rounded, size: 12, color: stockTextColor),
                                ),
                              Text("$stock", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: stockTextColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (stock <= 15 && onQuickRestock != null) ...[
                _buildActionButton(context, Icons.add_shopping_cart_rounded, context.colors.primaryOrange, onQuickRestock),
                SizedBox(width: 8),
              ],
              _buildActionButton(context, Icons.edit_rounded, Color(0xFF16A34A), onEdit),
              SizedBox(width: 8),
              _buildActionButton(context, Icons.delete_outline_rounded, Color(0xFFEF4444), onDelete),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text("Hapus Produk?", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: context.colors.textDark)),
        content: Text("Apakah Anda yakin ingin menghapus ${product['name']}? Tindakan ini tidak dapat dibatalkan.", style: GoogleFonts.plusJakartaSans(color: context.colors.textDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.plusJakartaSans(color: context.colors.textGrey)),
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
            child: Text("Hapus", style: GoogleFonts.plusJakartaSans(color: context.colors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showQuickRestockDialog(BuildContext context, Map<String, dynamic> product) {
    final TextEditingController stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text("Tambah Stok ${product['name']}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: context.colors.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Masukkan jumlah stok yang ditambahkan:", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: context.colors.textDark)),
            SizedBox(height: 12),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(color: context.colors.textDark),
              decoration: InputDecoration(
                hintText: "Contoh: 10",
                hintStyle: GoogleFonts.plusJakartaSans(color: context.colors.textHint),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.primaryOrange)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ctx),
            child: Text("Batal", style: GoogleFonts.plusJakartaSans(color: context.colors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final int addedStock = int.tryParse(stockController.text) ?? 0;
              if (addedStock <= 0) {
                PremiumSnackbar.showError(ctx, "Masukkan jumlah stok yang valid");
                return;
              }

              Navigator.pop(context, ctx);
              final provider = Provider.of<AdminProductProvider>(context, listen: false);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final int newStock = (product['stock'] ?? 0) + addedStock;

              bool success = await provider.updateProduct(
                id: product['id'],
                name: product['name'],
                category: product['category'] ?? "Lainnya",
                price: product['price'],
                stock: newStock,
                token: auth.token ?? '',
                imageUrl: product['image_url'],
              );

              if (mounted) {
                if (success) {
                  PremiumSnackbar.showSuccess(context, "Stok berhasil ditambahkan");
                } else {
                  PremiumSnackbar.showError(context, "Gagal menambah stok");
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.primaryOrange),
            child: Text("Simpan", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}