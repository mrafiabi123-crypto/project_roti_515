import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_service.dart';
import '../../../core/utils/premium_snackbar.dart';
import '../../../routes/app_routes.dart';

// ─── Model akun dummy Google ──────────────────────────────────────────────────

class _GoogleAccount {
  final String name;
  final String email;
  final Color avatarColor;
  final String initials;

  const _GoogleAccount({
    required this.name,
    required this.email,
    required this.avatarColor,
    required this.initials,
  });
}

const _kDummyAccounts = [
  _GoogleAccount(
    name: 'JM 48',
    email: 'jm48@gmail.com',
    avatarColor: Color(0xFF1A73E8),
    initials: 'J',
  ),
  _GoogleAccount(
    name: 'Siti Nurhaliza',
    email: 'siti.nurh@gmail.com',
    avatarColor: Color(0xFF34A853),
    initials: 'S',
  ),
  _GoogleAccount(
    name: 'Budi Santoso',
    email: 'budi.s1990@gmail.com',
    avatarColor: Color(0xFFEA4335),
    initials: 'B',
  ),
];

// ─── Entrypoint ───────────────────────────────────────────────────────────────

Future<void> showGoogleAccountPicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GoogleAccountPickerSheet(parentContext: context),
  );
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _GoogleAccountPickerSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _GoogleAccountPickerSheet({required this.parentContext});

  @override
  State<_GoogleAccountPickerSheet> createState() =>
      _GoogleAccountPickerSheetState();
}

class _GoogleAccountPickerSheetState
    extends State<_GoogleAccountPickerSheet> {
  int? _loadingIndex;

  Future<void> _onAccountTap(int index) async {
    setState(() => _loadingIndex = index);

    try {
      final response = await http.post(
        Uri.parse(ApiService.demoLogin),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        final role = data['user']['role'] as String;
        final name = _kDummyAccounts[index].name;

        Navigator.pushReplacementNamed(
          widget.parentContext,
          AppRoutes.loginSuccess,
          arguments: {
            'token': token,
            'role': role,
            'name': name,
            'isAdmin': role == 'admin',
          },
        );
      } else {
        PremiumSnackbar.showError(
          widget.parentContext,
          data['error'] ?? 'Gagal masuk dengan akun Google',
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        PremiumSnackbar.showError(
          widget.parentContext,
          'Gagal terhubung ke server.',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final dividerColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE0E0E0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F1F1F);
    final textSecondary =
        isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DragHandle(color: dividerColor),

            // Header Google
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  CustomPaint(
                    size: const Size(28, 28),
                    painter: _GoogleLogoPainter(),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk dengan Google',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Pilih akun untuk melanjutkan ke roti515',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: dividerColor),

            // Daftar akun
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _kDummyAccounts.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, indent: 72, color: dividerColor),
              itemBuilder: (_, i) => _AccountTile(
                account: _kDummyAccounts[i],
                isLoading: _loadingIndex == i,
                isDisabled: _loadingIndex != null && _loadingIndex != i,
                onTap: () => _onAccountTap(i),
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),

            Divider(height: 1, color: dividerColor),

            // Gunakan akun lain
            InkWell(
              onTap: _loadingIndex != null ? null : () => _onAccountTap(0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: dividerColor, width: 1.5),
                      ),
                      child: const Icon(Icons.add,
                          size: 20, color: Color(0xFF1A73E8)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Gunakan akun lain',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A73E8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer privasi
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'Sebelum menggunakan aplikasi ini, pastikan kamu memahami '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF1A73E8),
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' dan '),
                    TextSpan(
                      text: 'Syarat Layanan',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF1A73E8),
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' Google.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tile akun ────────────────────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  final _GoogleAccount account;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;

  const _AccountTile({
    required this.account,
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.4 : 1.0,
      child: InkWell(
        onTap: isLoading || isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: account.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    account.initials,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        )),
                    Text(account.email,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: textSecondary,
                        )),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF1A73E8)),
                )
              else
                Icon(Icons.chevron_right, color: textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Handle bar ───────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  final Color color;
  const _DragHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─── Google G Logo Painter (path SVG resmi, viewBox 24×24) ───────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24.0, size.height / 24.0);

    final p = Paint()..style = PaintingStyle.fill;

    // Biru — kanan + strip horizontal
    p.color = const Color(0xFF4285F4);
    canvas.drawPath(_bluePath, p);

    // Hijau — bawah kanan
    p.color = const Color(0xFF34A853);
    canvas.drawPath(_greenPath, p);

    // Kuning — kiri
    p.color = const Color(0xFFFBBC05);
    canvas.drawPath(_yellowPath, p);

    // Merah — atas
    p.color = const Color(0xFFEA4335);
    canvas.drawPath(_redPath, p);
  }

  static final _bluePath = Path()
    ..moveTo(22.56, 12.25)
    ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
    ..lineTo(12, 10.0)
    ..lineTo(12, 14.26)
    ..lineTo(17.92, 14.26)
    ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
    ..lineTo(15.71, 20.34)
    ..lineTo(19.28, 20.34)
    ..cubicTo(21.36, 18.42, 22.56, 15.60, 22.56, 12.25)
    ..close();

  static final _greenPath = Path()
    ..moveTo(12, 23)
    ..cubicTo(14.97, 23, 17.46, 22.02, 19.28, 20.34)
    ..lineTo(15.71, 17.57)
    ..cubicTo(14.73, 18.23, 13.48, 18.63, 12, 18.63)
    ..cubicTo(9.14, 18.63, 6.71, 16.70, 5.84, 14.10)
    ..lineTo(2.18, 14.10)
    ..lineTo(2.18, 16.94)
    ..cubicTo(3.99, 20.53, 7.7, 23, 12, 23)
    ..close();

  static final _yellowPath = Path()
    ..moveTo(5.84, 14.09)
    ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12.00)
    ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
    ..lineTo(5.84, 7.07)
    ..lineTo(2.18, 7.07)
    ..cubicTo(1.43, 8.55, 1, 10.22, 1, 12)
    ..cubicTo(1, 13.78, 1.43, 15.45, 2.18, 16.93)
    ..lineTo(5.03, 14.71)
    ..lineTo(5.84, 14.09)
    ..close();

  static final _redPath = Path()
    ..moveTo(12, 5.38)
    ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
    ..lineTo(19.36, 3.87)
    ..cubicTo(17.45, 2.09, 14.97, 1, 12, 1)
    ..cubicTo(7.7, 1, 3.99, 3.47, 2.18, 7.07)
    ..lineTo(5.84, 9.91)
    ..cubicTo(6.71, 7.31, 9.14, 5.38, 12, 5.38)
    ..close();

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
