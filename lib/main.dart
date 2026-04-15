import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/web_loader.dart';

// --- IMPORT PONDASI ---
import 'core/constants/app_colors.dart';
import 'routes/app_routes.dart';

// --- IMPORT PROVIDERS ---
import 'features/auth/providers/auth_provider.dart';
import 'features/product/providers/product_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/favorite/providers/favorite_provider.dart'; 
import 'features/admin/product_admin/providers/admin_product_provider.dart';
import 'features/admin/orders/providers/order_admin_provider.dart';
import 'features/admin/users/providers/user_admin_provider.dart';
import 'features/notification/providers/notification_provider.dart';
import 'features/admin/dashboard/providers/admin_stats_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib untuk async main

  final authProvider = AuthProvider();
  await authProvider.loadSession(); // Load data dari storage

  // Daftarkan IFrame jika di Web (Logika dihandle secara kondisional di web_loader)
  registerWebIframe();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider.value(value: authProvider), // Gunakan instance yang sudah diload
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => AdminProductProvider()),
          ChangeNotifierProvider(create: (_) => OrderAdminProvider()),
          ChangeNotifierProvider(create: (_) => UserAdminProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AdminStatsProvider()),
        ],
        child: const FoodDiscoveryApp(),
      ),
    ),
  );
}

class FoodDiscoveryApp extends StatelessWidget {
  const FoodDiscoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Roti 515', // Nama aplikasi diperbarui
      theme: ThemeData(
        // Menggunakan sinkronisasi warna dari AppColors
        primaryColor: AppColors.primaryOrange,
        scaffoldBackgroundColor: AppColors.bgColor,
        useMaterial3: true,
        fontFamily: 'Plus Jakarta Sans', 
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryOrange),
      ),
      
      // --- SISTEM NAVIGASI OTOMATIS BERDASARKAN SESI ---
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isLoggedIn) {
            // Jika belum login, ke halaman Login
            return AppRoutes.getRoutes()[AppRoutes.login]!(context);
          }
          
          // Jika sudah login, cek role untuk menentukan Dashboard
          if (auth.isAdmin) {
             return AppRoutes.getRoutes()[AppRoutes.adminDashboard]!(context);
          } else {
             return AppRoutes.getRoutes()[AppRoutes.mainNav]!(context);
          }
        },
      ),

      routes: AppRoutes.getRoutes()..remove(AppRoutes.mainNav),
    );
  }
}