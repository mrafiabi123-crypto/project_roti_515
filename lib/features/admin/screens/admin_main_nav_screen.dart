import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'dashboard_admin_screen.dart';

class AdminMainNavScreen extends StatefulWidget {
  const AdminMainNavScreen({super.key});

  @override
  State<AdminMainNavScreen> createState() => _AdminMainNavScreenState();
}

class _AdminMainNavScreenState extends State<AdminMainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardAdminScreen(),
    const Center(child: Text("Produk Admin")),
    const Center(child: Text("Order Admin")),
    const Center(child: Text("Pengguna Admin")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        // ✅ FIX OVERFLOW: Hapus height fix, gunakan SafeArea agar dinamis
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: AppColors.primaryOrange.withOpacity(0.1))),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primaryOrange,
            unselectedItemColor: AppColors.textHint,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold),
            items: [
              _buildNavItem(Icons.dashboard_rounded, "Dasboard"),
              _buildNavItem(Icons.inventory_2_rounded, "Produk"),
              _buildNavItem(Icons.receipt_long_rounded, "Order"),
              _buildNavItem(Icons.people_alt_rounded, "Pengguna"),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 8),
        child: Icon(icon, size: 24),
      ),
      label: label.toUpperCase(),
    );
  }
}