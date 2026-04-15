import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/widgets/animated_cart_icon.dart';
import '../../notification/widgets/notification_icon_badge.dart';
import 'cart_fly_animation.dart';

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
                // ── Animasi 2: Badge pop dengan AnimatedSwitcher ──
                Row(
                  children: [
                    const NotificationIconBadge(),
                    const SizedBox(width: 12),
                    AnimatedCartIcon(
                      cart: cart,
                      iconKey: CartFlyAnimation.cartIconKey,
                    ),
                  ],
                ),
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
              color: AppColors.textDark.withValues(alpha: 0.02), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search,
              color: AppColors.primaryOrange.withValues(alpha: 0.7), size: 18),
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
