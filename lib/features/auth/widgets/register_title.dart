import 'package:flutter/material.dart';
import 'package:roti_515/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterTitle extends StatelessWidget {
  const RegisterTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Buat Akun",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: context.colors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Daftar untuk memesan kue segar setiap hari dari Roti515.",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: context.colors.textHint,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
