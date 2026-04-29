import 'package:device_preview/device_preview.dart'; // Digunakan untuk melihat tampilan aplikasi di berbagai ukuran layar HP
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Paket utama Flutter untuk desain Material
import 'package:provider/provider.dart'; // Paket untuk State Management
import 'core/utils/web_loader.dart'; // Utilitas khusus untuk loading di Web

// --- IMPORT KONSTANTA DAN RUTE ---
// Warna-warna brand aplikasi
import 'routes/app_routes.dart'; // Daftar rute navigasi aplikasi

// --- IMPORT SEMUA PROVIDER (Pusat Logika) ---
import 'features/auth/providers/auth_provider.dart';
import 'features/product/providers/product_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/favorite/providers/favorite_provider.dart';
import 'features/admin/product_admin/providers/admin_product_provider.dart';
import 'features/admin/orders/providers/order_admin_provider.dart';
import 'features/admin/users/providers/user_admin_provider.dart';
import 'features/notification/providers/notification_provider.dart';
import 'features/admin/dashboard/providers/admin_stats_provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/premium_snackbar.dart'; // import global key untuk snackbar

/// Titik awal (Entry Point) aplikasi dijalankan
void main() async {
  // Memastikan binding Flutter sudah siap sebelum menjalankan fungsi async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi AuthProvider di awal untuk mengecek sesi login yang tersimpan
  final authProvider = AuthProvider();
  await authProvider.loadSession(); // Mengambil token login dari penyimpanan HP

  // Mendaftarkan IFrame jika aplikasi dijalankan di browser (Web)
  registerWebIframe();

  runApp(
    DevicePreview(
      // DevicePreview hanya aktif saat dalam mode debug (bukan rilis)
      enabled: !kReleaseMode,
      backgroundColor: Color(0xFF1E1E1E),
      builder: (context) => MultiProvider(
        // Mendaftarkan semua Provider agar bisa diakses di seluruh halaman aplikasi
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          // Menggunakan instance authProvider yang sudah diload sesinya tadi
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => AdminProductProvider()),
          ChangeNotifierProvider(create: (_) => OrderAdminProvider()),
          ChangeNotifierProvider(create: (_) => UserAdminProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AdminStatsProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: FoodDiscoveryApp(),
      ),
    ),
  );
}

class FoodDiscoveryApp extends StatelessWidget {
  const FoodDiscoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, // <- INI YANG HILANG
      debugShowCheckedModeBanner:
          false, // Menghilangkan banner "DEBUG" di pojok kanan atas
      locale: DevicePreview.locale(
        context,
      ), // Mengatur lokasi tampilan sesuai DevicePreview
      builder: DevicePreview.appBuilder,
      title:
          'Roti 515', // Judul aplikasi yang muncul di daftar aplikasi terbaru
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // --- SISTEM NAVIGASI ---
      initialRoute: AppRoutes.splash,

      // Bagian ini menentukan halaman pertama apa yang muncul (Auth Wrapper)
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 1. Cek apakah user sudah login?
          if (!auth.isLoggedIn) {
            // Jika belum login, paksa masuk ke halaman Login
            return AppRoutes.getRoutes()[AppRoutes.login]!(context);
          }

          // 2. Jika sudah login, cek role/perannya
          if (auth.isAdmin) {
            // Jika dia Admin, tampilkan Dashboard Admin
            return AppRoutes.getRoutes()[AppRoutes.adminDashboard]!(context);
          } else {
            // Jika dia Customer biasa, tampilkan halaman Navigasi Utama (Home)
            return AppRoutes.getRoutes()[AppRoutes.mainNav]!(context);
          }
        },
      ),

      // Mendaftarkan rute navigasi lain yang tersedia di aplikasi
      routes: AppRoutes.getRoutes()..remove(AppRoutes.mainNav),
    );
  }
}
