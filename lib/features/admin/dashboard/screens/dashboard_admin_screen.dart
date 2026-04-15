import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/admin_stats_provider.dart';
import '../widgets/animated_sales_chart.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final statsProvider = Provider.of<AdminStatsProvider>(context, listen: false);
    Future.microtask(() => statsProvider.startPolling(auth.token));
  }

  @override
  void dispose() {
    // Memastikan polling berhenti saat admin meninggalkan dashboard
    Provider.of<AdminStatsProvider>(context, listen: false).stopPolling();
    super.dispose();
  }

  // Fungsi Logout
  void _logout() {
    // Memanggil provider untuk menghapus session token
    Provider.of<AuthProvider>(context, listen: false).logout();
    // Kembali ke halaman Login dan hapus semua history navigasi
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  // Menampilkan Dialog Konfirmasi Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Logout", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin keluar?", style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text("Keluar", style: GoogleFonts.plusJakartaSans(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<AdminStatsProvider>(context);
    final stats = statsProvider.stats;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: statsProvider.isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- STATS ROW ---
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Total Penjualan", "Rp. ${stats['total_sales']}", stats['sales_growth'], Icons.payments_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Total Order", "${stats['total_orders']}", stats['orders_growth'], Icons.shopping_basket_rounded)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard("Pengguna Baru", "${stats['total_users']}", stats['users_growth'], Icons.person_add_rounded, isFullWidth: true),

            const SizedBox(height: 24),

            // --- SALES CHART ---
            _buildSalesChart(),

            const SizedBox(height: 32),

            // --- RECENT ACTIVITIES ---
            Text(
              "Aktivitas Terkini",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: AppColors.textDark
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem("New Order #8921", "2 menit lalu • Rp: 26.000", Icons.receipt_long_rounded),
            _buildActivityItem("Pelanggan Baru Terdaftar", "1 jam lalu • Sarah J.", Icons.person_add_alt_1_rounded),
            
            const SizedBox(height: 100), // Spasi aman untuk Bottom Nav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgColor,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(16)
            ),
            child: const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryOrange, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("roti515", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text("Portal Admin", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryOrange)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          tooltip: "Logout",
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.1),
            child: const Icon(Icons.account_circle_outlined, color: AppColors.primaryOrange),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String percent, IconData icon, {bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, 
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 14),
              const SizedBox(width: 4),
              Text(percent, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return const AnimatedSalesChart();
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}
