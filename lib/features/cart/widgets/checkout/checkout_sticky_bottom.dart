import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../providers/cart_provider.dart';
import 'checkout_styles.dart';

/// Bottom bar sticky: total harga + tombol "Buat Pesanan".
class CheckoutStickyBottom extends StatelessWidget {
  final CartProvider cart;
  final int deliveryFee;
  final bool isOrdering;
  final VoidCallback onOrder;

  const CheckoutStickyBottom({
    super.key,
    required this.cart,
    required this.deliveryFee,
    required this.isOrdering,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final grandTotal = cart.totalPrice + deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 20,
              offset: Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total harga
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Total Harga',
                    style: jakartaMedium(16, AppColors.textBrown)),
                Text('Rp ${formatRupiah(grandTotal)}',
                    style: jakartaBold(24, AppColors.textDark, height: 32 / 24)
                        .copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tombol pesan
          GestureDetector(
            onTap: isOrdering ? null : onOrder,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 4)),
                  BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Buat Pesanan',
                        textAlign: TextAlign.center,
                        style: jakartaBold(16, AppColors.white)),
                  ),
                  isOrdering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: AppColors.white, strokeWidth: 2.5))
                      : Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.white, size: 16),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Dengan mengklik tombol ini, Pesanan Anda akan disiapkan '
              'untuk diambil. Silakan bayar dengan uang tunai atau kartu '
              'saat Anda tiba di toko.',
              textAlign: TextAlign.center,
              style: jakartaRegular(12, AppColors.textBrown.withValues(alpha: 0.70),
                  height: 16 / 12),
            ),
          ),
        ],
      ),
    );
  }
}
