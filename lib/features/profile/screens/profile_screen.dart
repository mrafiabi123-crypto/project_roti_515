import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // URL Backend (Ganti ke 127.0.0.1 agar lebih stabil di browser)
  final String _apiUrl = 'http://127.0.0.1:8080/api/profile';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userData = data['user'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data Default & Inisial
    String fullName = _userData?['name'] ?? "User";
    String email = _userData?['email'] ?? "Email@gmail.com";
    
    return Scaffold(
      backgroundColor: AppColors.bgColor, // Menggunakan F8F7F6 dari AppColors
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- 1. CUSTOM TOP NAVIGATION ---
                    _buildTopNavigationBar(),

                    // --- 2. HEADER PROFIL (AVATAR & INFO) ---
                    _buildHeaderSection(fullName, email),

                    const SizedBox(height: 24),

                    // --- 3. MENU SECTION: AKTIVITAS AKUN ---
                    _buildSectionLabel("Aktivitas Akun"),
                    _buildMenuTile(
                      icon: Icons.receipt_long_rounded,
                      title: "Riwayat Pesanan",
                      onTap: () {}, // Hubungkan ke OrderHistoryPage jika perlu
                    ),
                    _buildMenuTile(
                      icon: Icons.location_on_rounded,
                      title: "Alamat",
                      subtitle: "------------",
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    // --- 4. MENU SECTION: PREFERENSI ---
                    _buildSectionLabel("Preferensi"),
                    _buildMenuTile(
                      icon: Icons.settings_rounded,
                      title: "Pengaturan",
                      subtitle: "Notifikasi, Privasi",
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // --- 5. TOMBOL LOGOUT (SOFT RED STYLE) ---
                    _buildLogoutButton(),

                    const SizedBox(height: 100), // Spasi Bottom Nav
                  ],
                ),
              ),
            ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildTopNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryOrange, size: 16),
          ),
          Text(
            "Profil",
            style: GoogleFonts.pragatiNarrow(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(width: 40), // Spacer penyeimbang
        ],
      ),
    );
  }

  Widget _buildHeaderSection(String name, String email) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 128, height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10))],
                image: const DecorationImage(
                  image: NetworkImage('https://placehold.co/128x128'), // Ganti dengan _userData?['photo_url'] jika ada
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.pragatiNarrow(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        Text(
          email,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textHint, letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(48),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(48),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.primaryOrange, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    if (subtitle != null)
                      Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          borderRadius: BorderRadius.circular(48),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // Red soft background
              borderRadius: BorderRadius.circular(48),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  "Keluar",
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}