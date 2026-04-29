import 'package:roti_515/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterInputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onSuffixTap;
  final TextInputType keyboardType;

  const RegisterInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textDark,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface, borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: context.colors.divider),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: context.colors.textDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: context.colors.textHint,
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              border: InputBorder.none,
              suffixIcon: GestureDetector(
                onTap: onSuffixTap,
                child: Icon(icon, color: context.colors.textHint, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
