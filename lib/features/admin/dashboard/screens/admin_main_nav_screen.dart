import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import 'dashboard_admin_screen.dart';
import '../../product_admin/screens/product_admin_screen.dart';
import '../../orders/screens/order_admin_screen.dart';
import '../../users/screens/user_admin_screen.dart';

class AdminMainNavScreen extends StatefulWidget {
  const AdminMainNavScreen({super.key});

  @override
  State<AdminMainNavScreen> createState() => _AdminMainNavScreenState();
}

class _AdminMainNavScreenState extends State<AdminMainNavScreen> {
  int _selectedIndex = 0;

  // Daftar Halaman
  final List<Widget> _screens = [
    const DashboardAdminScreen(),
    const ProductAdminScreen(),
    const OrderAdminScreen(),
    const UserAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      extendBody: true, 
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- KUSTOM NAVBAR (FIXED PRECISION) ---
  Widget _buildCustomBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          // Tinggi 80-84 sudah ideal, tapi kita hilangkan SafeArea internal 
          // agar Row bisa menggunakan seluruh ruang secara simetris
          height: 80, 
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            border: Border(
              top: BorderSide(
                color: AppColors.primaryOrange.withValues(alpha: 0.15), 
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center, // Memastikan konten rata tengah
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, "Dashboard"),
              _buildNavItem(1, Icons.inventory_2_rounded, "Produk"),
              _buildNavItem(2, Icons.receipt_long_rounded, "Order"),
              _buildNavItem(3, Icons.people_alt_rounded, "Pengguna"),
            ],
          ),
        ),
      ),
    );
  }

  // --- ITEM NAVBAR ---
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    Color color = isSelected ? AppColors.primaryOrange : const Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          // Menggunakan MainAxisAlignment.center agar konten vertikal di tengah
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Ikon dibuat sedikit lebih kecil (22) agar terlihat lebih elegan dan simetris
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.diagonal3Values(isSelected ? 1.05 : 1.0, isSelected ? 1.05 : 1.0, 1.0),
              child: Icon(icon, color: color, size: 22), 
            ),
            const SizedBox(height: 6), // Jarak antar ikon dan teks yang konsisten
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9, // Ukuran teks diperkecil sedikit agar tidak sesak
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: color,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}