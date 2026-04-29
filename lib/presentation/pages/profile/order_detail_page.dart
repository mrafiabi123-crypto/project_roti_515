import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/price_formatter.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = (order['items'] as List?) ?? [];
    final String status = (order['status'] ?? 'Pending');
    final String orderId = order['id']?.toString() ?? '0';
    final String orderRef = order['order_ref'] ?? '#ROTI515-$orderId';
    final String date = order['created_at']?.toString().substring(0, 10) ?? '-';
    final double total = (order['total'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: Color(0xFFF8F7F6),
      body: SafeArea(
        child: Column(
          children: [
            // --- CUSTOM HEADER ---
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- STATUS CARD ---
                    _buildStatusCard(status, orderRef, date),

                    SizedBox(height: 24),

                    // --- ITEMS SECTION ---
                    Text(
                      "Rincian Pesanan",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 12),
                    ...items.map((item) => _buildOrderItem(item)),

                    SizedBox(height: 24),

                    // --- PAYMENT SUMMARY ---
                    _buildPaymentSummary(total),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF8F7F6).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD47311).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: Color(0xFF0F172A),
          ),
          Text(
            "Detail Pesanan",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(width: 48), // Spacer to center title
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status, String ref, String date) {
    Color badgeBg;
    Color badgeText;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'done':
        badgeBg = Color(0xFFDCFCE7);
        badgeText = Color(0xFF15803D);
        statusLabel = "Selesai";
        break;
      case 'processing':
        badgeBg = Color(0xFFFEF9C3);
        badgeText = Color(0xFFA16207);
        statusLabel = "Diproses";
        break;
      default:
        badgeBg = Color(0xFFFEE2E2);
        badgeText = Color(0xFFB91C1C);
        statusLabel = "Menunggu";
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final food = item['food'] ?? {};
    final String name = food['name'] ?? 'Roti';
    final int qty = item['quantity'] ?? 1;
    final double price = (item['price'] ?? 0).toDouble();
    final String imageUrl = food['image_url'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFD47311).withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              ApiService.getDisplayImage(imageUrl),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56, height: 56, color: Colors.grey.shade100,
                child: Icon(Icons.bakery_dining_rounded, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "$qty x Rp ${formatRupiah(price)}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Rp ${formatRupiah(price * qty)}",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(double total) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Color(0xFFD47311).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Subtotal", total),
          Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Pembayaran",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                "Rp ${formatRupiah(total)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD47311),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            "Rp ${formatRupiah(value)}",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
