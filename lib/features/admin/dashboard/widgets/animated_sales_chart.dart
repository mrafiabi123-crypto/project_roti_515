import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/admin_stats_provider.dart';

class AnimatedSalesChart extends StatefulWidget {
  const AnimatedSalesChart({super.key});

  @override
  State<AnimatedSalesChart> createState() => _AnimatedSalesChartState();
}

class _AnimatedSalesChartState extends State<AnimatedSalesChart> {
  // Helper untuk memformat bulan ke bahasa Indonesia
  String _formatMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    return months[month - 1];
  }

  // Helper untuk memformat tanggal ke "DD MMM 2026"
  String _formatFullDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.day} ${_formatMonth(dt.month)} 2026";
    } catch (_) {
      return dateStr;
    }
  }

  // Helper untuk memformat tanggal ke "DD MMM"
  String _formatShortDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.day} ${_formatMonth(dt.month)}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<AdminStatsProvider>(context);
    final rawDailyStats = statsProvider.stats['daily_stats'] as List<dynamic>;
    
    // Siapkan spots dan labels dari data provider
    final List<FlSpot> spots = [];
    final List<String> days = [];
    double maxRevenue = 1.0;

    if (rawDailyStats.isEmpty) {
      // Fallback jika data kosong (tampilkan flat line)
      for (int i = 0; i < 7; i++) {
        spots.add(FlSpot(i.toDouble(), 0));
        days.add("-");
      }
    } else {
      for (int i = 0; i < rawDailyStats.length; i++) {
        final double rev = (rawDailyStats[i]['revenue'] as num).toDouble();
        // Skala revenue (misal / 10.000 agar muat di chart y-axis 0-10)
        spots.add(FlSpot(i.toDouble(), rev / 10000)); 
        days.add(_formatShortDate(rawDailyStats[i]['date']));
        if (rev / 10000 > maxRevenue) maxRevenue = rev / 10000;
      }
    }

    final chartMaxY = (maxRevenue * 1.2).clamp(5.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grafik Penjualan Harian 2026",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                    ),
                  ),
                  Text(
                    statsProvider.stats['total_sales'] != null 
                        ? "Rp ${(statsProvider.stats['total_sales'] as num).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"
                        : "Rp 0",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, color: AppColors.success, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statsProvider.stats['sales_growth'] ?? "0%",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Interaktif Drag/Scroll Chart dengan Animasi Naik
          SizedBox(
            height: 180, 
            width: double.infinity,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Mulai dari sisi paling kanan (data hari ini)
                controller: ScrollController(),
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                   width: (days.length * 60).clamp(350, 2000).toDouble(), 
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.elasticOut, 
                    builder: (context, animValue, child) {
                      final animatedSpots = spots.map((spot) {
                        return FlSpot(spot.x, spot.y * animValue);
                      }).toList();

                      return LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => AppColors.primaryOrange,
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final rawDate = rawDailyStats.isNotEmpty ? rawDailyStats[spot.x.toInt()]['date'] : "-";
                                  return LineTooltipItem(
                                    'Rp ${(spot.y * 10).toStringAsFixed(1)}K\n',
                                    GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _formatFullDate(rawDate),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        days[value.toInt()],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: animatedSpots,
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: AppColors.primaryOrange,
                              barWidth: 3.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: AppColors.primaryOrange,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryOrange.withValues(alpha: 0.4),
                                    AppColors.primaryOrange.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          minX: 0,
                          maxX: (days.length - 1).toDouble().clamp(0, double.infinity),
                          minY: 0,
                          maxY: chartMaxY, 
                        ),
                        duration: const Duration(milliseconds: 0), 
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
