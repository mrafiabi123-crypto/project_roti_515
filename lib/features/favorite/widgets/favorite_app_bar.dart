import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/widgets/animated_cart_icon.dart';

class FavoriteAppBar extends StatelessWidget {
  const FavoriteAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColors.bgColor.withValues(alpha: 0.95),
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
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
          AnimatedCartIcon(cart: cart),
        ],
      ),
    );
  }
}
