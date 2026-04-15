import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Halaman sukses yang ditampilkan setelah user berhasil registrasi.
class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen>
    with TickerProviderStateMixin {
  // Animasi lingkaran sukses muncul (scale + fade)
  late final AnimationController _circleCtrl;
  late final Animation<double> _circleScale;
  late final Animation<double> _circleFade;

  // Animasi teks muncul dari bawah
  late final AnimationController _textCtrl;
  late final Animation<double> _textSlide;
  late final Animation<double> _textFade;

  // Animasi tombol muncul
  late final AnimationController _btnCtrl;
  late final Animation<double> _btnFade;
  late final Animation<double> _btnSlide;

  @override
  void initState() {
    super.initState();

    _circleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _circleScale = CurvedAnimation(
      parent: _circleCtrl,
      curve: Curves.elasticOut,
    );
    _circleFade = CurvedAnimation(
      parent: _circleCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlide = Tween<double>(begin: 30, end: 0)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_textCtrl);
    _textFade = CurvedAnimation(
      parent: _textCtrl,
      curve: Curves.easeOut,
    );

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _btnFade = CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut);
    _btnSlide = Tween<double>(begin: 20, end: 0)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_btnCtrl);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _circleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _btnCtrl.forward();
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _textCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RadialBgPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                ScaleTransition(
                  scale: _circleScale,
                  child: FadeTransition(
                    opacity: _circleFade,
                    child: const _SuccessIcon(),
                  ),
                ),

                const SizedBox(height: 32),

                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: FadeTransition(
                      opacity: _textFade,
                      child: child,
                    ),
                  ),
                  child: const _RegisterInfo(),
                ),

                const Spacer(flex: 3),

                AnimatedBuilder(
                  animation: _btnCtrl,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _btnSlide.value),
                    child: FadeTransition(
                      opacity: _btnFade,
                      child: child,
                    ),
                  ),
                  child: _BottomActions(
                    onNext: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.75,
        colors: [
          const Color(0xFFD47311).withValues(alpha: 0.06),
          const Color(0xFFD47311).withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF22C55E);

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: greenColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: greenColor,
        size: 50,
      ),
    );
  }
}

class _RegisterInfo extends StatelessWidget {
  const _RegisterInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Registrasi Berhasil',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            height: 40 / 32,
          ),
        ),
        const SizedBox(height: 8),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Selamat bergabung dengan ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 28 / 18,
                ),
              ),
              TextSpan(
                text: 'roti515',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatefulWidget {
  final VoidCallback onNext;
  const _BottomActions({required this.onNext});

  @override
  State<_BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends State<_BottomActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pressCtrl);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    await _pressCtrl.forward();
    await _pressCtrl.reverse();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handlePress,
            child: ScaleTransition(
              scale: _pressScale,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Lanjut ke Login',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 0.4,
                      height: 24 / 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'roti515',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}
