import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/checkout_widgets.dart';
import '../../../core/network/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isOrdering = false;
  static const int _deliveryFee = 0;
  String _guestAddress = "Ambil Di Toko";

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  Future<void> _fetchUserAddress() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null || auth.token!.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(ApiService.profile),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${auth.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted && data['user'] != null && data['user']['address'] != null && data['user']['address'].isNotEmpty) {
          setState(() {
            _guestAddress = data['user']['address'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
    }
  }

  // --- LOGIKA UTAMA ---

  Future<void> _placeOrder() async {
    setState(() => _isOrdering = true);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final int finalTotal = cart.totalPrice + _deliveryFee;

    try {
      final orderData = {
        "guest_name": "Pelanggan Toko",
        "guest_phone": "-",
        "guest_address": _guestAddress,
        "total": finalTotal.toDouble(),
        "items": cart.items
            .map((item) => {
                  "product_id": item.product.id,
                  "quantity": item.quantity,
                  "price": item.product.price.toDouble(),
                })
            .toList(),
      };

      final auth = Provider.of<AuthProvider>(context, listen: false);

      final response = await http.post(
        Uri.parse(ApiService.orders),
        headers: {
          "Content-Type": "application/json",
          if (auth.token != null && auth.token!.isNotEmpty)
            "Authorization": "Bearer ${auth.token}",
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        // Generasi kode pesanan unik (Contoh: ORD-X7A1)
        final String timestampStr = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
        final String randomStr = timestampStr.substring(timestampStr.length.clamp(4, 99) - 4);
        final String orderCode = 'ORD-$randomStr';

        cart.clearCart();
        if (!context.mounted) return;
        final currentContext = context;
        Navigator.pushNamedAndRemoveUntil(
          currentContext,
          AppRoutes.checkoutSuccess,
          (route) => false,
          arguments: orderCode, // Kirim kode real dari backend
        );
      } else {
        throw Exception(
            "Gagal membuat pesanan (Error: ${response.statusCode}).");
      }
    } catch (e) {
      if (!context.mounted) return;
      final currentContext = context;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text("Error: $e",
              style: GoogleFonts.plusJakartaSans(color: AppColors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CheckoutStepper(),
                const CheckoutDeliveryOption(),
                const CheckoutConfirmationCard(),
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
      backgroundColor: AppColors.bgColor.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 60,
      leading: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark, size: 18),
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        'Checkout',
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          height: 22.5 / 18,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF3F4F6), height: 1),
      ),
    );
  }
}