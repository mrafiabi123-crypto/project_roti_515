import 'package:flutter/material.dart';
import 'dart:async';
import 'package:roti_515/core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shineController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Kontroler untuk Logo Muncul
    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(0.0, 0.8, curve: Curves.easeOutExpo),
      ),
    );

    // 2. Kontroler untuk Efek Kilauan (Shine)
    _shineController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _shineAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Jalankan urutan animasi
    _entranceController.forward().then((_) {
      _shineController.forward();
    });

    // Navigasi otomatis setelah 3.2 detik
    Timer(Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              context.colors.bgColor,
              context.colors.surface.withValues(alpha: 0.5),
            ],
            center: Alignment.center,
            radius: 1.0,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_entranceController, _shineController]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [
                          _shineAnimation.value - 0.5,
                          _shineAnimation.value,
                          _shineAnimation.value + 0.5,
                        ],
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.srcATop,
                    child: child,
                  ),
                ),
              );
            },
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark 
                ? 'assets/images/brand_logo_dark.png' 
                : 'assets/images/brand_logo.png',
              width: Theme.of(context).brightness == Brightness.dark ? 160 : 320, 
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
