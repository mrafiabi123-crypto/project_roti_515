import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../core/network/api_service.dart';
import 'package:roti_515/core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallback? onCameraTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayImageUrl = (photoUrl != null && photoUrl!.isNotEmpty) 
        ? ApiService.getDisplayImage(photoUrl)
        : 'https://placehold.co/400x400';

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _showFullImage(context, displayImageUrl),
              child: Hero(
                tag: 'profile-photo-hero',
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      )
                    ],
                    image: DecorationImage(
                      image: NetworkImage(displayImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.colors.textDark,
          ),
        ),
        Text(
          email,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textGrey,
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) => _FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'profile-photo-hero',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
