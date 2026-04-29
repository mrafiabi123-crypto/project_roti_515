import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../../cart/widgets/animated_cart_icon.dart';
import '../../notification/widgets/notification_icon_badge.dart';
import 'package:roti_515/core/theme/app_theme.dart';

class FavoriteAppBar extends StatelessWidget {
  const FavoriteAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: context.colors.bgColor.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: context.colors.divider)),
      ),
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
    );
  }
}
