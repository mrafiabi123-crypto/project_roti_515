/// Utility untuk memformat harga ke format Rupiah.
/// Contoh: 15000 -> "15.000"
String formatRupiah(num price) {
  return price.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
}
