import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roti_515/core/theme/app_theme.dart';


class HomePromoBanner extends StatefulWidget {
  final VoidCallback? onPesanSekarang;

  const HomePromoBanner({super.key, this.onPesanSekarang});

  @override
  State<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends State<HomePromoBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _images = [
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80', // Roti artisan rustic
    'https://images.unsplash.com/photo-1542826438-bd32f43d626f?auto=format&fit=crop&w=800&q=80', // Breads and bakery
    'https://images.unsplash.com/photo-1534620808146-d33bb39128b2?auto=format&fit=crop&w=800&q=80', // Bread loaf
    'https://images.unsplash.com/photo-1495147466023-ac5c588e2e94?auto=format&fit=crop&w=800&q=80', // Beautiful pastry
  ];

  @override
  void initState() {
    super.initState();
    // Memulai timer untuk mengganti gambar otomatis setiap 5 detik
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colors.textDark.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: Offset(0, 10),
            )
          ],
        ),
        // Memotong (clipping) agar PageView tidak keluar dari border radius 24
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // --- 1. Carousel Gambar Belakang ---
              PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    _images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),

              // --- 2. Gradien Gelap Penutup Depan ---
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colors.textDark.withValues(alpha: 0.85),
                        Colors.transparent
                      ],
                      begin: Alignment.centerLeft,
                    ),
                  ),
                ),
              ),

              // --- 3. Posisi Teks & Tombol di depan ---
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 320,
                        child: Text(
                          '"Roti 515: Hangat dari oven, hadir untuk harimu."',
                          style: GoogleFonts.plusJakartaSans(
                            color: context.colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: widget.onPesanSekarang, // Aksi pindah layar
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: context.colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: [
                              BoxShadow(
                                  color: context.colors.textDark
                                      .withValues(alpha: 0.1),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Text(
                            "Pesan Sekarang",
                            style: GoogleFonts.plusJakartaSans(
                              color: context.colors.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 4. Indikator Titik (Dots) di Kanan Bawah ---
              Positioned(
                bottom: 24,
                right: 24,
                child: Row(
                  children: List.generate(
                    _images.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(left: 5),
                      height: 6,
                      width: _currentPage == index ? 22 : 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? context.colors.primaryOrange
                            : context.colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
