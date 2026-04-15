import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'checkout_styles.dart';

/// Opsi pengambilan produk — "Ambil Di Toko".
class CheckoutDeliveryOption extends StatelessWidget {
  const CheckoutDeliveryOption({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: kSectionPadding,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(32),
            boxShadow: kCardShadow,
          ),
          child: Row(
            children: [
              CircleIconWidget(
                icon: Icons.storefront_rounded,
                bg: const Color(0xFFF3F4F6),
                color: const Color(0xFF6B7280),
                margin: const EdgeInsets.only(right: 16),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ambil Di Toko',
                        style: jakartaBold(16, AppColors.textDark)),
                    Text('Tersedia dalam 15 menit',
                        style: jakartaRegular(12, AppColors.textBrown)),
                  ],
                ),
              ),
              Text('Gratis', style: jakartaBold(16, AppColors.success)),
              const SizedBox(width: 12),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFD1D5DB), width: 2),
                ),
              ),
            ],
          ),
        ),
      );
}
