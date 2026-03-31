import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/product_provider.dart';

class ProductCategoryBar extends StatelessWidget {
  final List<String> categories;

  const ProductCategoryBar({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final name = categories[index];
          final String categoryValue = (name == "Semua") ? "All" : name;
          final isSelected = provider.selectedCategory == categoryValue;

          return GestureDetector(
            onTap: () => provider.setCategory(categoryValue),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : AppColors.white,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : AppColors.divider,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? AppColors.white : AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
