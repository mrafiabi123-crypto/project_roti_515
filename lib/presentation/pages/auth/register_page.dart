import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart'; // Import Login Page untuk navigasi balik

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // State UI
  bool _isLoading = false;
  bool _isObscure = true;
  bool _isAgreed = false; // Checkbox Terms

  // URL Backend
  final String _apiUrl = 'http://localhost:8080/api/register';

  // --- FUNGSI REGISTER KE BACKEND GO ---
  Future<void> _register() async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms of Service")),
      );
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
          // Address & PhotoURL bisa kosong dulu atau diupdate di Profile Page
          "address": "",
          "photo_url": "",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // SUKSES DAFTAR
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration Successful! Please Login."), backgroundColor: Colors.green),
          );
          // Balik ke Login Page
          Navigator.pop(context); 
        }
      } else {
        // GAGAL
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? "Registration Failed"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFEC4913);
    const bgColor = Colors.white; // HTML Anda pakai bg-white

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Back Button & Title)
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text("Join Us!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text("Create an account to start ordering your favorite meals.", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              const SizedBox(height: 32),

              // 2. FORM INPUT
              _buildInputLabel("Full Name"),
              _buildTextField(
                controller: _nameController,
                icon: Icons.person_outline,
                hint: "John Doe",
              ),
              const SizedBox(height: 16),

              _buildInputLabel("Email Address"),
              _buildTextField(
                controller: _emailController,
                icon: Icons.mail_outline,
                hint: "name@example.com",
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildInputLabel("Phone Number"),
              _buildTextField(
                controller: _phoneController,
                icon: Icons.call_outlined,
                hint: "+62 812 3456 7890", // Disesuaikan format Indo
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildInputLabel("Password"),
              _buildTextField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: "••••••••",
                isPassword: true,
                isObscure: _isObscure,
                onTogglePassword: () => setState(() => _isObscure = !_isObscure),
              ),
              const SizedBox(height: 20),

              // 3. CHECKBOX TERMS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                      onChanged: (val) => setState(() => _isAgreed = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                        children: const [
                          TextSpan(text: "I agree to the "),
                          TextSpan(text: "Terms of Service", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          TextSpan(text: " and "),
                          TextSpan(text: "Privacy Policy", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 4. TOMBOL SIGN UP
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isAgreed) ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              // 5. FOOTER LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  TextButton(
                    onPressed: () => Navigator.pop(context), // Balik ke Login
                    child: const Text("Sign In", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool isObscure = false,
    TextInputType inputType = TextInputType.text,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // slate-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        keyboardType: inputType,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade400),
                onPressed: onTogglePassword,
              ) 
            : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}