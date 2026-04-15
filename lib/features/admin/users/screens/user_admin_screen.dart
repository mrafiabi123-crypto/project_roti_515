import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/models/user_model.dart';
import '../providers/user_admin_provider.dart';

class UserAdminScreen extends StatefulWidget {
  const UserAdminScreen({super.key});

  @override
  State<UserAdminScreen> createState() => _UserAdminScreenState();
}

class _UserAdminScreenState extends State<UserAdminScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final token = context.read<AuthProvider>().token;
        context.read<UserAdminProvider>().init(token);
      }
    });

    _searchController.addListener(() {
      if (mounted) {
        context.read<UserAdminProvider>().setSearchQuery(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserAdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header "Manajemen Pengguna"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'Manajemen Pengguna',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  '${provider.totalUsers} Total',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari berdasarkan nama atau email',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tabs
          const _UserTabBar(),

          // Konten List Pengguna
          const Expanded(child: _UserListContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7F6).withValues(alpha: 0.80),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 21),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.bakery_dining_rounded,
                color: AppColors.primaryOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'roti515',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  ' Portal Admin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.10),
            child: const Icon(
              Icons.account_circle_outlined,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TAB BAR: Semua | Admin | Pelanggan
// ============================================================
class _UserTabBar extends StatelessWidget {
  const _UserTabBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserAdminProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F6),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildTabItem(context, 0, 'Semua', provider.activeTab),
            const SizedBox(width: 24),
            _buildTabItem(context, 1, 'Admin', provider.activeTab),
            const SizedBox(width: 24),
            _buildTabItem(context, 2, 'Pelanggan', provider.activeTab),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String label, int activeTab) {
    final isActive = index == activeTab;
    final activeColor = AppColors.primaryOrange;
    final inactiveColor = const Color(0xFF64748B);

    return GestureDetector(
      onTap: () => context.read<UserAdminProvider>().setTab(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4, right: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF0F172A) : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONTENT LIST PENGGUNA
// ============================================================
class _UserListContent extends StatelessWidget {
  const _UserListContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserAdminProvider>();

    if (provider.loadState == UserLoadState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (provider.loadState == UserLoadState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.primaryOrange, size: 56),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Pengguna',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => provider.fetchUsers(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'Coba Lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final users = provider.filteredUsers;

    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Icon(Icons.person_off_rounded, color: AppColors.primaryOrange.withValues(alpha: 0.4), size: 64),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data pengguna',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryOrange,
      onRefresh: () => provider.fetchUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: users.length,
        itemBuilder: (ctx, i) => _UserListItem(user: users[i]),
      ),
    );
  }
}

// ============================================================
// KOMPONEN ITEM PENGGUNA (Sesuai Desain HTML)
// ============================================================
class _UserListItem extends StatelessWidget {
  final UserModel user;
  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user.role.toLowerCase() == 'admin';
    // Gunakan indikator hijau jika admin (aktif) atau pengguna baru? Kita asumsikan hijau untuk pengguna baru/admin, abu-abu kalau lama
    // Atau kita bisa gunakan hijau untuk admin, abu abu untuk pelanggan. (Sesuai desain)
    final Color badgeColor = isAdmin ? const Color(0xFF4F46E5) : const Color(0xFFD47311);
    final Color badgeBgColor = isAdmin ? const Color(0xFFE0E7FF) : const Color(0xFFD47311).withValues(alpha: 0.10);
    final String badgeText = isAdmin ? 'Admin' : 'Pelanggan';
    
    // Status dot color bisa juga aktif/hijau jika admin
    final Color statusDotColor = isAdmin ? const Color(0xFF22C55E) : (user.timeAgo == 'Sekarang' ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Kiri: Avatar dengan Dot Indikator ──
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusDotColor,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // ── Tengah: Detail Nama & Email ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'Pengguna Tidak Diketahui' : user.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    height: 20 / 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email.isEmpty ? '-' : user.email,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 16 / 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Kanan: Badge Role & Waktu Gabung ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Center(
                  child: Text(
                    badgeText.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                      letterSpacing: 0.50,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAdmin ? 'Aktif' : user.timeAgo,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),
            ],
          ),

          // ── Tombol Hapus (Merah) ──
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              // Aksi hapus (bisa ditambahkan nanti)
            },
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
