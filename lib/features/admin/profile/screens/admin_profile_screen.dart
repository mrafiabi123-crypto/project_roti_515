import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/widgets/profile_header.dart';
import '../../../profile/widgets/profile_section_label.dart';
import '../../../profile/widgets/profile_menu_tile.dart';
import '../../../profile/widgets/profile_logout_button.dart';
import '../../../../presentation/pages/profile/edit_profile_page.dart';
import '../../../../core/utils/premium_snackbar.dart';
import 'package:roti_515/core/theme/theme_provider.dart';
import 'package:roti_515/core/theme/app_theme.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final String _apiUrl = ApiService.profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

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
          final user = data['user'];
          // Update global photoUrl di AuthProvider agar AppBar sinkron
          Provider.of<AuthProvider>(context, listen: false).updatePhotoUrl(user['photo_url']);

          setState(() {
            _userData = user;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      var request = http.MultipartRequest('POST', Uri.parse(ApiService.uploadPhoto));
      request.headers['Authorization'] = 'Bearer $token';

      // Gunakan file langsung dari picker
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: 'admin_photo.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          PremiumSnackbar.showSuccess(context, "Foto profil berhasil diperbarui!");
          _fetchProfile();
        }
      } else {
        if (mounted) {
          final data = jsonDecode(response.body);
          PremiumSnackbar.showError(context, data['error'] ?? "Gagal mengunggah foto");
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        PremiumSnackbar.showError(context, "Terjadi kesalahan: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullName = _userData?['name'] ?? "Loading...";
    String email = _userData?['email'] ?? "memuat..";

    return Scaffold(
      backgroundColor: context.colors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.primaryOrange, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profil Admin",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.colors.textDark,
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => IconButton(
              icon: Icon(
                theme.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: context.colors.textDark,
              ),
              onPressed: () => theme.toggleTheme(!theme.isDarkMode),
            ),
          ),
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: context.colors.primaryOrange))
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  ProfileHeader(
                    name: fullName, 
                    email: email,
                    photoUrl: _userData?['photo_url'],
                    onCameraTap: _pickAndUploadImage,
                  ),
                  SizedBox(height: 24),
                  ProfileSectionLabel(label: "Aktivitas Akun"),
                  ProfileMenuTile(
                    icon: Icons.edit_rounded,
                    title: "Edit Profil",
                    subtitle: "Ubah nama, telepon & password",
                    onTap: () async {
                      if (_userData == null) return;
                      final updated = await Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(userData: _userData!),
                        ),
                      );
                      if (updated == true && mounted) {
                        _fetchProfile();
                      }
                    },
                  ),
                  SizedBox(height: 24),
                  ProfileSectionLabel(label: "Sistem"),
                  SizedBox(height: 16),
                  ProfileLogoutButton(),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
