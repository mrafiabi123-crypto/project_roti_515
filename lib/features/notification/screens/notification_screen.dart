import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/staggered_fade_animation.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'package:roti_515/core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    Future.microtask(() {
      notificationProvider.fetchNotifications(authProvider.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: context.colors.bgColor, // Latar belakang premium
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // --- App Bar Premium ---
          SliverAppBar(
            backgroundColor: context.colors.bgColor,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            iconTheme: IconThemeData(color: context.colors.textDark),
            title: Text(
              "Notifikasi",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.textDark,
                letterSpacing: 0,
              ),
            ),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.notifications.isEmpty) return SizedBox();
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0, top: 8.0),
                    child: IconButton(
                      onPressed: () => _confirmDeleteAll(
                          context, provider, authProvider.token),
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_sweep_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                      ),
                      tooltip: "Hapus Semua",
                    ),
                  );
                },
              ),
            ],
          ),

          // --- Konten ---
          SliverToBoxAdapter(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                // Loading State
                if (provider.isLoading && provider.notifications.isEmpty) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: context.colors.primaryOrange),
                    ),
                  );
                }

                // Error State
                if (provider.error.isNotEmpty && provider.notifications.isEmpty) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.wifi_off_rounded,
                                size: 50, color: Colors.redAccent),
                          ),
                          SizedBox(height: 20),
                          Text("Gagal Memuat Data",
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textDark)),
                          SizedBox(height: 8),
                          Text(provider.error,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, color: context.colors.textGrey)),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () =>
                                provider.fetchNotifications(authProvider.token),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primaryOrange,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(99)),
                            ),
                            child: Text(
                              "Coba Lagi",
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty State Premium
                if (provider.notifications.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Custom Icon Layout
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      context.colors.primaryOrange
                                          .withValues(alpha: 0.15),
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x0C000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: Icon(
                                  Icons.notifications_active_outlined,
                                  size: 40,
                                  color: context.colors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                          Text(
                            "Belum ada Notifikasi",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textDark,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Kami akan memberi tahu saat ada promo\natau pembaruan pesanan Anda.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: context.colors.textGrey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // List Notifikasi (Dilengkapi Staggered Animation)
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(provider.notifications.length,
                        (index) {
                      final notif = provider.notifications[index];
                      // Menampilkan jarak tipis antar kartu
                      return Column(
                        children: [
                          StaggeredFadeAnimation(
                            index: index,
                            child: _buildNotificationCard(
                                notif, provider, authProvider.token),
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notif,
      NotificationProvider provider, String? token) {
    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20), // Sudut lebih halus
        ),
        child: Icon(Icons.delete_sweep_rounded,
            color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text("Hapus Notifikasi?",
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            content: Text("Notifikasi ini akan dihapus secara permanen.",
                style: GoogleFonts.plusJakartaSans(color: context.colors.textGrey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Batal",
                    style: GoogleFonts.plusJakartaSans(
                        color: context.colors.textGrey,
                        fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Hapus",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await provider.deleteNotification(notif.id, token);
          return true;
        }
        return false;
      },
      child: InkWell(
        onTap: () {
          if (!notif.isRead) {
            provider.markAsRead(notif.id, token);
          }
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: context.colors.primaryOrange.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: notif.isRead ? context.colors.surface : context.colors.primaryOrange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: notif.isRead
                    ? Color(0x08000000)
                    : context.colors.primaryOrange.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: Offset(0, 5),
              )
            ],
            border: Border.all(
              color: notif.isRead
                  ? Colors.transparent
                  : context.colors.primaryOrange.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Left accent bar for unread
              if (!notif.isRead)
                Positioned(
                  left: 0,
                  top: 24,
                  bottom: 24,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: context.colors.primaryOrange,
                      borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(4)), // Rounded kanan
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Ikon Premium
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.primaryOrange,
                            context.colors.primaryOrange.withValues(alpha: 0.7)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primaryOrange
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(Icons.bakery_dining_rounded,
                          color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: notif.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: context.colors.textDark,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                notif.timeAgo(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textHint,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            notif.message,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: context.colors.textGrey,
                              height: 1.5, // Line height yang nyaman
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, NotificationProvider provider,
      String? token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Hapus Semua?",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text("Seluruh riwayat notifikasi Anda akan dihapus permanen.",
            style: GoogleFonts.plusJakartaSans(color: context.colors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal",
                style: GoogleFonts.plusJakartaSans(
                    color: context.colors.textGrey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Hapus Semua",
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteAllNotifications(token);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Semua notifikasi dibersihkan",
                  style: GoogleFonts.plusJakartaSans()),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Gagal menghapus notifikasi"),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
