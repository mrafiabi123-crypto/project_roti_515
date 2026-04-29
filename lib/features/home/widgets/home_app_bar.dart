import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../../cart/widgets/animated_cart_icon.dart';
import '../../notification/widgets/notification_icon_badge.dart';
import 'package:roti_515/core/theme/app_theme.dart';

// HomeAppBar kini menjadi StatefulWidget agar bisa memiliki TextEditingController
// dan logika debounce untuk pencarian — persis seperti ProductAppBar
class HomeAppBar extends StatefulWidget {
  final void Function(String query) onSearchChanged;
  final VoidCallback onFilterTap;

  const HomeAppBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounce 500ms agar tidak terlalu sering hit API saat user mengetik
  void _onChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: context.colors.bgColor.withValues(alpha: 0.95),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "515",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 30,
                    color: context.colors.textBrown,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Row(
                  children: [
                    NotificationIconBadge(),
                    SizedBox(width: 12),
                    AnimatedCartIcon(cart: cart),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          // Search bar yang sudah terhubung ke controller dan callback
          _HomeSearchBar(
            controller: _searchController,
            onChanged: _onChanged,
            onFilterTap: widget.onFilterTap,
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const _HomeSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: context.colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: context.colors.divider),
        boxShadow: [
          BoxShadow(
              color: context.colors.textDark.withValues(alpha: 0.05), blurRadius: 2)
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.search_rounded,
              color: context.colors.primaryOrange.withValues(alpha: 0.7), size: 18),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Cari Roti Pia Susu...",
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: context.colors.textHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          // Tombol filter yang sekarang bisa di-tap
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              margin: EdgeInsets.only(right: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: context.colors.primaryOrange, shape: BoxShape.circle),
              child: Icon(Icons.tune_rounded,
                  color: context.colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
