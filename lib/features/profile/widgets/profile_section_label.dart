import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roti_515/core/theme/app_theme.dart';


class ProfileSectionLabel extends StatelessWidget {
  final String label;

  const ProfileSectionLabel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.colors.textHint,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
