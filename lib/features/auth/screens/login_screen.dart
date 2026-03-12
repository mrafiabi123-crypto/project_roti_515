import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart'; // ✅ Pastikan import ini ada
import '../providers/auth_provider.dart';
import 'register_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late TabController _tabController;
  
  bool _isLoading = false;
  bool _isObscure = true;

  // ✅ Gunakan 127.0.0.1 agar lebih stabil daripada localhost
  final String _apiUrl = 'http://127.0.0.1:8080/api/login';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGIKA LOGIN (FIXED NAVIGATION) ---
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Email dan Password wajib diisi", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    String role = _tabController.index == 0 ? "user" : "admin";

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
          "role": role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && mounted) {
        // 1. Simpan token ke provider
        Provider.of<AuthProvider>(context, listen: false).login(data['token']);
        
        _showSnackBar("Selamat datang kembali!", isError: false);

        // ✅ FIX BLANK SCREEN: Jangan pop, tapi arahkan ke MainNav dan hapus history
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainNav, (route) => false);
        
      } else if (mounted) {
        _showSnackBar(data['error'] ?? "Login Gagal", isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Gagal terhubung ke server", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER IMAGE DENGAN GRADIENT FADE ---
            _buildHeaderImage(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Selamat Datang",
                    style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1B140D)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Masuk untuk menikmati roti hangat setiap hari.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, color: const Color(0xFF9A734C)),
                  ),

                  const SizedBox(height: 32),

                  // --- 2. TAB SELECTOR (USER/ADMIN) ---
                  _buildTabSelector(),

                  const SizedBox(height: 32),

                  // --- 3. INPUT FIELDS (KAPSUL STYLE) ---
                  _buildLabel("Email"),
                  _buildInputKapsul(
                    controller: _emailController,
                    hint: "nama@email.com",
                    icon: Icons.mail_outline_rounded,
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

                  _buildForgotPassword(),

                  const SizedBox(height: 32),

                  // --- 4. TOMBOL LOGIN ---
                  _buildLoginButton(),

                  const SizedBox(height: 32),

                  // --- 5. FOOTER ---
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
      height: 240,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1517433367423-c7e5b0f35086?q=80&w=1000&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, const Color(0xFFF8F7F6).withOpacity(0.8), const Color(0xFFF8F7F6)],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFFE7DBCF).withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: const Color(0xFFD47311), borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF9A734C),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: "User"), Tab(text: "Admin")],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1B140D))),
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
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9999), border: Border.all(color: const Color(0xFFE7DBCF))),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.plusJakartaSans(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: InputBorder.none,
          suffixIcon: GestureDetector(onTap: onSuffixTap, child: Icon(icon, color: const Color(0xFF9A734C), size: 20)),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [BoxShadow(color: const Color(0xFFD47311).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD47311), shape: const StadiumBorder(), elevation: 0),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text("Masuk Sekarang", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text("Lupa Password?", style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD47311), fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Belum punya akun? ", style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9A734C))),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
          child: Text("Daftar Sekarang", style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD47311), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}