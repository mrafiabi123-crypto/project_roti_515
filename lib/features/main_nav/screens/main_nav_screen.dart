import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PONDASI ---
import '../../../core/constants/app_colors.dart';

// --- IMPORT PROVIDERS ---
import '../../auth/providers/auth_provider.dart';

// --- IMPORT FEATURE SCREENS ---
import '../../home/screens/home_screen.dart';
import '../../product/screens/product_screen.dart'; 
import '../../favorite/screens/favorite_screen.dart'; 
import '../../auth/screens/login_screen.dart'; 

// Import Profile (Sementara arahkan ke folder lama jika belum dipindah)
import '../../profile/screens/profile_screen.dart'; 

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  // Daftar halaman utama
  Widget _buildBody() {
    final isLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;

    switch (_selectedIndex) {
      case 0: return const HomeScreen(); // Sudah ganti nama dari HomePage
      case 1: return const ProductScreen();
      case 2: return const FavoriteScreen(); 
      case 3: 
        // Logika proteksi: Belum login? Lempar ke Login. Sudah? Tampilkan Profil.
        return isLoggedIn ? const ProfilePage() : const LoginScreen();
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: _buildBody(), 
      bottomNavigationBar: _buildFigmaBottomBar(),
    );
  }

  // Desain Bottom Bar yang Identik dengan Figma kamu
  Widget _buildFigmaBottomBar() {
    return Container(
      height: 85, 
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
        border: const Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, Icons.home_rounded, "Beranda", 0),
          _buildNavItem(Icons.bakery_dining_outlined, Icons.bakery_dining_rounded, "Produk", 1),
          _buildNavItem(Icons.favorite_outline_rounded, Icons.favorite_rounded, "Favorit", 2),
          _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, "Profil", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutline, IconData iconFilled, String label, int index) {
    final bool isActive = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconFilled : iconOutline,
              color: isActive ? AppColors.primaryOrange : AppColors.textHint,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isActive ? AppColors.primaryOrange : AppColors.textHint,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}