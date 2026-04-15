/// Sentralisasi konfigurasi layanan API untuk mempermudah manajemen Endpoint.
class ApiService {
  /// Base URL API - Sekarang mengarah ke Production (Railway)
  /// Kita tidak perlu membedakan platform lagi karena URL ini bisa diakses dari mana saja.
  static String get baseUrl =>
      'https://food-backend-production-0817.up.railway.app/api';

  /// Base Domain URL (Tanpa sub-route /api) untuk resolusi host.
  static String get baseDomain =>
      'https://food-backend-production-0817.up.railway.app';

  // --- Daftar Endpoint Rute (REST API) ---

  // Otentikasi
  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';

  // Profil User
  static String get profile => '$baseUrl/profile';

  static String get adminStats => '$baseUrl/admin/stats';
  static String get notifications => '$baseUrl/notifications';

  // Katalog Produk/Makanan
  static String get foods => '$baseUrl/foods';

  // Pembayaran / Pesanan
  static String get orders => '$baseUrl/orders'; // POST create order (public)
  static String get userOrders => '$baseUrl/user/orders'; // GET order by user
  static String get adminOrders =>
      '$baseUrl/admin/orders'; // GET all orders (admin only)
  static String adminOrderById(int id) =>
      '$baseUrl/admin/orders/$id'; // PUT update status (admin only)
  static String get adminUsers =>
      '$baseUrl/admin/users'; // GET all users (admin only)

  /// Path URL untuk memanggil resource Asset/Statis dari server Backend (contoh: load gambar)
  /// Contoh: ${ApiService.staticFiles}roti_keju.png
  static String get staticFiles => '$baseDomain/static/';

  /// Fungsi sakti untuk membersihkan dan membangun URL gambar yang valid.
  /// Bisa menangani URL lengkap (http://...) maupun path relatif (/static/...)
  static String getDisplayImage(String? path) {
    if (path == null || path.isEmpty) return '';
    
    // Jika sudah berupa URL lengkap, kembalikan langsung
    if (path.startsWith('http')) return path;

    // Jika diawali /static, kita gabungkan dengan baseDomain
    if (path.startsWith('/static')) {
      return '$baseDomain$path';
    }

    // Jika hanya nama file saja, kita arahkan ke folder static/uploads (disesuaikan srv)
    final cleaned = path.startsWith('/') ? path : '/$path';
    return '$baseDomain/static$cleaned';
  }
}
