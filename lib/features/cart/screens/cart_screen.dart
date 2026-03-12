import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';

// --- IMPORT PROVIDER & SCREEN ---
import '../providers/cart_provider.dart';
// (Import Checkout sementara masih mengarah ke folder lama, tidak apa-apa)
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Helper Format Harga
  String formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(context),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyState(context);
          }

          // --- LOGIKA HITUNGAN (SINKRON DENGAN CHECKOUT) ---
          final int subtotal = cart.totalPrice;
          final int deliveryFee = 0; // Gratis karena Ambil Di Toko
          final int total = subtotal + deliveryFee; // Pajak dihapus

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, item, index, cart);
                  },
                ),
              ),
              _buildSummaryAndAction(context, cart, subtotal, deliveryFee, total),
            ],
          );
        },
      ),
    );
  }

  // --- 1. APP BAR ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgColor.withOpacity(0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        "Keranjang",
        style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, _) => TextButton(
            onPressed: () => cart.clearCart(),
            child: Text(
              "Hapus Semua",
              style: GoogleFonts.plusJakartaSans(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- 2. ITEM KARTU KERANJANG ---
  Widget _buildCartItem(BuildContext context, dynamic item, int index, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          // Gambar Produk
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.network(
              item.product.imageUrl.isNotEmpty ? item.product.imageUrl : "https://placehold.co/88x88",
              width: 88, height: 88,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Info Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeItem(index),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.textHint, size: 20),
                    )
                  ],
                ),
                Text(
                  item.product.description.isNotEmpty ? item.product.description : "Roti hangat dari oven",
                  style: GoogleFonts.pontanoSans(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${formatPrice(item.product.price)}",
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryOrange),
                    ),
                    // Quantity Selector (Horizontal Pill Style)
                    _buildQtySelector(cart, index, item.quantity),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQtySelector(CartProvider cart, int index, int quantity) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Agar tidak terlalu melebar
        children: [
          _qtyCircleBtn(Icons.remove_rounded, AppColors.white, AppColors.textDark, () => cart.decreaseQuantity(index)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "$quantity",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark),
            ),
          ),
          _qtyCircleBtn(Icons.add_rounded, AppColors.primaryOrange, AppColors.white, () => cart.increaseQuantity(index), hasShadow: true),
        ],
      ),
    );
  }

  Widget _qtyCircleBtn(IconData icon, Color bg, Color iconCol, VoidCallback onTap, {bool hasShadow = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: hasShadow ? [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Icon(icon, size: 14, color: iconCol),
      ),
    );
  }

  // --- 3. SUMMARY & BOTTOM ACTION ---
  Widget _buildSummaryAndAction(BuildContext context, CartProvider cart, int subtotal, int delivery, int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, -8))],
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ringkasan Pesanan
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Ringkasan Pesanan", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
          const SizedBox(height: 16),
          _summaryRow("Subtotal", "Rp ${formatPrice(subtotal)}"),
          const SizedBox(height: 8),
          _summaryRow("Biaya Layanan", delivery == 0 ? "Gratis" : "Rp ${formatPrice(delivery)}"),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: AppColors.divider)),
          
          // Total Harga & Tombol Checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Harga", style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w500)),
              Text("Rp ${formatPrice(total)}", style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              elevation: 4,
              shadowColor: AppColors.primaryOrange.withOpacity(0.4),
            ),
            child: Text(
              "Lanjutkan ke Pembayaran",
              style: GoogleFonts.plusJakartaSans(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey, fontSize: 14)),
          Text(value, style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.divider),
          const SizedBox(height: 20),
          Text("Keranjangmu masih kosong", style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey, fontSize: 16)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange, 
              shape: const StadiumBorder(),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Mulai Belanja", style: GoogleFonts.plusJakartaSans(color: AppColors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}