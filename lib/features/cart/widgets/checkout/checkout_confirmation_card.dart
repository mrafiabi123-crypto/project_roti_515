import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'checkout_styles.dart';

/// Kartu konfirmasi bayar di toko.
class CheckoutConfirmationCard extends StatelessWidget {
  const CheckoutConfirmationCard({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: kSectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Konfirmasi',
                style: jakartaBold(18, AppColors.textDark, height: 28 / 18)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.10)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleIconWidget(
                    icon: Icons.shopping_bag_outlined,
                    bg: AppColors.primaryOrange.withValues(alpha: 0.10),
                    color: AppColors.primaryOrange,
                    margin: const EdgeInsets.only(right: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Konfirmasi & Bayar di Toko',
                            style: jakartaBold(16, AppColors.textDark,
                                height: 24 / 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Pesanan Anda akan disiapkan untuk diambil. '
                          'Silakan bayar dengan uang tunai atau kartu '
                          'saat Anda tiba di toko.',
                          style: jakartaRegular(14, AppColors.textBrown,
                              height: 1.625),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
