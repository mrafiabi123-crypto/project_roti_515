import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- LOGIKA TETAP (TIDAK DIUBAH) ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;
  bool _isAgreed = false; 

  final String _apiUrl = 'http://localhost:8080/api/register';

  Future<void> _register() async {
    if (!_isAgreed) {
      _showSnackBar("Harap setujui Syarat dan Ketentuan", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneController.text,
          "password": _passwordController.text,
          "address": "",
          "photo_url": "",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && mounted) {
        _showSnackBar("Pendaftaran Sukses! Silakan Login.", isError: false);
        Navigator.pop(context); 
      } else if (mounted) {
        _showSnackBar(data['error'] ?? "Pendaftaran Gagal", isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Error koneksi: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6), // Background sesuai HTML
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER IMAGE DENGAN GRADIENT FADE ---
            _buildHeaderImage(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // --- 2. TITLE SECTION ---
                  Text(
                    "Buat Akun",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B140D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Daftar untuk memesan kue segar setiap hari dari Roti515.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: const Color(0xFF9A734C),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- 3. FORM FIELDS (KAPSUL STYLE) ---
                  _buildLabel("Nama"),
                  _buildInputKapsul(
                    controller: _nameController,
                    hint: "Masukkan Nama Pengguna",
                    icon: Icons.person_outline_rounded,
                  ),
                  
                  const SizedBox(height: 16),
                  _buildLabel("Email"),
                  _buildInputKapsul(
                    controller: _emailController,
                    hint: "Sawit123@gmail.com",
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("No. Handphone"),
                  _buildInputKapsul(
                    controller: _phoneController,
                    hint: "(62+)8123456789",
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("Password"),
                  _buildInputKapsul(
                    controller: _passwordController,
                    hint: "••••••••",
                    icon: _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    isPassword: true,
                    obscureText: _isObscure,
                    onSuffixTap: () => setState(() => _isObscure = !_isObscure),
                  ),

                  const SizedBox(height: 24),

                  // --- 4. CHECKBOX TERMS ---
                  _buildTermsCheckbox(),

                  const SizedBox(height: 32),

                  // --- 5. TOMBOL DAFTAR (WITH FIGMA SHADOW) ---
                  _buildRegisterButton(),

                  const SizedBox(height: 24),

                  // --- 6. FOOTER ---
                  _buildFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS UNTUK TAMPILAN ---

  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=1000&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFFF8F7F6).withOpacity(0.8),
              const Color(0xFFF8F7F6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B140D),
          ),
        ),
      ),
    );
  }

  Widget _buildInputKapsul({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFE7DBCF)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(fontSize: 16, color: const Color(0xFF1B140D)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF9CA3AF), fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: InputBorder.none,
          suffixIcon: GestureDetector(
            onTap: onSuffixTap,
            child: Icon(icon, color: const Color(0xFF9A734C), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD47311).withOpacity(0.20),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (_isLoading || !_isAgreed) ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD47311),
          disabledBackgroundColor: const Color(0xFFD47311).withOpacity(0.5),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              "Daftar",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isAgreed,
          activeColor: const Color(0xFFD47311),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) => setState(() => _isAgreed = val ?? false),
        ),
        Expanded(
          child: Text(
            "Saya setuju dengan Syarat & Ketentuan Roti515",
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF9A734C)),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah Punya Akun? ",
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF9A734C)),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Masuk",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD47311),
            ),
          ),
        ),
      ],
    );
  }
}