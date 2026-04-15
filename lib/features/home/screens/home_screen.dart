import 'package:flutter/material.dart'; // Import kerangka kerja dasar antarmuka pengguna Flutter
import 'package:provider/provider.dart'; // Import paket Provider untuk manajemen state (mengelola data yang berubah secara real-time)

// Mengimpor file konfigurasi warna kustom yang akan digunakan di seluruh aplikasi (misal untuk latar belakang)
import '../../../core/constants/app_colors.dart';
// Mengimpor ProductProvider yang bertugas mengambil, menyimpan, dan menyediakan data produk/makanan dari server
import '../../product/providers/product_provider.dart';

// Mengimpor widget-widget modular (pecahan UI kecil) secara terpisah agar kode tetap bersih dan mudah dibaca
import '../../../core/widgets/staggered_fade_animation.dart';
import '../widgets/home_app_bar.dart'; // Bagian navigasi atas (logo, keranjang, tombol cari)
import '../widgets/home_promo_banner.dart'; // Bagian spanduk promosi berjalan / slider
import '../widgets/home_section_header.dart'; // Bagian teks judul kategori (seperti "Bestsellers", "Menu Baru")
import '../widgets/bestseller_card.dart'; // Kartu/card desain khusus untuk item produk terlaris
import '../widgets/new_menu_card.dart'; // Kartu/card desain khusus untuk daftar menu baru
import '../widgets/home_footer.dart'; // Bagian footer berisi alamat dan sosmed

// Kelas utama Home Screen, ini adalah layar Beranda saat aplikasi pertama kali masuk.
// Menggunakan StatefulWidget karena layar ini perlu menangkap perubahaan state (seperti saat data selesai diload)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State milik HomeScreen di mana kita mengatur logika "sebelum layar ditampilkan" (siklus hidup aplikasi)
class _HomeScreenState extends State<HomeScreen> {
  // Fungsi initState() akan dipanggil sekali saat layar ini pertama kali dirender
  @override
  void initState() {
    super.initState();
    // Menggunakan Future.microtask untuk menunda pemanggilan fungsi fetchProducts sepersekian milidetik.
    // Ini berguna untuk menghindari error "setState() or markNeedsBuild called during build".
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    Future.microtask(() => productProvider.fetchProducts());
  }

  // Fungsi build() adalah tempat menyusun keseluruhan tata letak visual UI
  @override
  Widget build(BuildContext context) {
    // Menyambungkan layar ini dengan ProductProvider. Segala perubahan di data (misal proses loading selesai), layar akan di-refresh.
    final provider = Provider.of<ProductProvider>(context);

    // Scaffold adalah kanvas kosong tempat kita meletakkan elemen tampilan (Header, Body, Footer)
    return Scaffold(
      backgroundColor: AppColors.bgColor, // Memberikan warna latar kustom dari file constants (seperti keabu-abuan)

      // Di dalam Body, kita memeriksa logika loading. Apakah Provider masih mengambil data (isLoading == true)?
      body: provider.isLoading
          // JIKA MASIH LOADING: Tampilkan lingkaran indikator (Spinner) yang berada terpusat di tengah layar
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          // JIKA SUDAH SELESAI LOADING: Tampilkan layar konten beserta isinya
          : SingleChildScrollView( // Bungkus semuanya dengan SingleChildScrollView agar layar bisa digulir ke bawah
              // Memberikan jarak bawah 120 pixels agar daftar paling bawah tidak tertutup oleh tombol navigasi bottom bar (Menu Utama)
              padding: const EdgeInsets.only(bottom: 120),
              
              child: Column( // Menata semua komponen Home secara bertingkat mendatar / vertical (atas ke bawah)
                crossAxisAlignment: CrossAxisAlignment.start, // Ratakan semua anak widgetnya ke kiri
                children: [
                  // 1. BAGIAN APP BAR: Memanggil komponen HomeAppBar untuk header paling atas
                  const HomeAppBar(),
                  const SizedBox(height: 10), // Spasi antar elemen sebesar 10 pixel

                  // 2. BAGIAN BANNER PROMOSI: Memanggil komponen gambar slide Banner Promo
                  const HomePromoBanner(),
                  const SizedBox(height: 32),

                  // 3. BAGIAN PRODUK TERLARIS (BESTSELLERS)
                  // Header section berupa teks judul "Bestsellers"
                  const HomeSectionHeader(
                    title: "Bestsellers",
                    showArrows: true, // Menampilkan tanda anak panah untuk melihat produk lebih banyak
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 285, 
                    // ListView.builder untuk membuat kotak-kotak bisa di-*scroll* secara menyamping (horizontal)
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Arah guliran ke samping
                      padding: const EdgeInsets.symmetric(horizontal: 20), // Padding/celah kiri kanannya 20
                      // Banyaknya jumlah (jumlah kartu) ditentukan dari banyaknya data yang status bestsellernya aktif di Provider
                      itemCount: provider.bestsellers.length,
                      itemBuilder: (context, index) {
                        return StaggeredFadeAnimation(
                          index: index,
                          child: BestsellerCard(
                              product: provider.bestsellers[index]),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32), // Jeda jarak antar kategori

                  // 4. BAGIAN PRODUK MENU BARU
                  // Teks Judul section berbunyi "Menu Baru"
                  const HomeSectionHeader(
                    title: "Menu Baru",
                    showArrows: false, // Tidak pakai panah karena tidak perlu "Lihat Semua"
                  ),
                  const SizedBox(height: 16),
                  
                  // Kotak penampung desain kartu Menu Baru yang lebih pendek (tinggi 106 pixel)
                  SizedBox(
                    height: 106,
                    // Membuat fitur gulir mendatar juga untuk daftar menu baru
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      // Hitung jumlah data yang dikategorikan sebagai menu baru
                      itemCount: provider.newMenus.length,
                      itemBuilder: (context, index) {
                        return StaggeredFadeAnimation(
                          index: index,
                          child: NewMenuCard(
                              product: provider.newMenus[index]),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // 5. BAGIAN FOOTER (Alamat & Sosmed)
                  const HomeFooter(),
                ],
              ),
            ),
    );
  }
}