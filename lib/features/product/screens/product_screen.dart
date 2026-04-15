import 'package:flutter/material.dart'; // Import kerangka utama untuk sistem desain grafis UI material Flutter
import 'package:google_fonts/google_fonts.dart'; // Paket untuk menggunakan font moderen dari Google Fonts API (Inter, PragatiNarrow, dll.)
import 'package:provider/provider.dart'; // Paket untuk memanggil State Provider agar data otomatis diperbarui jika terjadi perubahan

// Mengimpor file pondasi warna (AppColors)
import '../../../core/constants/app_colors.dart';
// Mengimpor ProductProvider yang menyediakan filter, search, & mengunduh data daftar produk
import '../providers/product_provider.dart';

// Mengimpor komponen-komponen UI modular khusus layar Produk ini (Modularisasi mempermudah pengecekan kode)
import '../widgets/product_app_bar.dart'; // Komponen kepala atas (App Bar) dengan keranjang belanja
import '../widgets/product_category_bar.dart'; // Komponen baris pil (kapsul) kategori (Roti, Biskuit, dll.)
import '../widgets/product_card.dart'; // Komponen kardus tampilan daftar produk
import '../../../core/widgets/staggered_fade_animation.dart'; // Animasi efek transisi saat me-*render* produk

// Ini adalah Layar Menu Produk UTAMA. Berjenis StatefulWidget (seperti komponen dinamis).
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

// Logic layar
class _ProductScreenState extends State<ProductScreen> {
  // Membuat konfigurasi statis daftar jenis tulisan Kategori yang ditampilkan secara mendatar
  final List<String> categories = ["Semua", "Roti", "Biskuit"];

  // Variabel GlobalKey ini cukup krusial:
  // Kita membuat sekeranjang kunci unik (_imageKeys) yang terhubung ke indeks dari setiap "product kardus(card)".
  // Tujuannya adalah membantu animasi "Terbang Masuk Keranjang" nantinya dapat mengetahui posisi spesifik gambar produk di layar.
  final Map<int, GlobalKey> _imageKeys = {};

  // initState memicu aksi sekali saja ketika jendela ini terbangun (masuk tampilannya)
  @override
  void initState() {
    super.initState();
    // Gunakan Future.microtask agar kode penembakan API ini terjadi tepat setelah Frame (lukisan visual) awal selesai termuat.
    // Minta Provider untuk memanggil API backend (fetchProducts) untuk memuat katalog
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    Future.microtask(() => productProvider.fetchProducts());
  }

  // Fungsi khusus untuk menangkap teks masukan di kolom "Pencarian" (Search Bar)
  void _onSearchChanged(String query) {
    // Perintah ke Provider: "Tolong unduh data produk lagi tapi dengan parameter (kata kunci / query) yang aku kasih ini"
    Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(query: query);
  }

  // Fungsi utama untuk mengatur dan menggambar tata letak widget
  @override
  Widget build(BuildContext context) {
    // Deklarasi provider pada fungsi build berarti kita "Berlangganan" layaknya Youtube. 
    // Saat data produk ada dan Provider mengatakan "notifyListeners()", fungsi build() ini akan dipanggil ulang agar gambar muncul
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.products; // Mengkopasi array list hasil download Produk dari provider ke variabel lokal agar singkat

    // Scaffold me-return kerangka dasar layar
    return Scaffold(
      backgroundColor: AppColors.bgColor, // Pemberian warna tembok belakang layout dengan keabuabuan standar Roti515

      // Kolom untuk menata UI memanjang kebawah (Vertikal)
      body: Column(
        children: [
          // 1. BAGIAN ATAS (App bar) - Kita lewatkan fungsi pencarian _onSearchChanged ke komponen ini, 
          // tempat di mana textfield kustom pencarian berada.
          ProductAppBar(onSearchChanged: _onSearchChanged),

          // Membungkus list produk di dalam "Expanded" agar dia mengambil semua ruang kosong sisa kebawah sampai pojok hp.
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero, // Hapus setelan bantalan awal dari ListView default
              children: [
                
                // 2. BAGIAN FILTER KATEGORI: Komponen modular memanjang kesamping yang menampilkan kapsul (Roti, Biskuit)
                // Daftar string Kategori dimasukkan dari variabel `categories` di atas.
                ProductCategoryBar(categories: categories),

                // 3. TEKS LABEL DAFTAR ("Produk Kami")
                // Padding diatur menjorok menjauh dari kiri teks agak tidak pinggir betul (kiri 20, atas 24, bawah 16)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    "Produk Kami",
                    // Menggunakan tipe tulisan yang khas (Pragati Narrow) menyesuaikan desain UI/UX aslinya
                    style: GoogleFonts.pragatiNarrow(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark, // Warna hitam kelam
                    ),
                  ),
                ),

                // 4. BAGIAN DAFTAR KOTAK PRODUK (Grid produk)
                // Percabangan (If-else): Jika provider masih dalam tahap memuat (loading)
                if (provider.isLoading)
                  const Center(
                    // Munculkan indikator bundar muter berwarna oranye tanda sedang memproses
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange),
                  )
                else
                  // Jika selesai memuat asinkronus, render daftar katalog bertipe jaring / Grid
                  GridView.builder(
                    shrinkWrap: true, // Grid perlu dibungkus ke ukuran terkecil kontennya agar sejajar aman di dalam ListView
                    physics: const NeverScrollableScrollPhysics(), // Buat scroll dari Grid mati (Scroll di takeover dan dikontrol sama `ListView` di atasnya tadi)
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Berikan padding 100 dibelakang agar tidak bentok batas bottom navigasi

                    // Peraturan pola Grid yang akan membelah kolom menjadi 2 bagian / 2 kolom produk menyamping (crossAxisCount)
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      mainAxisExtent: 280, // Mematok tinggi kartunya agar fix dan tidak gepeng pada berbagai ukuran rasio layar perangkat
                      crossAxisSpacing: 15, // Gap spasium/jurang lebar antar 2 kolom kesamping sebesar 15
                      mainAxisSpacing: 15, // Gap spasium vertikal batas atasbawah sebesar 15
                    ),
                    itemCount: products.length, // Beritahu list ini ada berapa jumlah data

                    // Melukis masing-masing produk (terulang sampai nilai `products.length` habis dicetak)
                    itemBuilder: (context, index) {
                      // Ini logic pengisian kunci: Jika index ini belum ada kuncinya, ciptakan Key baru agar 
                      // widget produknya bisa "dikenali" lokasinya nanti pada map
                      _imageKeys.putIfAbsent(index, () => GlobalKey());

                      // Membungkus ke animasi yang membuat si produk Card muncul dengan pelan (fade-in + slide) 
                      return StaggeredFadeAnimation(
                        index: index, // Memberi jeda tiap animasi (sekuensial lambat bergantian) berdasarkan indeks urutannya
                        
                        // Isi nyata (komponen kardus kustom nya)
                        child: ProductCard(
                          product: products[index], // Kirim data detail objek per satuannya
                          imageKey: _imageKeys[index]!, // Kirim kunci pendeteksi lokasinya juga
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}