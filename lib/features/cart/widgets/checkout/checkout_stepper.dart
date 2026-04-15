import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'checkout_styles.dart';

/// Progress stepper 3 langkah di atas halaman checkout.
class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Row(
          children: [
            _StepItem(num: '1', label: 'Pilih Produk'),
            const Expanded(child: _StepLine()),
            _StepItem(num: '2', label: 'Total Harga'),
            const Expanded(child: _StepLine()),
            _StepItem(num: '3', label: 'Konfirmasi'),
          ],
        ),
      );
}

class _StepItem extends StatelessWidget {
  final String num;
  final String label;
  const _StepItem({required this.num, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.20),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: pontano(12, AppColors.primaryOrange,
                  weight: FontWeight.w600)),
        ],
      );
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) => Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(999),
        ),
      );
}
