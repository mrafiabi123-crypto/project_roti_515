import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../models/product_model.dart';

/// Header gambar besar di atas halaman detail produk.
class DetailImageHeader extends StatelessWidget {
  final ProductModel product;
  const DetailImageHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(
            product.imageUrl.isNotEmpty
                ? product.imageUrl
                : "https://placehold.co/440x400",
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Baris aksi floating (back + favorit) di atas gambar.
class DetailFloatingActions extends StatelessWidget {
  const DetailFloatingActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            size: 18,
            onTap: () => Navigator.pop(context),
          ),
          _GlassButton(
            icon: Icons.favorite_border_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Ditambahkan ke Favorit!",
                    style: GoogleFonts.plusJakartaSans(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Info produk: nama, badge rating, harga.
class DetailProductInfo extends StatelessWidget {
  final ProductModel product;
  const DetailProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 30,
                    color: AppColors.textBrown,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.primaryOrange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${product.rating}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "(120 ulasan)",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "Rp ${formatRupiah(product.price)}",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bagian deskripsi + tag kategori.
class DetailDescription extends StatelessWidget {
  final ProductModel product;
  const DetailDescription({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Deskripsi",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              color: AppColors.textBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description.isNotEmpty
                ? product.description
                : "Deskripsi produk belum tersedia.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(
                  text: product.category.isNotEmpty
                      ? product.category
                      : "Roti"),
              if (product.isBestseller) const _Tag(text: "Bestseller 🔥"),
            ],
          ),
        ],
      ),
    );
  }
}

/// Selector jumlah produk yang akan dibeli.
class DetailQuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const DetailQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Jumlah",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBrown,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.textDark.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1))
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onDecrease,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.remove_rounded,
                          color: AppColors.textHint, size: 18),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: Text(
                      "$quantity",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBrown,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onIncrease,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.textBrown,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.textDark.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppColors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----- Private helpers -----

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: AppColors.textBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _GlassButton(
      {required this.icon, required this.onTap, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: AppColors.textDark, size: size),
          ),
        ),
      ),
    );
  }
}
