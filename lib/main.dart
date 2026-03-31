import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT PONDASI ---
import 'core/constants/app_colors.dart';
import 'routes/app_routes.dart';

// --- IMPORT PROVIDERS ---
import 'features/auth/providers/auth_provider.dart';
import 'features/product/providers/product_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/favorite/providers/favorite_provider.dart'; 
import 'features/admin/product_admin/providers/admin_product_provider.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Aktif hanya saat debug
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => MultiProvider(
        providers: [
          // 1. Product Provider
          ChangeNotifierProvider(create: (_) => ProductProvider()),

          // 2. Cart Provider (Keranjang Belanja)
          ChangeNotifierProvider(create: (_) => CartProvider()),

          // 3. Auth Provider (Login/Register)
          ChangeNotifierProvider(create: (_) => AuthProvider()),

          // 4. Favorite Provider (Favorit Roti)
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (context) => AdminProductProvider()),
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
      
      // --- SISTEM NAVIGASI TERPUSAT ---
      initialRoute: AppRoutes.mainNav, // Titik awal aplikasi (Bottom Nav)
      routes: AppRoutes.getRoutes(),   // Memanggil "Buku Telepon" rute
    );
  }
}