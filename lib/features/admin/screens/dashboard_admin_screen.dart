import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // ✅ Setup Animasi Berjalan 1.5 Detik
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Mulai animasi saat halaman dibuka
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATS ROW ---
            Row(
              children: [
                Expanded(child: _buildStatCard("Total Penjualan", "Rp. 101.500", "+12%", Icons.payments_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Total Order", "128", "+5%", Icons.shopping_basket_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard("Pengguna Baru", "45", "+18%", Icons.person_add_rounded, isFullWidth: true),

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
              color: AppColors.primaryOrange.withOpacity(0.1), 
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
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.05)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Grafik Penjualan Harian", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textGrey)),
                  Text("15.300", style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(9999)),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, color: AppColors.success, size: 12),
                    const SizedBox(width: 4),
                    Text("8.4%", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // --- GRAFIK PAINTER (ANIMASI & AREA SHADER) ---
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              size: const Size(double.infinity, 130),
              painter: _ChartLinePainter(_animation), // ✅ Memanggil pelukis grafik kita
            ),
          ),
          
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["SEN", "SEL", "RAB", "KAM", "JUM", "SAB", "MIN"].map((day) {
              return Text(day, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint));
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
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

// ✅ Custom Painter Baru dengan Cubic Curve & Smooth Gradient Area
class _ChartLinePainter extends CustomPainter {
  final Animation<double> animation;

  _ChartLinePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. ANIMASI KLIP: Menampilkan grafik dari kiri ke kanan perlahan
    canvas.clipRect(Rect.fromLTWH(0, 0, w * animation.value, h));

    final path = Path();
    
    // Titik awal (SEN)
    path.moveTo(0, h * 0.8);

    // 2. RUMUS LENGKUNGAN MULUS (Cubic Bezier)
    path.cubicTo(w * 0.05, h * 0.80, w * 0.08, h * 0.30, w * 0.16, h * 0.45); // SEL
    path.cubicTo(w * 0.24, h * 0.60, w * 0.28, h * 0.80, w * 0.33, h * 0.70); // RAB
    path.cubicTo(w * 0.38, h * 0.60, w * 0.42, h * 0.40, w * 0.50, h * 0.50); // KAM
    path.cubicTo(w * 0.58, h * 0.60, w * 0.62, h * 0.95, w * 0.66, h * 0.80); // JUM
    path.cubicTo(w * 0.72, h * 0.60, w * 0.75, h * 0.10, w * 0.83, h * 0.30); // SAB
    path.cubicTo(w * 0.90, h * 0.50, w * 0.95, h * 0.40, w * 1.00, h * 0.20); // MIN

    // 3. MENGGAMBAR BAYANGAN (AREA CHART)
    final areaPath = Path.from(path);
    areaPath.lineTo(w, h); // Tarik ke sudut kanan bawah
    areaPath.lineTo(0, h); // Tarik ke sudut kiri bawah
    areaPath.close();      // Tutup area

    // Buat efek gradasi warna
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primaryOrange.withOpacity(0.3), 
        Colors.transparent
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final areaPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);

    // 4. MENGGAMBAR GARIS UTAMA (STROKE)
    final linePaint = Paint()
      ..color = AppColors.primaryOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ChartLinePainter oldDelegate) => true; // Wajib true untuk animasi
}