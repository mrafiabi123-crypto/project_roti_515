import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_service.dart';

class AdminStatsProvider extends ChangeNotifier {
  Map<String, dynamic> _stats = {
    "total_sales": 0,
    "total_orders": 0,
    "total_users": 0,
    "sales_growth": "0%",
    "orders_growth": "0%",
    "users_growth": "0%",
    "daily_stats": <Map<String, dynamic>>[],
  };
  bool _isLoading = true;
  Timer? _pollingTimer;

  // Token disimpan agar refreshNow() bisa digunakan tanpa passing token
  String? _cachedToken;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  void startPolling(String? token) {
    _cachedToken = token;
    fetchStats(token);
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchStats(token, silent: true);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Refresh statistik secara langsung (dipanggil setelah admin selesaikan order)
  Future<void> refreshNow() async {
    await fetchStats(_cachedToken, silent: true);
  }

  Future<void> fetchStats(String? token, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await http.get(
        Uri.parse(ApiService.adminStats),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ambil growth dari backend jika tersedia, fallback ke '+0%'
        final String salesGrowth = _parseGrowth(data['sales_growth']);
        final String ordersGrowth = _parseGrowth(data['orders_growth']);
        final String usersGrowth = _parseGrowth(data['users_growth']);

        _stats = {
          "total_sales": data['revenue'] ?? data['total_revenue'] ?? 0,
          "total_orders": data['total_order'] ?? data['total_orders'] ?? 0,
          "total_users": data['new_users'] ?? 0,
          "sales_growth": salesGrowth,
          "orders_growth": ordersGrowth,
          "users_growth": usersGrowth,
          "daily_stats": data['daily_stats'] ?? [],
        };
      }
    } catch (e) {
      debugPrint("Error fetching stats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parsing nilai growth dari API — bisa berupa String atau angka
  String _parseGrowth(dynamic raw) {
    if (raw == null) return '+0%';
    if (raw is String) {
      // Pastikan diawali '+' jika positif
      if (raw.startsWith('+') || raw.startsWith('-')) return raw;
      return '+$raw';
    }
    if (raw is num) {
      final sign = raw >= 0 ? '+' : '';
      return '$sign${raw.toStringAsFixed(0)}%';
    }
    return '+0%';
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
