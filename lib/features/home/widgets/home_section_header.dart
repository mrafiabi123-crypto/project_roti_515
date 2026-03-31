import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final bool showArrows;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.showArrows,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.pragatiNarrow(
              fontSize: 18,
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showArrows)
            Row(
              children: [
                _SmallArrow(icon: Icons.chevron_left_rounded),
                const SizedBox(width: 4),
                _SmallArrow(icon: Icons.chevron_right_rounded),
              ],
            )
          else
            Text(
              "Lihat Semua",
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallArrow extends StatelessWidget {
  final IconData icon;
  const _SmallArrow({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: AppColors.textDark.withOpacity(0.05), blurRadius: 2)
        ],
        border: Border.all(color: AppColors.divider),
      ),
      child: Icon(icon, size: 20, color: AppColors.textDark),
    );
  }
}
