import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/product_app_bar.dart';
import '../widgets/product_category_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_fade_animation.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final List<String> categories = ["Semua", "Roti", "Biskuit"];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
    );
  }

  void _onSearchChanged(String query) {
    Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(query: query);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.products;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          // App bar: logo, cart, search (dengan debounce internal)
          ProductAppBar(onSearchChanged: _onSearchChanged),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Filter kategori
                ProductCategoryBar(categories: categories),

                // Label "Produk Kami"
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    "Produk Kami",
                    style: GoogleFonts.pragatiNarrow(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                // Grid produk
                if (provider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) => ProductFadeAnimation(
                      index: index,
                      child: ProductCard(product: products[index]),
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