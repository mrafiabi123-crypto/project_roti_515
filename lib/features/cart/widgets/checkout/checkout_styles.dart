import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── TextStyle helpers ─────────────────────────────────────────────────────────

TextStyle jakartaBold(double size, Color color, {double? height}) =>
    GoogleFonts.plusJakartaSans(
        fontSize: size, fontWeight: FontWeight.w700, color: color, height: height);

TextStyle jakartaRegular(double size, Color color, {double? height}) =>
    GoogleFonts.plusJakartaSans(
        fontSize: size, fontWeight: FontWeight.w400, color: color, height: height);

TextStyle jakartaMedium(double size, Color color) =>
    GoogleFonts.plusJakartaSans(
        fontSize: size, fontWeight: FontWeight.w500, color: color);

TextStyle pontano(double size, Color color,
        {FontWeight weight = FontWeight.w500}) =>
    GoogleFonts.pontanoSans(fontSize: size, fontWeight: weight, color: color);

// ── Shared constants ──────────────────────────────────────────────────────────

final kSectionPadding = EdgeInsets.only(left: 20, right: 20, bottom: 24);

final kCardShadow = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))
];

// ── Reusable widget ───────────────────────────────────────────────────────────

/// Ikon lingkaran berwarna (avatar-style).
class CircleIconWidget extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;
  final EdgeInsets? margin;

  const CircleIconWidget({
    super.key,
    required this.icon,
    required this.bg,
    required this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        margin: margin,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      );
}
