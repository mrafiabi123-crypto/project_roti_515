import 'package:roti_515/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Theme.of(context).brightness == Brightness.dark ? 160 : 320,
          child: Image.asset(
            Theme.of(context).brightness == Brightness.dark 
              ? 'assets/images/brand_logo_dark.png' 
              : 'assets/images/brand_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Selamat Datang",
          style: GoogleFonts.pragatiNarrow(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: context.colors.textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Roti 515",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: context.colors.textGrey,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
