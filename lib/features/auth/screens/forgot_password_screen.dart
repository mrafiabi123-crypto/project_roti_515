import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/premium_snackbar.dart';
import '../widgets/login_back_button.dart';
import '../widgets/login_logo.dart';
import '../widgets/login_input_field.dart';
import '../widgets/login_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_emailController.text.isEmpty) {
      PremiumSnackbar.showError(context, "Silakan masukkan email Anda");
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi pengiriman email
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      PremiumSnackbar.showSuccess(context, "Instruksi reset password telah dikirim ke email Anda");
      
      // Tunggu sebentar lalu kembali ke login
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LoginBackButton(),
              const SizedBox(height: 16),
              const LoginLogo(),
              const SizedBox(height: 40),
              
              Text(
                "Lupa Password?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Jangan khawatir! Masukkan email Anda di bawah ini untuk menerima instruksi reset password.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF757575),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              LoginInputField(
                controller: _emailController,
                label: "Email",
                hint: "Masukkan Email Terdaftar",
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 32),
              
              LoginButton(
                isLoading: _isLoading, 
                onPressed: _sendResetLink,
                text: "Kirim Instruksi",
              ),
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Kembali ke Login",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
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
