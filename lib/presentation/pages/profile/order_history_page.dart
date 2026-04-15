import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/network/api_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../features/product/models/product_model.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _orders = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final response = await http.get(
        Uri.parse(ApiService.userOrders), 
        headers: {"Authorization": "Bearer ${auth.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> parsedOrders = [];
        if (data is List) {
          parsedOrders = data;
        } else if (data is Map && data.containsKey('data')) {
          parsedOrders = data['data'];
        }

        setState(() {
          _orders = parsedOrders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal memuat pesanan (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  void _handleReorder(dynamic order) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final items = order['items'] as List;
    
    int addedCount = 0;
    for (var item in items) {
      final food = item['food'];
      if (food != null) {
        // Buat ProductModel "palsu" dari data history untuk dimasukkan ke keranjang
        final product = ProductModel(
          id: food['id'] ?? 0,
          name: food['name'] ?? 'Product',
          description: food['description'] ?? '',
          price: (item['price'] ?? 0).toInt(),
          imageUrl: food['image_url'] ?? '',
          rating: (food['rating'] as num?)?.toDouble() ?? 0.0,
          category: food['category'] ?? '',
          isBestseller: food['is_bestseller'] ?? false,
          stock: food['stock'] ?? 99,
        );

        // Tambahkan sesuai quantity pesanan lama
        final int qty = item['quantity'] ?? 1;
        for (int i = 0; i < qty; i++) {
          cart.addToCart(product);
        }
        addedCount += qty;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$addedCount item berhasil ditambahkan ke keranjang!"),
        backgroundColor: const Color(0xFFD47311),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. LIST CONTENT
            Column(
              children: [
                const SizedBox(height: 80), // Padding for Sticky Header
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD47311)))
                    : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : _orders.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_orders[index]);
                            },
                          ),
                ),
              ],
            ),

            // 2. STICKY HEADER (Glassmorphism)
            Positioned(
              top: 0, left: 0, right: 0,
              child: _buildStickyHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F6).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD47311).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
            ),
          ),
          Text(
            "Riwayat Pesanan",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFD47311).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFFD47311)),
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat pesanan.",
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final items = order['items'] as List;
    final String status = (order['status'] ?? 'Pending');
    final String id = order['id']?.toString() ?? '0';
    final String date = order['created_at']?.toString().substring(0, 10) ?? '-';
    final double total = (order['total'] ?? 0).toDouble();

    // Summary text
    String summary = "${items.length} item: ";
    if (items.isNotEmpty) {
      summary += "${items.first['food']?['name'] ?? ''}";
    }

    // Status Badge Colors
    Color badgeBg;
    Color badgeText;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'done':
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF15803D);
        statusLabel = "Selesai";
        break;
      case 'processing':
        badgeBg = const Color(0xFFFEF9C3);
        badgeText = const Color(0xFFA16207);
        statusLabel = "Diproses";
        break;
      default:
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFB91C1C);
        statusLabel = "Menunggu";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48), // EXTREME RADIUS
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFD47311).withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: ID, Status, and Image
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "#$id",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: badgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: items.isNotEmpty 
                  ? Image.network(
                      ApiService.getDisplayImage(items.first['food']?['image_url']),
                      width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(width: 56, height: 56, color: Colors.grey.shade100),
                    )
                  : Container(width: 56, height: 56, color: Colors.grey.shade100),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5, color: Color(0x0DD47311)),
          ),

          // Row 2: Summary Text
          Text(
            summary,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 12),

          // Row 3: Price & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rp ${formatRupiah(total)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  // Button Detail
                  _buildSecondaryButton(
                    "Detail", 
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Button Pesan Lagi (Hanya jika Selesai)
                  if (statusLabel == "Selesai")
                    _buildPrimaryButton("Pesan Lagi", () => _handleReorder(order)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: const Color(0xFFD47311).withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD47311),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD47311),
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD47311).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}