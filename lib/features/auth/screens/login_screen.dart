import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_back_button.dart';
import '../widgets/login_logo.dart';
import '../widgets/login_tab_selector.dart';
import '../widgets/login_input_field.dart';
import '../widgets/login_button.dart';
import '../widgets/login_divider.dart';
import '../widgets/login_google_button.dart';
import '../widgets/login_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late TabController _tabController;

  bool _isLoading = false;
  bool _isObscure = true;

  // URL API dinamis sesuai platform
  String get _apiUrl {
    const String port = '8080';
    if (kIsWeb) {
      return 'http://localhost:$port/api/login';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port/api/login';
    } else {
      return 'http://localhost:$port/api/login';
    }
  }

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

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Email dan Password wajib diisi", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && mounted) {
        final String token = data['token'];
        final String userRole = data['user']['role'];
        final String userName = data['user']['name'];

        Provider.of<AuthProvider>(context, listen: false).login(token);
        _showSnackBar("Selamat datang, $userName!", isError: false);

        if (userRole == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.adminDashboard, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.mainNav, (route) => false);
        }
      } else if (mounted) {
        _showSnackBar(data['error'] ?? "Gagal login", isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Gagal terhubung ke server. Cek koneksi.", isError: true);
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LoginBackButton(),
              const SizedBox(height: 16),
              const LoginLogo(),
              const SizedBox(height: 32),
              LoginTabSelector(controller: _tabController),
              const SizedBox(height: 32),
              LoginInputField(
                controller: _emailController,
                label: "Email",
                hint: "Masukkan Email Atau Nama Pengguna",
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 20),
              LoginInputField(
                controller: _passwordController,
                label: "Password",
                hint: "Masukkan Password",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _isObscure,
                onSuffixTap: () => setState(() => _isObscure = !_isObscure),
              ),

              // --- LUPA PASSWORD ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Lupa Password?",
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primaryOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              LoginButton(isLoading: _isLoading, onPressed: _login),
              const SizedBox(height: 32),

              // Fitur daftar & sosial login hanya untuk tab User
              if (_tabController.index == 0) ...[
                const LoginDivider(),
                const SizedBox(height: 24),
                const LoginGoogleButton(),
                const SizedBox(height: 32),
                const LoginFooter(),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}