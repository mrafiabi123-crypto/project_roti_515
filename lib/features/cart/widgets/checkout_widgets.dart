import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../providers/cart_provider.dart';

const Color _whatsappGreen = Color(0xFF25D366);

/// Stepper progress di bagian atas halaman checkout.
class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepItem(num: "1", label: "Pilih Produk"),
          _StepLine(),
          _StepItem(num: "2", label: "Total Harga"),
          _StepLine(),
          _StepItem(num: "3", label: "Konfirmasi"),
        ],
      ),
    );
  }
}

/// Opsi pengiriman "Ambil Di Toko".
class CheckoutDeliveryOption extends StatelessWidget {
  const CheckoutDeliveryOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
                color: AppColors.textDark.withOpacity(0.02), blurRadius: 4)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.storefront_rounded,
                  color: AppColors.textGrey, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ambil Di Toko",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    "Tersedia dalam 15 menit",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textBrown),
                  ),
                ],
              ),
            ),
            Text(
              "Gratis",
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                  fontSize: 16),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryOrange, width: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu info konfirmasi via WhatsApp.
class CheckoutWhatsAppCard extends StatelessWidget {
  const CheckoutWhatsAppCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Konfirmasi",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _whatsappGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(FontAwesomeIcons.whatsapp,
                        color: _whatsappGreen, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order via WhatsApp",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rincian pesanan Anda akan kami proses dan kami akan menghubungi Anda.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textBrown,
                          height: 1.5,
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
  }
}

/// Ringkasan daftar produk yang dipesan beserta subtotal.
class CheckoutOrderSummary extends StatelessWidget {
  final CartProvider cart;
  final int deliveryFee;

  const CheckoutOrderSummary({
    super.key,
    required this.cart,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Ringkasan Pesanan",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                    color: AppColors.textDark.withOpacity(0.05), blurRadius: 2)
              ],
            ),
            child: Column(
              children: [
                ...cart.items.map((item) =>
                    _SummaryItem(product: item.product, qty: item.quantity)),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    color: AppColors.divider),
                _SummaryRow(
                    label: "Subtotal",
                    value: "Rp ${formatRupiah(cart.totalPrice)}"),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: "Biaya Pengiriman",
                  value: deliveryFee == 0
                      ? "Gratis"
                      : "Rp ${formatRupiah(deliveryFee)}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar dengan total harga + tombol "Order via WhatsApp".
class CheckoutStickyBottom extends StatelessWidget {
  final CartProvider cart;
  final int deliveryFee;
  final bool isOrdering;
  final VoidCallback onOrder;

  const CheckoutStickyBottom({
    super.key,
    required this.cart,
    required this.deliveryFee,
    required this.isOrdering,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Harga",
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                "Rp ${formatRupiah(cart.totalPrice + deliveryFee)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: isOrdering ? null : onOrder,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: _whatsappGreen,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                      color: _whatsappGreen.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 4)),
                  BoxShadow(
                      color: _whatsappGreen.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Center(
                child: isOrdering
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 3))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(FontAwesomeIcons.whatsapp,
                              color: AppColors.white, size: 21),
                          const SizedBox(width: 12),
                          Text(
                            "Order via WhatsApp",
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Dengan mengklik tombol ini, detail pesanan Anda akan diproses di sistem.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ----- Private helpers -----

class _StepItem extends StatelessWidget {
  final String num;
  final String label;
  const _StepItem({required this.num, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.pontanoSans(
            color: AppColors.primaryOrange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withOpacity(0.3),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final dynamic product;
  final int qty;
  const _SummaryItem({required this.product, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              product.imageUrl.isNotEmpty
                  ? product.imageUrl
                  : "https://placehold.co/64x64",
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "Rp ${formatRupiah(product.price)}",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  product.description.isNotEmpty
                      ? product.description
                      : "Roti 515",
                  style: GoogleFonts.pontanoSans(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Jumlah : $qty",
                  style: GoogleFonts.pontanoSans(
                    color: AppColors.primaryOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textBrown, fontSize: 14)),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            )),
      ],
    );
  }
}
