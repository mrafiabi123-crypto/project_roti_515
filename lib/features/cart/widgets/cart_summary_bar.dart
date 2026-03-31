import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../screens/checkout_screen.dart';

/// Panel ringkasan harga + tombol "Lanjutkan ke Pembayaran" di bawah cart.
class CartSummaryBar extends StatelessWidget {
  final int subtotal;
  final int deliveryFee;
  final int total;

  const CartSummaryBar({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, -8),
          )
        ],
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Ringkasan Pesanan",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: "Subtotal",
            value: "Rp ${formatRupiah(subtotal)}",
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: "Biaya Layanan",
            value: deliveryFee == 0 ? "Gratis" : "Rp ${formatRupiah(deliveryFee)}",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Harga",
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Rp ${formatRupiah(total)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999)),
              elevation: 4,
              shadowColor: AppColors.primaryOrange.withOpacity(0.4),
            ),
            child: Text(
              "Lanjutkan ke Pembayaran",
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textGrey, fontSize: 14)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

/// State kosong ketika keranjang belum ada produk.
class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 80, color: AppColors.divider),
          const SizedBox(height: 20),
          Text(
            "Keranjangmu masih kosong",
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textGrey, fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: const StadiumBorder(),
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Mulai Belanja",
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
