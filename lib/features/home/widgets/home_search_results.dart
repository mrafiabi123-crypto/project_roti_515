import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/staggered_fade_animation.dart';
import '../../product/providers/product_provider.dart';
import '../../product/widgets/product_card.dart';
import 'package:roti_515/core/theme/app_theme.dart';

/// Widget untuk menampilkan hasil pencarian dari Home search bar.
/// Menampilkan grid 2 kolom menggunakan ProductCard yang sama dengan ProductScreen.
class HomeSearchResults extends StatefulWidget {
  final String query;

  const HomeSearchResults({super.key, required this.query});

  @override
  State<HomeSearchResults> createState() => _HomeSearchResultsState();
}

class _HomeSearchResultsState extends State<HomeSearchResults> {
  // Map key untuk fly animation — persis seperti di ProductScreen
  final Map<int, GlobalKey> _imageKeys = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header hasil pencarian ---
        Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: context.colors.primaryOrange, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: context.colors.textGrey),
                    children: [
                      TextSpan(text: 'Hasil untuk '),
                      TextSpan(
                        text: '"${widget.query}"',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Badge jumlah hasil
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${products.length} menu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // --- Loading indicator ---
        if (provider.isLoading)
          Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: CircularProgressIndicator(color: context.colors.primaryOrange),
            ),
          )

        // --- Empty state ---
        else if (products.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 56,
                      color: context.colors.textHint.withValues(alpha: 0.5)),
                  SizedBox(height: 16),
                  Text(
                    'Menu tidak ditemukan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textGrey,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Coba kata kunci lain',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: context.colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          )

        // --- Grid hasil pencarian (sama persis dengan ProductScreen) ---
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 280,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              _imageKeys.putIfAbsent(index, () => GlobalKey());
              return StaggeredFadeAnimation(
                index: index,
                child: ProductCard(
                  product: products[index],
                  imageKey: _imageKeys[index]!,
                ),
              );
            },
          ),
      ],
    );
  }
}
