import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT STATE MANAGEMENT ---
import 'presentation/state/auth_provider.dart';
import 'presentation/state/product_provider.dart';
import 'presentation/state/cart_provider.dart';

// --- IMPORT HALAMAN UTAMA ---
import 'presentation/pages/main_nav/main_nav_page.dart'; 

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Aktif hanya saat debug
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => MultiProvider(
        providers: [
          // 1. Food Provider (SUDAH DIPERBAIKI)
          // Tidak perlu repository lagi, cukup panggil FoodProvider()
          ChangeNotifierProvider(
            create: (_) => ProductProvider(),
          ),

          // 2. Cart Provider (Keranjang Belanja)
          ChangeNotifierProvider(
            create: (_) => CartProvider(),
          ),

          // 3. Auth Provider (Login/Register)
          ChangeNotifierProvider(
            create: (_) => AuthProvider()
          ),
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
      title: 'Food Discovery',
      theme: ThemeData(
        // Warna Utama Aplikasi (Oranye)
        primaryColor: const Color(0xFFEC4913),
        // Warna Latar Belakang
        scaffoldBackgroundColor: const Color(0xFFF8F6F6),
        useMaterial3: true,
        fontFamily: 'Plus Jakarta Sans', 
      ),
      home: const MainNavPage(), // Masuk ke Halaman Navigasi Bawah
    );
  }
}