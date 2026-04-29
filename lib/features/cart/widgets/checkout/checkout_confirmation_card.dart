import 'package:flutter/material.dart';
import 'checkout_styles.dart';
import 'package:roti_515/core/theme/app_theme.dart';

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
                style: jakartaBold(18, context.colors.textDark, height: 28 / 18)),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.primaryOrange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                    color: context.colors.primaryOrange.withValues(alpha: 0.10)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleIconWidget(
                    icon: Icons.shopping_bag_outlined,
                    bg: context.colors.primaryOrange.withValues(alpha: 0.10),
                    color: context.colors.primaryOrange,
                    margin: EdgeInsets.only(right: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Konfirmasi & Bayar di Toko',
                            style: jakartaBold(16, context.colors.textDark,
                                height: 24 / 16)),
                        SizedBox(height: 4),
                        Text(
                          'Pesanan Anda akan disiapkan untuk diambil. '
                          'Silakan bayar dengan uang tunai atau kartu '
                          'saat Anda tiba di toko.',
                          style: jakartaRegular(14, context.colors.textBrown,
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
