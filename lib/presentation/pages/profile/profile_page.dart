import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// --- IMPORT FILES ---
import '../../state/auth_provider.dart';
import 'edit_profile_page.dart';
import 'order_history_page.dart'; // ✅ Import Halaman Order History

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data User
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // URL Backend
  final String _apiUrl = 'http://localhost:8080/api/profile';

  @override
  void initState() {
    super.initState();
    _fetchProfile(); // Ambil data saat halaman dibuka
  }

  // --- AMBIL DATA DARI BACKEND ---
  Future<void> _fetchProfile() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userData = data['user'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFEC4913);
    const bgColor = Color(0xFFF8F6F6);

    // Ambil inisial nama
    String initials = "U";
    String fullName = "Loading...";
    
    if (_userData != null) {
      fullName = _userData!['name'] ?? "User";
      List<String> names = fullName.split(" ");
      if (names.length >= 2) {
        initials = "${names[0][0]}${names[1][0]}".toUpperCase();
      } else if (names.isNotEmpty) {
        initials = names[0][0].toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                // 1. HEADER PROFIL
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 96, height: 96,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials, 
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.grey.shade400)
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: bgColor, width: 3),
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade300]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 4),
                            Text("SILVER MEMBER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 2. MENU SECTIONS
                _buildSectionTitle("Account Settings"),
                _buildMenuContainer([
                  _buildMenuItem(Icons.person, Colors.blue, "Edit Profile", onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userData: _userData ?? {}),
                      ),
                    );
                    if (result == true) {
                      _fetchProfile(); 
                    }
                  }),
                  _buildMenuItem(Icons.location_on, Colors.green, "Saved Addresses"),
                  _buildMenuItem(Icons.credit_card, Colors.purple, "Payment Methods"),
                ]),

                const SizedBox(height: 24),

                _buildSectionTitle("Orders"),
                _buildMenuContainer([
                  // ✅ LINK KE ORDER HISTORY
                  _buildMenuItem(Icons.receipt_long, Colors.orange, "Order History", onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryPage()));
                  }),
                  _buildMenuItem(Icons.local_shipping, Colors.orange, "Ongoing Orders", badgeCount: 1),
                ]),

                const SizedBox(height: 24),

                _buildSectionTitle("Preferences"),
                _buildMenuContainer([
                  _buildMenuItem(Icons.notifications, Colors.grey, "Notifications"),
                  _buildMenuItem(Icons.language, Colors.grey, "Language", trailingText: "English"),
                  _buildMenuItem(Icons.support_agent, Colors.grey, "Help Center"),
                ]),

                const SizedBox(height: 24),

                // 3. TOMBOL LOGOUT
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                    },
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text("Log Out"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade100),
                      backgroundColor: Colors.red.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget widget = entry.value;
          if (idx != children.length - 1) {
            return Column(children: [widget, Divider(height: 1, color: Colors.grey.shade100, indent: 60)]);
          }
          return widget;
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, MaterialColor colorData, String title, {int badgeCount = 0, String? trailingText, VoidCallback? onTap}) {
    Color iconColor = colorData.shade500;
    Color iconBg = colorData.shade50;
    if (colorData == Colors.grey) {
       iconColor = Colors.grey.shade500;
       iconBg = Colors.grey.shade50;
    }

    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), // Sedikit kotak rounded
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(trailingText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              ),
            if (badgeCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEC4913), borderRadius: BorderRadius.circular(10)),
                child: Text("$badgeCount", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}