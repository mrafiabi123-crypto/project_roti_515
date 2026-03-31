import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../widgets/checkout_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isOrdering = false;
  static const int _deliveryFee = 0;

  // --- LOGIKA UTAMA ---

  Future<void> _placeOrder() async {
    setState(() => _isOrdering = true);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final int finalTotal = cart.totalPrice + _deliveryFee;

    try {
      final orderData = {
        "guest_name": "Pelanggan Toko",
        "guest_phone": "-",
        "guest_address": "Ambil Di Toko",
        "total": finalTotal.toDouble(),
        "items": cart.items
            .map((item) => {
                  "product_id": item.product.id,
                  "quantity": item.quantity,
                  "price": item.product.price.toDouble(),
                })
            .toList(),
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
        throw Exception(
            "Gagal membuat pesanan (Error: ${response.statusCode}).");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e",
                style: GoogleFonts.plusJakartaSans(color: AppColors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(
            child: FaIcon(FontAwesomeIcons.whatsapp,
                color: Color(0xFF25D366), size: 80)),
        content: Text(
          "Pesanan Berhasil!\nTerima kasih telah memesan di Roti 515.",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
                elevation: 0,
              ),
              child: Text(
                "Kembali ke Menu",
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 220),
            child: Column(
              children: [
                const CheckoutStepper(),
                const CheckoutDeliveryOption(),
                const CheckoutWhatsAppCard(),
                CheckoutOrderSummary(cart: cart, deliveryFee: _deliveryFee),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CheckoutStickyBottom(
              cart: cart,
              deliveryFee: _deliveryFee,
              isOrdering: _isOrdering,
              onOrder: _placeOrder,
            ),
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
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark, size: 20),
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        "Checkout",
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.divider, height: 1),
      ),
    );
  }
}