import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../product/providers/product_provider.dart';
import 'package:roti_515/core/theme/app_theme.dart';

/// Pilihan sortir yang tersedia untuk filter produk di Home
enum SortOption { terlaris, terbaru, hargaAsc, hargaDesc }

/// Bottom Sheet filter yang tampil saat ikon `tune` di-tap.
/// Berisi: pilihan Kategori (pill) dan Sortir (radio).
class HomeFilterSheet extends StatefulWidget {
  /// Sortir yang sedang aktif saat sheet dibuka (agar state tidak reset)
  final SortOption currentSort;

  const HomeFilterSheet({super.key, required this.currentSort});

  @override
  State<HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<HomeFilterSheet> {
  // Kategori yang tersedia (value 'All' sesuai ProductProvider)
  final List<Map<String, String>> _categories = [
    {'label': 'Semua', 'value': 'All'},
    {'label': 'Roti', 'value': 'Roti'},
    {'label': 'Biskuit', 'value': 'Biskuit'},
  ];

  late SortOption _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
  }

  void _apply(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    // Map enum ke string value yang digunakan provider
    final sortMap = {
      SortOption.terlaris: 'bestseller',
      SortOption.terbaru: 'newest',
      SortOption.hargaAsc: 'price_asc',
      SortOption.hargaDesc: 'price_desc',
    };

    // Terapkan sortir lokal melalui provider
    provider.setSortOption(sortMap[_selectedSort]!);

    // Kembalikan sort option yang dipilih ke parent agar bisa disimpan di state
    Navigator.pop(context, _selectedSort);
  }

  void _reset(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    setState(() => _selectedSort = SortOption.terlaris);
    provider.clearFilters();
    Navigator.pop(context, SortOption.terlaris);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar dekoratif
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),

          // --- JUDUL ---
          Text(
            "Filter & Urutkan",
            style: GoogleFonts.pragatiNarrow(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.colors.textDark,
            ),
          ),
          SizedBox(height: 20),

          // --- SEKSI KATEGORI ---
          Text(
            "Kategori",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textGrey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _categories.map((cat) {
              final isSelected = provider.selectedCategory == cat['value'];
              return GestureDetector(
                onTap: () => provider.setCategory(cat['value']!),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primaryOrange
                        : context.colors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.primaryOrange
                          : context.colors.divider,
                    ),
                  ),
                  child: Text(
                    cat['label']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? context.colors.white : context.colors.textGrey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),

          // --- SEKSI URUTKAN ---
          Text(
            "Urutkan",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textGrey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          ...SortOption.values.map((opt) {
            final labels = {
              SortOption.terlaris: "Terlaris",
              SortOption.terbaru: "Terbaru",
              SortOption.hargaAsc: "Harga: Termurah",
              SortOption.hargaDesc: "Harga: Termahal",
            };
            return RadioListTile<SortOption>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: context.colors.primaryOrange,
              value: opt,
              groupValue: _selectedSort,
              title: Text(
                labels[opt]!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: context.colors.textDark,
                ),
              ),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSort = val);
              },
            );
          }),

          SizedBox(height: 16),

          // --- TOMBOL AKSI ---
          Row(
            children: [
              // Tombol Reset
              OutlinedButton(
                onPressed: () => _reset(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.divider),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Reset",
                  style: GoogleFonts.plusJakartaSans(
                    color: context.colors.textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Tombol Terapkan
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _apply(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryOrange,
                    foregroundColor: context.colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    "Terapkan Filter",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
