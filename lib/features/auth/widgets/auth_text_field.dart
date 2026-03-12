import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan font agar senada
import '../../../core/constants/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final TextEditingController controller;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false, // Pastikan obscureText hanya jalan jika isPassword true
      style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: AppColors.textHint, size: 20),
        
        // Icon mata untuk password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.textHint, 
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,

        // Border bawah sesuai desain Figma
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}