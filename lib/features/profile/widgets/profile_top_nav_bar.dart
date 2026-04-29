import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roti_515/core/theme/app_theme.dart';


class ProfileTopNavBar extends StatelessWidget {
  const ProfileTopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.colors.primaryOrange,
                size: 16,
              ),
            ),
          ),
          Text(
            "Profil",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.colors.textDark,
            ),
          ),
          SizedBox(width: 40), // Spacer penyeimbang
        ],
      ),
    );
  }
}
