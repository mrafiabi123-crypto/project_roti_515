import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/order_model.dart';
import '../providers/order_admin_provider.dart';
import '../../../../core/utils/premium_snackbar.dart';

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
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: _buildAppBar(),
      body: const Column(
        children: [
          _OrderTabBar(),
          Expanded(child: _OrderListContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7F6).withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
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
// TAB BAR: Tertunda | Pengolahan | Selesai
// ============================================================
class _OrderTabBar extends StatelessWidget {
  const _OrderTabBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderAdminProvider>();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F6),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryOrange.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabItem(context, 0, 'Tertunda', provider.pendingCount, provider.activeTab),
            _buildTabItem(context, 1, 'Pengolahan', provider.processingCount, provider.activeTab),
            _buildTabItem(context, 2, 'Selesai', provider.completedCount, provider.activeTab),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    int index,
    String label,
    int count,
    int activeTab,
  ) {
    final isActive = index == activeTab;
    final activeColor = AppColors.primaryOrange;
    final inactiveColor = const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<OrderAdminProvider>().setTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
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
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: isActive ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppColors.primaryOrange,
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    // Error state
    if (provider.loadState == OrderLoadState.error) {
      // Deteksi error 401 (sesi habis)
      final bool isAuthError = provider.errorMessage.contains('login');

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAuthError ? Icons.lock_outline_rounded : Icons.cloud_off_rounded,
                color: AppColors.primaryOrange,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                isAuthError ? 'Sesi Admin Habis' : 'Gagal Memuat Pesanan',
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
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
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

    final orders = provider.filteredOrders;

    // Kosong
    if (orders.isEmpty) {
      return _buildEmptyState(provider.activeTab);
    }

    // Daftar pesanan
    return RefreshIndicator(
      color: AppColors.primaryOrange,
      onRefresh: () => provider.fetchOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
      ),
    );
  }

  Widget _buildEmptyState(int tab) {
    const messages = [
      'Tidak ada pesanan tertunda',
      'Tidak ada pesanan dalam pengolahan',
      'Belum ada pesanan selesai',
    ];
    const icons = [
      Icons.hourglass_empty_rounded,
      Icons.pending_actions_rounded,
      Icons.check_circle_outline_rounded,
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icons[tab], color: AppColors.primaryOrange.withValues(alpha: 0.4), size: 64),
            const SizedBox(height: 16),
            Text(
              messages[tab],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan baru akan muncul di sini secara otomatis',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
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
      duration: const Duration(milliseconds: 1000),
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

    if (mounted) {
      if (success) {
        PremiumSnackbar.showSuccess(context, "Berhasil, $actionLabel");
      } else {
        PremiumSnackbar.showError(context, "Gagal memperbarui status. Silakan coba lagi");
      }
      setState(() => _isUpdating = false);
    }
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
    final bool canAct = !order.isCompleted;

    final String actionLabel = order.isPending
        ? 'Menerima'
        : order.isProcessing
            ? 'Selesaikan'
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.05)),
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
                      _buildStatusBadge(order.status),
                      Text(
                        order.timeAgo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Nomor Order
                  Text(
                    'Order #${order.orderId}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                      height: 22.5 / 18,
                    ),
                  ),

                  // Nama Pelanggan
                  Text(
                    'Pelanggan : ${order.guestName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Total Harga
                  Row(
                    children: [
                      const Icon(
                        Icons.bakery_dining_rounded,
                        color: AppColors.primaryOrange,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.formattedTotal,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tombol Aksi + Detail
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: canAct && !_isUpdating ? _handleAction : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 36,
                            decoration: BoxDecoration(
                              color: canAct
                                  ? AppColors.primaryOrange
                                  : const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Center(
                              child: _isUpdating
                                  ? const SizedBox(
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
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showDetail,
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Center(
                            child: Text(
                              'Detail',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

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

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;

    switch (status) {
      case 'processing':
        badgeColor = const Color(0xFFF59E0B);
        badgeText = 'Pengolahan';
        break;
      case 'completed':
      case 'done':
        badgeColor = AppColors.success;
        badgeText = 'Selesai';
        break;
      default: // pending
        badgeColor = AppColors.error;
        badgeText = 'Tertunda';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        color: AppColors.primaryOrange.withValues(alpha: 0.08),
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
                        color: AppColors.primaryOrange,
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => _buildFallback(),
                ),
                // Badge jumlah item
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.bakery_dining_rounded, color: AppColors.primaryOrange, size: 40),
        const SizedBox(height: 8),
        Text(
          '$itemCount Item',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryOrange,
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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Pengambilan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
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
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
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
          backgroundColor: success ? AppColors.success : AppColors.error,
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
            decoration: const BoxDecoration(
              color: Color(0xFFF8F7F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),

                // Judul
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${latestOrder.orderId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // INFO PELANGGAN
                      _buildSection('Informasi Pelanggan', [
                        _buildInfoRow(Icons.person_rounded, 'Nama', latestOrder.guestName),
                        _buildInfoRow(Icons.phone_rounded, 'Telepon', latestOrder.guestPhone),
                        _buildInfoRow(Icons.location_on_rounded, 'Alamat/Metode', latestOrder.guestAddress),
                      ]),

                      const SizedBox(height: 16),

                      // JAM PENGAMBILAN (Admin mengatur)
                      _buildPickupTimeSection(latestOrder),

                      const SizedBox(height: 16),

                      // ITEM PESANAN
                      _buildSection(
                        'Item Pesanan (${latestOrder.items.length} produk)',
                        latestOrder.items.isEmpty
                            ? [_buildInfoRow(Icons.info_outline_rounded, 'Catatan', 'Detail item tidak tersedia')]
                            : latestOrder.items.map((item) => _buildItemRow(item)).toList(),
                      ),

                      const SizedBox(height: 16),

                      // TOTAL
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            Text(
                              latestOrder.formattedTotal,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryOrange,
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
  Widget _buildPickupTimeSection(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: order.hasPickupTime
              ? AppColors.primaryOrange.withValues(alpha: 0.30)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: AppColors.primaryOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jam Pengambilan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.hasPickupTime ? order.pickupTime! : 'Belum ditentukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: order.hasPickupTime
                        ? AppColors.primaryOrange
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          // Tombol ubah jam
          GestureDetector(
            onTap: _isSavingTime ? null : _pickDateTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: _isSavingTime
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      order.hasPickupTime ? 'Ubah' : 'Atur',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
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

  Widget _buildItemRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bakery_dining_rounded,
              color: AppColors.primaryOrange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${item.quantity}x  •  Rp. ${item.price.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
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
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
