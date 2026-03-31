import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../product/providers/product_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/home_section_header.dart';
import '../widgets/bestseller_card.dart';
import '../widgets/new_menu_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar: logo, cart, search
                  const HomeAppBar(),
                  const SizedBox(height: 10),

                  // Banner promo
                  const HomePromoBanner(),
                  const SizedBox(height: 32),

                  // Section: Bestsellers
                  const HomeSectionHeader(
                    title: "Bestsellers",
                    showArrows: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 277,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.bestsellers.length,
                      itemBuilder: (context, index) =>
                          BestsellerCard(product: provider.bestsellers[index]),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section: Menu Baru
                  const HomeSectionHeader(
                    title: "Menu Baru",
                    showArrows: false,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 106,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.newMenus.length,
                      itemBuilder: (context, index) =>
                          NewMenuCard(product: provider.newMenus[index]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}