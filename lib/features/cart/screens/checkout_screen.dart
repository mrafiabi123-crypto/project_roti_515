import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';

// --- IMPORT PROVIDER LOKAL ---
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isOrdering = false;

  // Warna Khusus Brand (Selain AppColors)
  final Color whatsappGreen = const Color(0xFF25D366);

  // Helper Format Harga
  String formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
  }

  // --- FUNGSI API ---
  Future<void> _placeOrder() async {
    setState(() => _isOrdering = true);
    final cart = Provider.of<CartProvider>(context, listen: false);

    int subtotal = cart.totalPrice;
    int deliveryFee = 0; 
    int finalTotal = subtotal + deliveryFee;

    try {
      final orderData = {
        "guest_name": "Pelanggan Toko", 
        "guest_phone": "-",
        "guest_address": "Ambil Di Toko",
        "total": finalTotal.toDouble(), 
        "items": cart.items.map((item) => {
          "product_id": item.product.id,
          "quantity": item.quantity,
          "price": item.product.price.toDouble()
        }).toList()
      };

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8080/api/orders'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        cart.clearCart();
        if (mounted) _showSuccessDialog();
      } else {
        throw Exception("Gagal membuat pesanan (Error: ${response.statusCode}).");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e", style: GoogleFonts.plusJakartaSans(color: AppColors.white)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  // --- FUNGSI DIALOG ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(child: FaIcon(FontAwesomeIcons.whatsapp, color: whatsappGreen, size: 80)),
        content: Text(
          "Pesanan Berhasil!\nTerima kasih telah memesan di Roti 515.",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                elevation: 0,
              ),
              child: Text("Kembali ke Menu", style: GoogleFonts.plusJakartaSans(color: AppColors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final int deliveryFee = 0; 

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 220), 
            child: Column(
              children: [
                _buildStepper(),
                _buildDeliveryOption(),
                _buildWhatsAppInfoCard(),
                _buildOrderSummary(cart, deliveryFee),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStickyBottom(cart, deliveryFee),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgColor.withOpacity(0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 70,
      leading: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle), // Colors.transparent dihapus karena default container tanpa warna adalah transparan
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          ),
        ),
      ),
      centerTitle: true,
      title: Text("Checkout", style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.divider, height: 1),
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepItem("1", "Pilih Produk"),
          _stepLine(),
          _stepItem("2", "Total Harga"),
          _stepLine(),
          _stepItem("3", "Konfirmasi"),
        ],
      ),
    );
  }

  Widget _stepItem(String num, String label) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primaryOrange.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]),
          child: Center(child: Text(num, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14))),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.pontanoSans(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 2, margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: AppColors.primaryOrange.withOpacity(0.3), borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  Widget _buildDeliveryOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.divider), 
          boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.02), blurRadius: 4)], // Colors.black diganti AppColors.textDark
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.storefront_rounded, color: AppColors.textGrey, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ambil Di Toko", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  Text("Tersedia dalam 15 menit", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textBrown)),
                ],
              ),
            ),
            Text("Gratis", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 16)),
            const SizedBox(width: 12),
            Container(
              width: 20, height: 20, 
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryOrange, width: 6)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text("Konfirmasi", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFFDCFCE7))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: whatsappGreen.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: FaIcon(FontAwesomeIcons.whatsapp, color: whatsappGreen, size: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order via WhatsApp", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(
                        "Rincian pesanan Anda akan kami proses dan kami akan menghubungi Anda.",
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textBrown, height: 1.5),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart, int deliveryFee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text("Ringkasan Pesanan", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 2)], // Colors.black diganti AppColors.textDark
            ),
            child: Column(
              children: [
                ...cart.items.map((item) => _buildSummaryItem(item.product, item.quantity)),
                Container(margin: const EdgeInsets.symmetric(vertical: 16), height: 1, color: AppColors.divider),
                _summaryRow("Subtotal", "Rp ${formatPrice(cart.totalPrice)}"),
                const SizedBox(height: 8),
                _summaryRow("Biaya Pengiriman", deliveryFee == 0 ? "Gratis" : "Rp ${formatPrice(deliveryFee)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(dynamic product, int qty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24), 
            child: Image.network(product.imageUrl.isNotEmpty ? product.imageUrl : "https://placehold.co/64x64", width: 64, height: 64, fit: BoxFit.cover)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(product.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis)
                    ),
                    Text("Rp ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                  ],
                ),
                Text(product.description.isNotEmpty ? product.description : "Roti 515", style: GoogleFonts.pontanoSans(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("Jumlah : $qty", style: GoogleFonts.pontanoSans(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: AppColors.textBrown, fontSize: 14)),
        Text(value, style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildStickyBottom(CartProvider cart, int deliveryFee) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))], // Colors.black diganti AppColors.textDark
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Harga", style: GoogleFonts.plusJakartaSans(color: AppColors.textBrown, fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                "Rp ${formatPrice(cart.totalPrice + deliveryFee)}",
                style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isOrdering ? null : _placeOrder,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: whatsappGreen,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(color: whatsappGreen.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 4)),
                  BoxShadow(color: whatsappGreen.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 10)),
                ],
              ),
              child: Center(
                child: _isOrdering 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.white, size: 21),
                      const SizedBox(width: 12),
                      Text(
                        "Order via WhatsApp",
                        style: GoogleFonts.plusJakartaSans(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Dengan mengklik tombol ini, detail pesanan Anda akan diproses di sistem.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}