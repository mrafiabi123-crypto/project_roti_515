import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryOrange;
  final Color bgColor;
  final Color authBackground;
  final Color white;
  final Color surface;
  final Color divider;
  final Color textDark;
  final Color textBrown;
  final Color textGrey;
  final Color textHint;
  final Color error;
  final Color success;
  final Color googleBlue;

  const AppColorsExtension({
    required this.primary,
    required this.primaryOrange,
    required this.bgColor,
    required this.authBackground,
    required this.white,
    required this.surface,
    required this.divider,
    required this.textDark,
    required this.textBrown,
    required this.textGrey,
    required this.textHint,
    required this.error,
    required this.success,
    required this.googleBlue,
  });

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryOrange,
    Color? bgColor,
    Color? authBackground,
    Color? white,
    Color? surface,
    Color? divider,
    Color? textDark,
    Color? textBrown,
    Color? textGrey,
    Color? textHint,
    Color? error,
    Color? success,
    Color? googleBlue,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryOrange: primaryOrange ?? this.primaryOrange,
      bgColor: bgColor ?? this.bgColor,
      authBackground: authBackground ?? this.authBackground,
      white: white ?? this.white,
      surface: surface ?? this.surface,
      divider: divider ?? this.divider,
      textDark: textDark ?? this.textDark,
      textBrown: textBrown ?? this.textBrown,
      textGrey: textGrey ?? this.textGrey,
      textHint: textHint ?? this.textHint,
      error: error ?? this.error,
      success: success ?? this.success,
      googleBlue: googleBlue ?? this.googleBlue,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryOrange: Color.lerp(primaryOrange, other.primaryOrange, t)!,
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      authBackground: Color.lerp(authBackground, other.authBackground, t)!,
      white: Color.lerp(white, other.white, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textBrown: Color.lerp(textBrown, other.textBrown, t)!,
      textGrey: Color.lerp(textGrey, other.textGrey, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      googleBlue: Color.lerp(googleBlue, other.googleBlue, t)!,
    );
  }
}

// Skema Warna Mode Terang
final _lightColors = AppColorsExtension(
  primary: Color(0xFFD47311),
  primaryOrange: Color(0xFFD47311),
  bgColor: Color(0xFFFCFAF8),
  authBackground: Color(0xFFF8F7F6),
  white: Colors.white,
  surface: Color(0xFFF3F4F6), 
  divider: Color(0xFFE5E7EB),
  textDark: Color(0xFF1F2937), 
  textBrown: Color(0xFF5D4037),
  textGrey: Color(0xFF6B7280),
  textHint: Color(0xFFA8A29E),
  error: Color(0xFFEF4444), 
  success: Color(0xFF10B981), 
  googleBlue: Color(0xFF4285F4),
);

// Skema Warna Mode Gelap
final _darkColors = AppColorsExtension(
  primary: Color(0xFFD47311), 
  primaryOrange: Color(0xFFD47311),
  bgColor: Color(0xFF121212), // Gelap pekat
  authBackground: Color(0xFF1E1E1E), 
  white: Color(0xFF1E1E1E), // Permukaan yang tadinya putih jadi abu gelap
  surface: Color(0xFF2C2C2C), 
  divider: Color(0xFF333333),
  textDark: Color(0xFFF9FAFB), // Teks gelap menjadi putih/terang
  textBrown: Color(0xFFEFEBE9), 
  textGrey: Color(0xFF9CA3AF),
  textHint: Color(0xFF6B7280),
  error: Color(0xFFEF4444), 
  success: Color(0xFF10B981), 
  googleBlue: Color(0xFF4285F4),
);

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _lightColors.primaryOrange,
      scaffoldBackgroundColor: _lightColors.bgColor,
      fontFamily: 'Plus Jakarta Sans',
      extensions: <ThemeExtension<dynamic>>[
        _lightColors,
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightColors.primaryOrange, 
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _darkColors.primaryOrange,
      scaffoldBackgroundColor: _darkColors.bgColor,
      fontFamily: 'Plus Jakarta Sans',
      extensions: <ThemeExtension<dynamic>>[
        _darkColors,
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkColors.primaryOrange, 
        brightness: Brightness.dark,
      ),
    );
  }
}

// Ekstensi untuk mempermudah akses ke warna: context.colors.primaryOrange
extension AppThemeExtension on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}
