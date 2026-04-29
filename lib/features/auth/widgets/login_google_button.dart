import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:roti_515/core/theme/app_theme.dart';

import '../../../core/network/api_service.dart';
import '../../../core/utils/premium_snackbar.dart';
import '../../../routes/app_routes.dart';

/// Tombol "Masuk dengan Google" yang memanggil Google Sign-In asli.
class LoginGoogleButton extends StatefulWidget {
  const LoginGoogleButton({super.key});

  @override
  State<LoginGoogleButton> createState() => _LoginGoogleButtonState();
}

class _LoginGoogleButtonState extends State<LoginGoogleButton> {
  bool _isLoading = false;

  // Konfigurasi Google Sign In.
  static const String _clientId = '492758926071-hmumclc4o1vh96fdfup6s66ij8fr6pvr.apps.googleusercontent.com';

  late GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? _clientId : null,
      scopes: const [
        'email',
        'profile',
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        if (!mounted) return;
        PremiumSnackbar.showError(context, "Gagal mendapatkan token dari Google.");
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/auth/google'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_token": idToken}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final String token = data['token'];
        final String userRole = data['user']['role'];
        final String userName = data['user']['name'];

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.loginSuccess,
          arguments: {
            'token': token,
            'role': userRole,
            'name': userName,
            'isAdmin': userRole == 'admin',
          },
        );
      } else {
        PremiumSnackbar.showError(
          context,
          data['error'] ?? "Gagal memverifikasi login Google",
        );
        await _googleSignIn.signOut();
      }
    } catch (e) {
      if (mounted) {
        PremiumSnackbar.showError(context, "Terjadi kesalahan sistem saat login Google.");
        await _googleSignIn.signOut();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleGoogleSignIn,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.orange,
                ),
              )
            else
              const Icon(Icons.login, color: Colors.orange),
            const SizedBox(width: 12),
            Text(
              _isLoading ? 'Memproses...' : 'Masuk dengan Google',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.colors.textDark,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
