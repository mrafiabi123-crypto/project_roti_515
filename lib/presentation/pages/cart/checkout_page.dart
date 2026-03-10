import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- IMPORT STATE & PROVIDER ---
import '../../../presentation/state/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isOrdering = false;

  // Warna Tema Disesuaikan dengan Desain
  final Color bgColor = const Color(0xFFFCFAF8);
  final Color primaryOrange = const Color(0xFFD47311);
  final Color textDark = const Color(0xFF1B140D);
  final Color textBrown = const Color(0xFF9A734C);
  final Color whatsappGreen = const Color(0xFF25D366);
  final Color borderGrey = const Color(0xFFF3F4F6);

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

    // LOGIKA HARGA (Sesuai dengan Cart)
    int subtotal = cart.totalPrice;
    int deliveryFee = 0; // 0 karena "Ambil Di Toko" (Gratis)
    int finalTotal = subtotal + deliveryFee;

    try {
      final orderData = {
        // Karena form dihapus, kita kirim data default ke backend agar tidak error
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

      // URL API Localhost Chrome
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8080/api/orders'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        cart.clearCart();
        if (mounted) _showSuccessDialog();
      } else {
        throw Exception("Gagal membuat pesanan.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(child: FaIcon(FontAwesomeIcons.whatsapp, color: whatsappGreen, size: 80)),
        content: Text(
          "Pesanan Berhasil!\nTerima kasih telah memesan di Roti 515.",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text("Kembali ke Menu", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final int deliveryFee = 0; // Ambil di toko = Gratis

    return Scaffold(
      backgroundColor: bgColor,
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
      backgroundColor: bgColor.withOpacity(0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 70,
      leading: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          ),
        ),
      ),
      centerTitle: true,
      title: Text("Checkout", style: GoogleFonts.plusJakartaSans(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: borderGrey, height: 1),
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
          decoration: BoxDecoration(color: primaryOrange, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]),
          child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.pontanoSans(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 2, margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: primaryOrange.withOpacity(0.3), borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  Widget _buildDeliveryOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(32),
          border: Border.all(color: borderGrey), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
              child: const Icon(Icons.storefront, color: Color(0xFF6B7280), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ambil Di Toko", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                  Text("Tersedia dalam 15 menit", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textBrown)),
                ],
              ),
            ),
            Text("Gratis", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF16A34A), fontSize: 16)),
            const SizedBox(width: 12),
            Container(
              width: 20, height: 20, 
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryOrange, width: 6)),
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
            child: Text("Konfirmasi", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
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
                      Text("Order via WhatsApp", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                      const SizedBox(height: 4),
                      Text(
                        "Rincian pesanan Anda akan kami proses dan kami akan menghubungi Anda.",
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textBrown, height: 1.5),
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
            child: Text("Ringkasan Pesanan", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: borderGrey),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
            ),
            child: Column(
              children: [
                ...cart.items.map((item) => _buildSummaryItem(item.product, item.quantity)),
                Container(margin: const EdgeInsets.symmetric(vertical: 16), height: 1, color: borderGrey),
                _summaryRow("Subtotal", "Rp. ${formatPrice(cart.totalPrice)}"),
                const SizedBox(height: 8),
                _summaryRow("Biaya Pengiriman", deliveryFee == 0 ? "Gratis" : "Rp. ${formatPrice(deliveryFee)}"),
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
          ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(product.imageUrl, width: 64, height: 64, fit: BoxFit.cover)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(product.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: textDark), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text("Rp. ${formatPrice(product.price)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                  ],
                ),
                Text(product.description ?? "", style: GoogleFonts.pontanoSans(fontSize: 12, color: const Color(0xFF78716C), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text("Jumlah : $qty", style: GoogleFonts.pontanoSans(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.w600)),
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
        Text(label, style: GoogleFonts.plusJakartaSans(color: textBrown, fontSize: 14)),
        Text(value, style: GoogleFonts.plusJakartaSans(color: textDark, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildStickyBottom(CartProvider cart, int deliveryFee) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        border: Border(top: BorderSide(color: borderGrey)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Harga", style: GoogleFonts.plusJakartaSans(color: textBrown, fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                "Rp. ${formatPrice(cart.totalPrice + deliveryFee)}",
                style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: textDark),
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
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 21),
                      const SizedBox(width: 12),
                      Text(
                        "Order via WhatsApp",
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Dengan mengklik tombol ini, detail pesanan Anda akan dikirim ke WhatsApp resmi kami untuk konfirmasi.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: textBrown.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}