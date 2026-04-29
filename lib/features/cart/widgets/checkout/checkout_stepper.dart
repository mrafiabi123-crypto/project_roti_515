import 'package:flutter/material.dart';
import 'checkout_styles.dart';
import 'package:roti_515/core/theme/app_theme.dart';

/// Progress stepper 3 langkah di atas halaman checkout.
class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Row(
          children: [
            _StepItem(num: '1', label: 'Pilih Produk'),
            Expanded(child: _StepLine()),
            _StepItem(num: '2', label: 'Total Harga'),
            Expanded(child: _StepLine()),
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
              color: context.colors.primaryOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: context.colors.primaryOrange.withValues(alpha: 0.20),
                    blurRadius: 6,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Text(num,
                  style: TextStyle(
                      color: context.colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          SizedBox(width: 8),
          Text(label,
              style: pontano(12, context.colors.primaryOrange,
                  weight: FontWeight.w600)),
        ],
      );
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) => Container(
        height: 2,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.colors.primaryOrange.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(999),
        ),
      );
}
