import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class PremiumSnackbar {
  static void showSuccess(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: Color(0xFF0F172A), // Dark Navy
      icon: Icons.check_circle_rounded,
      accentColor: Color(0xFF10B981), // Emerald
    );
  }

  static void showSuccessMessenger(ScaffoldMessengerState? messenger, String message) {
    _show(
      message: message,
      backgroundColor: Color(0xFF0F172A),
      icon: Icons.check_circle_rounded,
      accentColor: Color(0xFF10B981),
    );
  }

  static void showError(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: Color(0xFF0F172A),
      icon: Icons.error_rounded,
      accentColor: Color(0xFFEF4444), // Rose
    );
  }

  static void showErrorMessenger(ScaffoldMessengerState? messenger, String message) {
    _show(
      message: message,
      backgroundColor: Color(0xFF0F172A),
      icon: Icons.error_rounded,
      accentColor: Color(0xFFEF4444),
    );
  }

  static void showInfo(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: Color(0xFF0F172A),
      icon: Icons.info_rounded,
      accentColor: Color(0xFF3B82F6), // Blue
    );
  }

  static void _show({
    BuildContext? context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Color accentColor,
  }) {
    final messenger = (context != null && context.mounted) 
        ? ScaffoldMessenger.maybeOf(context) 
        : scaffoldMessengerKey.currentState;

    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor, // Premium dark background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
