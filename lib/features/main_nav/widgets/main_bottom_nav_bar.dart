import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Komponen UI modular untuk navigasi bawah (Bottom Navigation Bar).
class MainBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const MainBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
        border: const Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, Icons.home_rounded, "Beranda", 0),
          _buildNavItem(Icons.bakery_dining_outlined, Icons.bakery_dining_rounded, "Produk", 1),
          _buildNavItem(Icons.favorite_outline_rounded, Icons.favorite_rounded, "Favorit", 2),
          _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, "Profil", 3),
        ],
      ),
    );
  }

  /// Membangun masing-masing tombol navigasi berdasarkan indeks aktif.
  Widget _buildNavItem(IconData iconOutline, IconData iconFilled, String label, int index) {
    final bool isActive = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconFilled : iconOutline,
              color: isActive ? AppColors.primaryOrange : AppColors.textHint,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isActive ? AppColors.primaryOrange : AppColors.textHint,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
