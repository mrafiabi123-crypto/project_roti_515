import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT PROVIDER ---
import '../../state/auth_provider.dart';

// --- IMPORT HALAMAN ---
import '../home/home_page.dart';
import '../menu/menu_page.dart'; 
import '../auth/login_page.dart'; 
import '../profile/profile_page.dart'; 

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _selectedIndex = 0;
  
  // Warna Palet Roti 515
  final Color primaryColor = const Color(0xFFD4812C); 
  final Color inactiveColor = const Color(0xFF9E9E9E);
  final Color bgColor = const Color(0xFFFDFBFA);

  Widget _buildBody() {
    final isLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;

    switch (_selectedIndex) {
      case 0: return const HomePage();
      case 1: return const MenuPage();
      case 2: return const Center(child: Text("Halaman Favorit"));
      case 3: return isLoggedIn ? const ProfilePage() : const LoginPage();
      default: return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _buildBody(), 
      bottomNavigationBar: _buildFigmaBottomBar(),
    );
  }

  Widget _buildFigmaBottomBar() {
    return Container(
      height: 85, 
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
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
              color: isActive ? primaryColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryColor : inactiveColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
              ),
            ),
            // Bagian titik sudah dihapus sepenuhnya di sini
          ],
        ),
      ),
    );
  }
}