import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// --- IMPORT YANG DIBUTUHKAN ---
import '../main_nav/main_nav_page.dart'; // Halaman Utama
import 'register_page.dart'; // Halaman Register
import '../../state/auth_provider.dart'; // PENTING: Untuk AuthProvider

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Tambahkan SingleTickerProviderStateMixin untuk TabController
class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late TabController _tabController;
  
  bool _isLoading = false;
  bool _isObscure = true;

  // Variabel Warna dari Desain HTML (Tema Bakery)
  final Color primaryColor = const Color(0xFFD47311);
  final Color bgColor = const Color(0xFFF8F7F6);

  // URL Backend (Ganti 10.0.2.2 untuk Emulator Android, localhost untuk iOS/Web)
  final String _apiUrl = 'http://localhost:8080/api/login';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listener agar UI terupdate saat tab diklik (untuk perubahan warna teks tab)
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Mencegah memory leak
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGIN KE BACKEND GO ---
  Future<void> _login() async {
    // Validasi input kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password tidak boleh kosong"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Ambil role berdasarkan tab yang dipilih
    String role = _tabController.index == 0 ? "user" : "admin";

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
          "role": role, // Kirim role ke backend
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // SUKSES LOGIN
        print("Token: ${data['token']}");
        
        if (mounted) {
          // 1. Lapor ke AuthProvider bahwa login sukses
          Provider.of<AuthProvider>(context, listen: false).loginSuccess(data['token']);
          
          // 2. Karena LoginPage ada di dalam Tab Bar, kita tidak perlu Navigator push.
          // Halaman akan otomatis berubah jadi Profil karena AuthProvider update.
        }
      } else {
        // GAGAL LOGIN
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? "Login Failed"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error connecting to server: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // 1. BACK BUTTON (Top Left)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
                ),
              ),

              const SizedBox(height: 20),

              // 2. BRANDING SECTION (Desain HTML Bakery)
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(Icons.bakery_dining, size: 48, color: primaryColor),
              ),
              const SizedBox(height: 24),
              const Text(
                "Let's get baking!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome back to fresh delights.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // 3. ROLE SELECTION (Segmented Control Style)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person, size: 18), SizedBox(width: 8), Text("User Login")])),
                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.admin_panel_settings, size: 18), SizedBox(width: 8), Text("Admin Login")])),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. LOGIN FORM
              _buildInputLabel("Email Address"),
              _buildTextField(
                controller: _emailController,
                hint: "hello@example.com",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildInputLabel("Password"),
              _buildTextField(
                controller: _passwordController,
                hint: "••••••••",
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: _isObscure,
                onToggle: () => setState(() => _isObscure = !_isObscure),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text("Forgot Password?", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 10),

              // 5. MAIN ACTION BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Log In", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                ),
              ),

              // 6. DIVIDER
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Or continue with", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),

              // 7. SOCIAL LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton('google'),
                  const SizedBox(width: 16),
                  _buildSocialButton('apple'),
                  const SizedBox(width: 16),
                  _buildSocialButton('facebook'),
                ],
              ),

              const SizedBox(height: 32),

              // 8. FOOTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New to roti515?", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                    child: Text("Sign Up", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1F2937))),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.8)),
          suffixIcon: isPassword
              ? IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle)
              : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String type) {
    IconData iconData = Icons.g_mobiledata;
    Color iconColor = Colors.black;

    if (type == 'google') { iconData = Icons.g_mobiledata; iconColor = const Color(0xFF4285F4); }
    else if (type == 'apple') { iconData = Icons.apple; iconColor = Colors.black; }
    else if (type == 'facebook') { iconData = Icons.facebook; iconColor = const Color(0xFF1877F2); }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Icon(iconData, size: 30, color: iconColor),
    );
  }
}