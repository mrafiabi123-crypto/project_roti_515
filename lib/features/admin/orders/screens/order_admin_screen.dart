import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/auth_provider.dart';
import '../models/order_model.dart';
import '../providers/order_admin_provider.dart';
import '../../../../core/utils/premium_snackbar.dart';
import '../../../admin/dashboard/providers/admin_stats_provider.dart';
import '../../profile/screens/admin_profile_screen.dart';
import 'package:roti_515/core/theme/theme_provider.dart';
import 'package:roti_515/core/theme/app_theme.dart';
import 'package:roti_515/core/network/api_service.dart';

// ============================================================
// HALAMAN UTAMA ORDER ADMIN
// ============================================================
class OrderAdminScreen extends StatefulWidget {
  const OrderAdminScreen({super.key});

  @override
  State<OrderAdminScreen> createState() => _OrderAdminScreenState();
}

class _OrderAdminScreenState extends State<OrderAdminScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil token dari AuthProvider, lalu mulai polling otomatis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final token = context.read<AuthProvider>().token;
        context.read<OrderAdminProvider>().startPolling(token);
      }
    });
  }

  @override
  void dispose() {
    // Hentikan polling saat berpindah halaman
    context.read<OrderAdminProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _OrderTabBar(),
          Expanded(child: _OrderListContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.colors.bgColor,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primaryOrange.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(16)
            ),
            child: Icon(Icons.bakery_dining_rounded, color: context.colors.primaryOrange, size: 22),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("roti515", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textDark)),
              Text("Portal Admin", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.primaryOrange)),
            ],
          ),
        ],
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
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => AdminProfileScreen()),
              );
            },
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final photoUrl = auth.photoUrl;
                final fullImageUrl = ApiService.getDisplayImage(photoUrl);
                
                return CircleAvatar(
                  backgroundColor: context.colors.primaryOrange.withValues(alpha: 0.1),
                  backgroundImage: fullImageUrl.isNotEmpty
                      ? NetworkImage(fullImageUrl)
                      : null,
                  child: fullImageUrl.isEmpty
                      ? Icon(Icons.account_circle_outlined, color: context.colors.primaryOrange)
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TAB BAR: Tertunda | Pengolahan | Selesai
// ============================================================
class _OrderTabBar extends StatelessWidget {
  const _OrderTabBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderAdminProvider>();

    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgColor,
        border: Border(
          bottom: BorderSide(
            color: context.colors.primaryOrange.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabItem(context, 0, 'Tertunda', provider.pendingCount, provider.activeTab),
            _buildTabItem(context, 1, 'Pengolahan', provider.processingCount, provider.activeTab),
            _buildTabItem(context, 2, 'Selesai', provider.completedCount, provider.activeTab),
            _buildTabItem(context, 3, 'Dibatalkan', provider.cancelledCount, provider.activeTab),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context,
    int index,
    String label,
    int count,
    int activeTab,
  ) {
    final isActive = index == activeTab;
    final activeColor = context.colors.primaryOrange;
    final inactiveColor = context.colors.textGrey;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<OrderAdminProvider>().setTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.only(top: 16, bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? activeColor : Colors.transparent,
                width: 3,
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
                  fontWeight: FontWeight.w700,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              if (count > 0) ...[
                SizedBox(height: 4),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.primaryOrange.withValues(alpha: isActive ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: context.colors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// KONTEN LIST PESANAN
// ============================================================
class _OrderListContent extends StatelessWidget {
  const _OrderListContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderAdminProvider>();

    // Loading state
    if (provider.loadState == OrderLoadState.loading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primaryOrange),
      );
    }

    // Error state
    if (provider.loadState == OrderLoadState.error) {
      // Deteksi error 401 (sesi habis)
      final bool isAuthError = provider.errorMessage.contains('login');

      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAuthError ? Icons.lock_outline_rounded : Icons.cloud_off_rounded,
                color: context.colors.primaryOrange,
                size: 56,
              ),
              SizedBox(height: 16),
              Text(
                isAuthError ? 'Sesi Admin Habis' : 'Gagal Memuat Pesanan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                provider.errorMessage,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: context.colors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28),
              // Tombol sesuai jenis error
              if (isAuthError)
                GestureDetector(
                  onTap: () {
                    // Navigasi kembali ke halaman login
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.colors.primaryOrange,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Login Ulang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => provider.fetchOrders(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.colors.primaryOrange,
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

    final orders = provider.filteredOrders;

    // Kosong
    if (orders.isEmpty) {
      return _buildEmptyState(context, provider.activeTab);
    }

    // Daftar pesanan
    return RefreshIndicator(
      color: context.colors.primaryOrange,
      onRefresh: () => provider.fetchOrders(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: orders.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, int tab) {
    final messages = [
      'Tidak ada pesanan tertunda',
      'Tidak ada pesanan dalam pengolahan',
      'Belum ada pesanan selesai',
      'Tidak ada pesanan yang dibatalkan',
    ];
    final icons = [
      Icons.hourglass_empty_rounded,
      Icons.pending_actions_rounded,
      Icons.check_circle_outline_rounded,
      Icons.cancel_outlined,
    ];

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icons[tab], color: context.colors.primaryOrange.withValues(alpha: 0.4), size: 64),
            SizedBox(height: 16),
            Text(
              messages[tab],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.textGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pesanan baru akan muncul di sini secara otomatis',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: context.colors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CARD PESANAN (sesuai desain)
// ============================================================
class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> with SingleTickerProviderStateMixin {
  bool _isUpdating = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Animasi pulse untuk pesanan baru (tertunda)
    if (widget.order.isPending) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    final provider = context.read<OrderAdminProvider>();
    final statsProvider = context.read<AdminStatsProvider>(); // Ambil provider sebelum task run
    String nextStatus;
    String actionLabel;

    if (widget.order.isPending) {
      nextStatus = 'processing';
      actionLabel = 'pesanan diterima dan diproses';
    } else if (widget.order.isProcessing) {
      nextStatus = 'completed';
      actionLabel = 'pesanan telah diselesaikan';
    } else {
      return;
    }

    setState(() => _isUpdating = true);
    final success = await provider.updateOrderStatus(widget.order.id, nextStatus);

    if (!mounted) return;

    if (success) {
      PremiumSnackbar.showSuccess(null, "Berhasil, $actionLabel");
      // Jika pesanan diselesaikan, langsung refresh statistik dashboard
      if (nextStatus == 'completed') {
        statsProvider.refreshNow(); // Gunakan variabel yang diinisasi sebelum gap async
      }
    } else {
      PremiumSnackbar.showError(null, "Gagal memperbarui status. Silakan coba lagi");
    }
    setState(() => _isUpdating = false);
  }

  Future<void> _handleDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Hapus Pesanan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: context.colors.textDark,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus riwayat pesanan #${widget.order.orderId} ini secara permanen?',
          style: GoogleFonts.plusJakartaSans(color: context.colors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', 
              style: GoogleFonts.plusJakartaSans(
                color: context.colors.textGrey,
                fontWeight: FontWeight.w600,
              )
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Hapus', 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUpdating = true);
    final provider = context.read<OrderAdminProvider>();
    final success = await provider.deleteOrder(widget.order.id);

    if (!mounted) return;

    if (success) {
      PremiumSnackbar.showSuccess(null, "Pesanan berhasil dihapus");
    } else {
      PremiumSnackbar.showError(null, "Gagal menghapus pesanan. Silakan coba lagi");
    }
    setState(() => _isUpdating = false);
  }

  void _showDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderDetailSheet(order: widget.order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool canAct = order.isPending || order.isProcessing;

    final String actionLabel = order.isPending
        ? 'Menerima'
        : order.isProcessing
            ? 'Selesaikan'
            : order.isCancelled
                ? 'Dibatalkan'
                : 'Selesai ✓';

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, child) {
        return Transform.scale(
          scale: order.isPending ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface, borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
          border: Border.all(color: context.colors.primaryOrange.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Kiri: Info Pesanan ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge + Waktu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(context, order.status),
                      Text(
                        order.timeAgo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: context.colors.textHint,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

                  // Nomor Order
                  Text(
                    'Order #${order.orderId}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textDark,
                      height: 22.5 / 18,
                    ),
                  ),

                  // Nama Pelanggan
                  Text(
                    'Pelanggan : ${order.guestName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textGrey,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Total Harga
                  Row(
                    children: [
                      Icon(
                        Icons.bakery_dining_rounded,
                        color: context.colors.primaryOrange,
                        size: 14,
                      ),
                      SizedBox(width: 8),
                      Text(
                        order.formattedTotal,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Tombol Aksi + Detail
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: canAct && !_isUpdating ? _handleAction : null,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: 36,
                            decoration: BoxDecoration(
                              color: canAct
                                  ? context.colors.primaryOrange
                                  : order.isCancelled
                                      ? context.colors.error
                                      : Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Center(
                              child: _isUpdating
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      actionLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showDetail,
                        child: Container(
                          height: 36,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: context.colors.divider,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Center(
                            child: Text(
                              'Detail',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (order.isCompleted || order.isCancelled) ...[
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: !_isUpdating ? _handleDelete : null,
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: context.colors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: context.colors.error,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),

            // ─── Kanan: Gambar Produk ─────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: _OrderThumbnail(
                imageUrl: order.thumbnailImage,
                itemCount: order.items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color badgeColor;
    String badgeText;

    switch (status) {
      case 'processing':
        badgeColor = Color(0xFFF59E0B);
        badgeText = 'Pengolahan';
        break;
      case 'completed':
      case 'done':
        badgeColor = context.colors.success;
        badgeText = 'Selesai';
        break;
      case 'cancelled':
        badgeColor = context.colors.textHint;
        badgeText = 'Dibatalkan';
        break;
      default: // pending
        badgeColor = context.colors.error;
        badgeText = 'Tertunda';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        badgeText.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ============================================================
// THUMBNAIL GAMBAR PRODUK (dengan fallback ikon)
// ============================================================
class _OrderThumbnail extends StatelessWidget {
  final String imageUrl;
  final int itemCount;
  const _OrderThumbnail({required this.imageUrl, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl.isNotEmpty;

    return Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: context.colors.primaryOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(32),
      ),
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                // Gambar Produk
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.colors.primaryOrange,
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => _buildFallback(context),
                ),
                // Badge jumlah item
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '$itemCount Item',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bakery_dining_rounded, color: context.colors.primaryOrange, size: 40),
        SizedBox(height: 8),
        Text(
          '$itemCount Item',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colors.primaryOrange,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BOTTOM SHEET DETAIL PESANAN
// ============================================================
class _OrderDetailSheet extends StatefulWidget {
  final OrderModel order;
  const _OrderDetailSheet({required this.order});

  @override
  State<_OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends State<_OrderDetailSheet> {
  bool _isSavingTime = false;

  Future<void> _pickDateTime() async {
    // 1. Pilih Tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      helpText: 'Pilih Tanggal Pengambilan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.colors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: context.colors.textDark,
              surface: context.colors.surface,
            ),
            dialogBackgroundColor: context.colors.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    // 2. Pilih Jam
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Pilih Jam Pengambilan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.colors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: context.colors.textDark,
              surface: context.colors.surface,
            ),
            dialogBackgroundColor: context.colors.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    // 3. Format Hasil (Contoh: "14 Apr 2026, 09:30")
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final String formatted =
        '${pickedDate.day} ${months[pickedDate.month - 1]} ${pickedDate.year}, ${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

    setState(() => _isSavingTime = true);
    final provider = context.read<OrderAdminProvider>();
    final success = await provider.setPickupTime(widget.order.id, formatted);
    if (mounted) {
      setState(() => _isSavingTime = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            success
                ? '✅ Jadwal pengambilan ditetapkan: $formatted'
                : '❌ Gagal menyimpan jadwal. Coba lagi.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: success ? context.colors.success : context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider agar jam tampil langsung setelah disimpan
    final latestOrder = context
        .watch<OrderAdminProvider>()
        .filteredOrders
        .firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: context.colors.bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.divider,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),

                // Judul
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${latestOrder.orderId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textDark,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.divider,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, size: 18, color: context.colors.textGrey),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: context.colors.divider),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.all(20),
                    children: [
                      // INFO PELANGGAN
                      _buildSection(context, 'Informasi Pelanggan', [
                        _buildInfoRow(context, Icons.person_rounded, 'Nama', latestOrder.guestName),
                        _buildInfoRow(context, Icons.phone_rounded, 'Telepon', latestOrder.guestPhone),
                        _buildInfoRow(context, Icons.location_on_rounded, 'Alamat/Metode', latestOrder.guestAddress),
                      ]),

                      SizedBox(height: 16),

                      // JAM PENGAMBILAN (Admin mengatur)
                      _buildPickupTimeSection(context, latestOrder),

                      SizedBox(height: 16),

                      // ITEM PESANAN
                      _buildSection(context, 
                        'Item Pesanan (${latestOrder.items.length} produk)',
                        latestOrder.items.isEmpty
                            ? [_buildInfoRow(context, Icons.info_outline_rounded, 'Catatan', 'Detail item tidak tersedia')]
                            : latestOrder.items.map((item) => _buildItemRow(context, item)).toList(),
                      ),

                      SizedBox(height: 16),

                      // TOTAL
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surface, borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: context.colors.primaryOrange.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textGrey,
                              ),
                            ),
                            Text(
                              latestOrder.formattedTotal,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Widget section jam pengambilan (bisa diklik admin untuk ubah)
  Widget _buildPickupTimeSection(BuildContext context, OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface, borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: order.hasPickupTime
              ? context.colors.primaryOrange.withValues(alpha: 0.30)
              : context.colors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primaryOrange.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: context.colors.primaryOrange,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jam Pengambilan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textGrey,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  order.hasPickupTime ? order.pickupTime! : 'Belum ditentukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: order.hasPickupTime
                        ? context.colors.primaryOrange
                        : context.colors.textHint,
                  ),
                ),
              ],
            ),
          ),
          // Tombol ubah jam
          GestureDetector(
            onTap: _isSavingTime ? null : _pickDateTime,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: _isSavingTime
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: context.colors.primaryOrange,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      order.hasPickupTime ? 'Ubah' : 'Atur',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.colors.primaryOrange,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.primaryOrange.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.textDark,
            ),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.primaryOrange, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textGrey,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: context.colors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItemModel item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.bakery_dining_rounded,
              color: context.colors.primaryOrange,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.isNotEmpty
                      ? item.productName
                      : 'Produk #${item.productId}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textDark,
                  ),
                ),
                Text(
                  '${item.quantity}x  •  Rp. ${item.price.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: context.colors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp. ${(item.price * item.quantity).toInt()}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
