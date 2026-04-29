import 'package:flutter/material.dart';
import 'package:roti_515/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah Punya Akun? ",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: context.colors.textHint,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Masuk",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.colors.primaryOrange,
            ),
          ),
        ),
      ],
    );
  }
}
