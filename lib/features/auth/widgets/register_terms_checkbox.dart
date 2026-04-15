import 'package:flutter/material.dart';
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
          activeColor: const Color(0xFFD47311),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: onChanged,
        ),
        Expanded(
          child: Text(
            "Saya setuju dengan Syarat & Ketentuan Roti515",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF9A734C),
            ),
          ),
        ),
      ],
    );
  }
}
