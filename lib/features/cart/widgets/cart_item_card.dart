import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../providers/cart_provider.dart';

/// Satu baris item di keranjang — gambar, nama, harga, qty selector, hapus.
class CartItemCard extends StatelessWidget {
  final dynamic item;
  final int index;

  const CartItemCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.network(
              item.product.imageUrl.isNotEmpty
                  ? item.product.imageUrl
                  : "https://placehold.co/88x88",
              width: 88,
              height: 88,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeItem(index),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.textHint, size: 20),
                    ),
                  ],
                ),
                Text(
                  item.product.description.isNotEmpty
                      ? item.product.description
                      : "Roti hangat dari oven",
                  style: GoogleFonts.pontanoSans(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${formatRupiah(item.product.price)}",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    _QtySelector(cart: cart, index: index, quantity: item.quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----- Quantity Selector (private) -----

class _QtySelector extends StatelessWidget {
  final CartProvider cart;
  final int index;
  final int quantity;

  const _QtySelector({
    required this.cart,
    required this.index,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleBtn(
            icon: Icons.remove_rounded,
            bg: AppColors.white,
            iconColor: AppColors.textDark,
            onTap: () => cart.decreaseQuantity(index),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "$quantity",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ),
          _CircleBtn(
            icon: Icons.add_rounded,
            bg: AppColors.primaryOrange,
            iconColor: AppColors.white,
            hasShadow: true,
            onTap: () => cart.increaseQuantity(index),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final bool hasShadow;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.onTap,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }
}
