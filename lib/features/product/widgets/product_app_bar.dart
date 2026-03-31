import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';

class ProductAppBar extends StatefulWidget {
  final void Function(String query) onSearchChanged;

  const ProductAppBar({super.key, required this.onSearchChanged});

  @override
  State<ProductAppBar> createState() => _ProductAppBarState();
}

class _ProductAppBarState extends State<ProductAppBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      color: AppColors.bgColor,
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
                  ),
                ),
                _ProductCartIcon(cart: cart),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _ProductSearchBar(
            controller: _searchController,
            onChanged: _onChanged,
          ),
        ],
      ),
    );
  }
}

// ----- Cart Icon -----

class _ProductCartIcon extends StatelessWidget {
  final CartProvider cart;
  const _ProductCartIcon({required this.cart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.textBrown, size: 22),
          ),
          if (cart.totalItems > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.primaryOrange, shape: BoxShape.circle),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${cart.totalItems}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ----- Search Bar -----

class _ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ProductSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: AppColors.textDark.withOpacity(0.02), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search,
              color: AppColors.primaryOrange.withOpacity(0.7), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Cari Roti Pia Susu...",
                hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.textHint, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryOrange,
              child: Icon(Icons.tune, color: AppColors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
