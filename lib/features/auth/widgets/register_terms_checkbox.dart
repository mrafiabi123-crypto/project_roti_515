import 'package:flutter/material.dart';
import 'package:roti_515/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterTermsCheckbox extends StatelessWidget {
  final bool isAgreed;
  final ValueChanged<bool?> onChanged;

  const RegisterTermsCheckbox({
    super.key,
    required this.isAgreed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isAgreed,
          activeColor: context.colors.primaryOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: onChanged,
        ),
        Expanded(
          child: Text(
            "Saya setuju dengan Syarat & Ketentuan Roti515",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: context.colors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}
