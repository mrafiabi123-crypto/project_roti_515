import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/auth_provider.dart';
import '../providers/admin_stats_provider.dart';
import '../widgets/animated_sales_chart.dart';
import '../../profile/screens/admin_profile_screen.dart';
import 'package:roti_515/core/theme/theme_provider.dart';
import 'package:roti_515/core/theme/app_theme.dart';
import 'package:roti_515/core/network/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<AdminStatsProvider>(context);
    final stats = statsProvider.stats;

    return Scaffold(
      backgroundColor: context.colors.bgColor,
      appBar: _buildAppBar(),
      body: statsProvider.isLoading 
          ? Center(child: CircularProgressIndicator(color: context.colors.primaryOrange))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- STATS ROW ---
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Total Penjualan", "Rp. ${stats['total_sales']}", stats['sales_growth'], Icons.payments_rounded)),
                      SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Total Order", "${stats['total_orders']}", stats['orders_growth'], Icons.shopping_basket_rounded)),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildStatCard("Pengguna Baru", "${stats['total_users']}", stats['users_growth'], Icons.person_add_rounded, isFullWidth: true),

            SizedBox(height: 24),

            // --- SALES CHART ---
            _buildSalesChart(),

            SizedBox(height: 32),

            // --- RECENT ACTIVITIES ---
            Text(
              "Aktivitas Terkini",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: context.colors.textDark
              ),
            ),
            SizedBox(height: 16),
            _buildActivityItem("New Order #8921", "2 menit lalu • Rp: 26.000", Icons.receipt_long_rounded),
            _buildActivityItem("Pelanggan Baru Terdaftar", "1 jam lalu • Sarah J.", Icons.person_add_alt_1_rounded),
            
                  ],
                ),
              ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.colors.bgColor,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primaryOrange.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(16)
            ),
            child: Icon(Icons.bakery_dining_rounded, color: context.colors.primaryOrange, size: 22),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("roti515", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textDark)),
              Text("Portal Admin", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.primaryOrange)),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, theme, _) => IconButton(
            icon: Icon(
              theme.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: context.colors.textDark,
            ),
            onPressed: () => theme.toggleTheme(!theme.isDarkMode),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => AdminProfileScreen()),
              );
            },
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final photoUrl = auth.photoUrl;
                final fullImageUrl = ApiService.getDisplayImage(photoUrl);
                
                return CircleAvatar(
                  backgroundColor: context.colors.primaryOrange.withValues(alpha: 0.1),
                  backgroundImage: fullImageUrl.isNotEmpty
                      ? NetworkImage(fullImageUrl)
                      : null,
                  child: fullImageUrl.isEmpty
                      ? Icon(Icons.account_circle_outlined, color: context.colors.primaryOrange)
                      : null,
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String percent, IconData icon, {bool isFullWidth = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.white,
        borderRadius: BorderRadius.circular(32), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: Offset(0, 1))],
        border: Border.all(color: context.colors.primaryOrange.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primaryOrange, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, 
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textDark)),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: context.colors.success, size: 14),
              SizedBox(width: 4),
              Text(percent, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: context.colors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return AnimatedSalesChart();
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.colors.primaryOrange.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: context.colors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: context.colors.primaryOrange, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textDark)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.colors.textGrey)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.colors.textHint),
        ],
      ),
    );
  }
}

