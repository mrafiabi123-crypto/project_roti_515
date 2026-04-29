import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import 'package:roti_515/core/theme/app_theme.dart';

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
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final name = categories[index];
          final String categoryValue = (name == "Semua") ? "All" : name;
          final isSelected = provider.selectedCategory == categoryValue;

          return GestureDetector(
            onTap: () => provider.setCategory(categoryValue),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? context.colors.primaryOrange : context.colors.white,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected
                      ? context.colors.primaryOrange
                      : context.colors.divider,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? context.colors.white : context.colors.textGrey,
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
