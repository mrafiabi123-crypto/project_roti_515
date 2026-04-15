import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_service.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _error = '';

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Ambil notifikasi dari server. Token diambil langsung dari AuthProvider.
  Future<void> fetchNotifications(String? token) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    if (token == null || token.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return; // Guest, tidak perlu fetch
    }

    try {
      final response = await http.get(
        Uri.parse(ApiService.notifications),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _notifications = data.map((n) => NotificationModel.fromJson(n)).toList();
      } else {
        _error = 'Gagal memuat notifikasi (${response.statusCode})';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan jaringan.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id, String? token) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      final oldNotif = _notifications[index];
      _notifications[index] = NotificationModel(
        id: oldNotif.id,
        userId: oldNotif.userId,
        title: oldNotif.title,
        message: oldNotif.message,
        isRead: true,
        createdAt: oldNotif.createdAt,
      );
      notifyListeners();

      try {
        if (token != null) {
          await http.put(
            Uri.parse('${ApiService.notifications}/$id/read'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      } catch (e) {
        // Optimistic update - abaikan error
      }
    }
  }
}
