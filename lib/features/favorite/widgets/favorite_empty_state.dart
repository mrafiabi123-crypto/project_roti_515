import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roti_515/core/theme/app_theme.dart';


class FavoriteEmptyState extends StatelessWidget {
  const FavoriteEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: context.colors.textGrey.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16),
          Text(
            "Belum ada roti favoritmu.",
            style: GoogleFonts.plusJakartaSans(
              color: context.colors.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
