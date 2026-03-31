import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(context),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const CartEmptyState();
          }

          final int subtotal = cart.totalPrice;
          const int deliveryFee = 0; // Gratis, Ambil Di Toko
          final int total = subtotal + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) => CartItemCard(
                    item: cart.items[index],
                    index: index,
                  ),
                ),
              ),
              CartSummaryBar(
                subtotal: subtotal,
                deliveryFee: deliveryFee,
                total: total,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgColor.withOpacity(0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        "Keranjang",
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, _) => TextButton(
            onPressed: () => cart.clearCart(),
            child: Text(
              "Hapus Semua",
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}