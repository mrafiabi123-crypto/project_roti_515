import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class HomePromoBanner extends StatelessWidget {
  const HomePromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            )
          ],
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [AppColors.textDark.withOpacity(0.8), Colors.transparent],
              begin: Alignment.centerLeft,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 320,
                child: Text(
                  '"Roti 515: Hangat dari oven, hadir untuk harimu."',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.textDark.withOpacity(0.1),
                        blurRadius: 4)
                  ],
                ),
                child: Text(
                  "Pesan Sekarang",
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
