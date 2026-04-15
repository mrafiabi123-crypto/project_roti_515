import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// --- IMPORT COMPONENT WIDGETS ---
// Mengimpor sub-komponen UI modular khusus layar profil
import '../widgets/profile_top_nav_bar.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section_label.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_logout_button.dart';
import 'address_management_screen.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_service.dart';
import '../../../presentation/pages/profile/order_history_page.dart';

/// Layar utama Profil Pengguna (StatefulWidget untuk mengakomodasi state loading dan data asinkron).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Menyimpan data profile hasil fetch API dalam Map
  Map<String, dynamic>? _userData;
  
  // Flag indikator proses request API
  bool _isLoading = true;

  // Mendapatkan path endpoint API profile dari layanan terpusat
  final String _apiUrl = ApiService.profile;

  @override
  void initState() {
    super.initState();
    // Memanggil API fetch secara implisit sesaat setelah inisialisasi State
    _fetchProfile();
  }

  /// Memuat profil data dari Backend API dengan Autorisasi Token Bearer.
  Future<void> _fetchProfile() async {
    try {
      // Mengambil token sesi login aktual dari state AuthProvider
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      
      // Request method GET untuk mengambil detail data diri (Profile)
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Respon HTTP valid
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Memastikan widget masih di-mount sebelum memicu re-render
        if (mounted) {
          setState(() {
            _userData = data['user']; // Menyalin data objek 'user' dari respon JSON
            _isLoading = false; // Mengakhiri state loading
          });
        }
      } else {
        // Gagal mengambil data karena HTTP code tidak valid
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      // Gagal tersambung internet atau server mati
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengekstrak informasi user dari Map State. Fallback string jika null.
    String fullName = _userData?['name'] ?? "Loading...";
    String email = _userData?['email'] ?? "memuat..";
    
    return Scaffold(
      backgroundColor: AppColors.bgColor, // Mengatur standar background warna aplikasi
      body: _isLoading
          // Render progress indikator selama response API dari endpoint profile belum selesai
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          // Render Main Layout Profil jika data siap
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- 1. CUSTOM TOP NAVIGATION ---
                    // Menampilkan bilah navigasi Header dengan title "Profil"
                    const ProfileTopNavBar(),

                    // --- 2. HEADER PROFIL (AVATAR & INFO) ---
                    // Mengoper data API (_userData) ke widget render Header
                    ProfileHeader(name: fullName, email: email),

                    const SizedBox(height: 24),

                    // --- 3. MENU SECTION: AKTIVITAS AKUN ---
                    // Label seksio
                    const ProfileSectionLabel(label: "Aktivitas Akun"),
                    
                    // Modul Tombol Navigasi Menu: Riwayat Pesanan
                    ProfileMenuTile(
                      icon: Icons.receipt_long_rounded,
                      title: "Riwayat Pesanan",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryPage(),
                          ),
                        );
                      },
                    ),
                    
                    // Modul Tombol Navigasi Menu: Modifikasi Alamat
                    ProfileMenuTile(
                      icon: Icons.location_on_rounded,
                      title: "Alamat Lengkap",
                      subtitle: (_userData?['address'] as String? ?? "").isNotEmpty
                          ? _userData!['address']
                          : "Tambahkan / Ubah",
                      onTap: () async {
                        final newAddress = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressManagementScreen(
                              currentAddress: _userData?['address'] ?? "Ambil Di Toko",
                            ),
                          ),
                        );
                        if (newAddress != null && mounted) {
                          setState(() {
                            _userData?['address'] = newAddress;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // --- 4. MENU SECTION: PREFERENSI ---
                    const ProfileSectionLabel(label: "Preferensi"),
                    
                    // Modul Tombol Navigasi Menu: Pengaturan
                    ProfileMenuTile(
                      icon: Icons.settings_rounded,
                      title: "Pengaturan Utama",
                      subtitle: "Notifikasi, Privasi",
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // --- 5. TOMBOL LOGOUT (SOFT RED STYLE) ---
                    // Memuat Widget kustom konfirmasi Logout system (terhubung ke AuthProvider)
                    const ProfileLogoutButton(),

                    // Bantalan margin penahan dari BottomNavigationBar utama Scaffold
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
    );
  }
}