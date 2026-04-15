import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/widgets/animated_cart_icon.dart';
import '../../notification/widgets/notification_icon_badge.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.bgColor.withValues(alpha: 0.95),
      ),
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
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Row(
                  children: [
                    const NotificationIconBadge(),
                    const SizedBox(width: 12),
                    AnimatedCartIcon(cart: cart),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const _HomeSearchBar(),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

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
              color: AppColors.textDark.withValues(alpha: 0.05), blurRadius: 2)
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded,
              color: AppColors.primaryOrange.withValues(alpha: 0.7), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari Roti Pia Susu...",
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: AppColors.primaryOrange, shape: BoxShape.circle),
            child: const Icon(Icons.tune_rounded,
                color: AppColors.white, size: 14),
          ),
        ],
      ),
    );
  }
}
