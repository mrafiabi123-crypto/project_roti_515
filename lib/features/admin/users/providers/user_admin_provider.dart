import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_service.dart';
import '../../../auth/models/user_model.dart';

enum UserLoadState { idle, loading, success, error }

class UserAdminProvider extends ChangeNotifier {
  List<UserModel> _allUsers = [];
  UserLoadState _loadState = UserLoadState.idle;
  String _errorMessage = '';
  
  // Tab aktif: 0=Semua, 1=Admin, 2=Pelanggan
  int _activeTab = 0;
  String _searchQuery = '';

  String? _authToken;

  UserLoadState get loadState => _loadState;
  String get errorMessage => _errorMessage;
  int get activeTab => _activeTab;
  int get totalUsers => _allUsers.length;

  List<UserModel> get filteredUsers {
    List<UserModel> result = _allUsers;

    // Filter berdasarkan tab
    if (_activeTab == 1) {
      result = result.where((u) => u.role.toLowerCase() == 'admin').toList();
    } else if (_activeTab == 2) {
      result = result.where((u) => u.role.toLowerCase() != 'admin').toList();
    }

    // Filter berdasarkan search
    if (_searchQuery.isNotEmpty) {
      result = result.where((u) => 
        u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
        u.email.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return result;
  }

  void setTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void init(String? token) {
    _authToken = token;
    fetchUsers();
  }

  Future<void> fetchUsers({bool silent = false}) async {
    if (!silent) {
      _loadState = UserLoadState.loading;
      _errorMessage = '';
      notifyListeners();
    }

    try {
      final response = await http.get(
        Uri.parse(ApiService.adminUsers),
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          rawList = decoded['data'] as List;
        }

        _allUsers = rawList
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by created_at desc (newest first)
        _allUsers.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });

        _loadState = UserLoadState.success;
      } else if (response.statusCode == 401) {
        _errorMessage = 'Sesi login habis. Silakan login ulang.';
        _loadState = UserLoadState.error;
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      if (!silent) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _loadState = UserLoadState.error;
      }
    }

    notifyListeners();
  }
}
