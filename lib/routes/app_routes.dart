import 'package:flutter/material.dart';

// --- IMPORT SEMUA SCREEN ---
import '../features/main_nav/screens/main_nav_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/cart/screens/checkout_screen.dart';
import '../features/cart/screens/checkout_success_screen.dart';
// ✅ Tambahkan import untuk halaman Admin
import '../features/admin/dashboard/screens/admin_main_nav_screen.dart'; 
// Import login success screen
import '../features/auth/screens/login_success_screen.dart';
// Import register success screen
import '../features/auth/screens/register_success_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';

class AppRoutes {
  // 1. DAFTAR NAMA RUTE (String)
  static const String mainNav = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout-success';
  // ✅ Tambahkan nama rute Admin
  static const String adminDashboard = '/admin_dashboard'; 
  
  static const String loginSuccess = '/login-success';
  static const String registerSuccess = '/register-success';
  static const String forgotPassword = '/forgot-password';

  // 2. BUKU TELEPON (Mapping Rute ke Screen)
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      mainNav: (context) => const MainNavScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      cart: (context) => const CartScreen(),
      checkout: (context) => const CheckoutScreen(),
      checkoutSuccess: (context) {
        final ref = ModalRoute.of(context)!.settings.arguments as String?;
        return CheckoutSuccessScreen(
          orderRef: ref ?? generateOrderRef(),
        );
      },
      // ✅ Daftarkan halaman Admin ke dalam peta navigasi
      adminDashboard: (context) => const AdminMainNavScreen(), 
      loginSuccess: (context) => const LoginSuccessScreen(),
      registerSuccess: (context) => const RegisterSuccessScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
    };
  }
}