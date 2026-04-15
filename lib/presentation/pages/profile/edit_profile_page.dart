import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Import Provider untuk ambil Token
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/network/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData; // Terima data lama dari ProfilePage

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller Input
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController; // Pakai Address, bukan Email (Email biasanya gaboleh diganti sembarangan)
  
  bool _isLoading = false;

  final String _apiUrl = ApiService.profile;

  @override
  void initState() {
    super.initState();
    // Isi formulir dengan data lama
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _addressController = TextEditingController(text: widget.userData['address']);
  }

  // --- FUNGSI UPDATE KE BACKEND ---
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.put(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": _nameController.text,
          "phone": _phoneController.text,
          "address": _addressController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Balik ke halaman sebelumnya & kirim sinyal 'true' (berhasil)
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Failed: ${response.body}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFEC4913);
    const bgColor = Color(0xFFF8F6F6);

    // Ambil inisial untuk foto profil
    String initials = "U";
    if (_nameController.text.isNotEmpty) {
      initials = _nameController.text[0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. FOTO PROFIL (Lingkaran Besar)
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.grey.shade400),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text("Change Photo", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 32),

            // 2. FORM PUBLIC INFO
            Align(alignment: Alignment.centerLeft, child: _sectionTitle("Public Info")),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInputGroup("Full Name", _nameController, Icons.edit),
                  const SizedBox(height: 16),
                  // Email kita matikan (readOnly) karena biasanya gaboleh ganti email sembarangan
                  _buildInputGroup("Email Address", TextEditingController(text: widget.userData['email']), Icons.lock, isReadOnly: true),
                  const SizedBox(height: 16),
                  _buildInputGroup("Phone Number", _phoneController, Icons.phone),
                  const SizedBox(height: 16),
                  _buildInputGroup("Address", _addressController, Icons.location_on),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. PRIVATE DETAILS (Gender - Dummy UI dulu)
            Align(alignment: Alignment.centerLeft, child: _sectionTitle("Private Details")),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gender", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _genderOption("Male", true),
                      const SizedBox(width: 8),
                      _genderOption("Female", false),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. TOMBOL SAVE
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: primaryColor.withValues(alpha: 0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _sectionTitle(String title) {
    return Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1));
  }

  Widget _buildInputGroup(String label, TextEditingController controller, IconData icon, {bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isReadOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            style: TextStyle(fontWeight: FontWeight.bold, color: isReadOnly ? Colors.grey : Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        )
      ],
    );
  }

  Widget _genderOption(String label, bool isSelected) {
    const primaryColor = Color(0xFFEC4913);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.grey.shade50,
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isSelected ? primaryColor : Colors.grey.shade600
          )),
        ),
      ),
    );
  }
}