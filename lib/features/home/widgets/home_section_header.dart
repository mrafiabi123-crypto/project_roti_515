import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roti_515/core/theme/app_theme.dart';


class HomeSectionHeader extends StatelessWidget {
  final String title;
  final bool showArrows;
  final VoidCallback? onLeftArrowTap;
  final VoidCallback? onRightArrowTap;
  final VoidCallback? onSeeAllTap;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.showArrows,
    this.onLeftArrowTap,
    this.onRightArrowTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.pragatiNarrow(
              fontSize: 18,
              color: context.colors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showArrows)
            Row(
              children: [
                _SmallArrow(icon: Icons.chevron_left_rounded, onTap: onLeftArrowTap),
                SizedBox(width: 4),
                _SmallArrow(icon: Icons.chevron_right_rounded, onTap: onRightArrowTap),
              ],
            )
          else
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                "Lihat Semua",
                style: GoogleFonts.plusJakartaSans(
                  color: context.colors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _SmallArrow({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: context.colors.textDark.withValues(alpha: 0.05), blurRadius: 2)
          ],
          border: Border.all(color: context.colors.divider),
        ),
        child: Icon(icon, size: 20, color: context.colors.textDark),
      ),
    );
  }
}
