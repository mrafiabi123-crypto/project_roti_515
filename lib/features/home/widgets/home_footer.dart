import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Seksi
          Text(
            "Our Location & Socials",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // 1. BAGIAN PETA (Interactive Map or Fallback Image)
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: _MapContentView(),
                ),
              ),
              // Overlay Button Maps
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Maps",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF0F172A)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. KARTU ALAMAT (Visit Us)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "VISIT US",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Jl. Artisan No. 515, Jakarta Selatan",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 3. MEDIA SOSIAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Follow us",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Row(
                children: [
                  _buildSocialBtn(FontAwesomeIcons.instagram, const Color(0xfffdf2f2), const Color(0xffe1306c)), // IG
                  const SizedBox(width: 12),
                  _buildSocialBtn(FontAwesomeIcons.facebook, const Color(0xffeff6ff), const Color(0xff1877f2)), // FB
                  const SizedBox(width: 12),
                  _buildSocialBtn(FontAwesomeIcons.whatsapp, const Color(0xfff0fdf4), const Color(0xff25d366)), // WA
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          
          Center(
            child: Text(
              "© 2026 Roti 515 - Baked with Passion",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

class _MapContentView extends StatelessWidget {
  const _MapContentView();

  // URL Google Maps untuk dibuka di aplikasi/browser
  final String _googleMapsUrl = 'https://maps.app.goo.gl/sK5XzhsLK179oXfw6';

  Future<void> _launchMaps() async {
    final Uri url = Uri.parse(_googleMapsUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const HtmlElementView(viewType: 'google-maps-embed');
    }
    
    // Tampilan untuk Android/iOS
    return GestureDetector(
      onTap: _launchMaps, // Tekan untuk buka Google Maps asli
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/map_colored.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: Icon(Icons.map_outlined, color: Color(0xFF94A3B8), size: 40),
              ),
            ),
          ),
          // Indikator bahwa ini bisa diklik
          Container(
            color: Colors.black.withValues(alpha: 0.05),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Klik untuk Petunjuk Arah",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
