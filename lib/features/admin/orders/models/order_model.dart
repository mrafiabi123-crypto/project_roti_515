import '../../../../core/network/api_service.dart';

// Model yang merepresentasikan satu item dalam pesanan
class OrderItemModel {
  final int productId;
  final String productName;
  final String imageUrl; // URL gambar produk dari server
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Backend melakukan Preload("Items.Product"), object direturn dengan key "food"
    final product = (json['food'] ?? json['product']) as Map<String, dynamic>?;

    // Ambil nama dari nested product object (bukan top-level)
    final rawName = product?['name'] as String? ?? '';

    // Ambil image_url dari nested product, lalu bangun URL lengkap
    final rawImage = product?['image_url'] as String? ?? '';
    String fullImageUrl = '';
    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        fullImageUrl = rawImage;
      } else if (rawImage.startsWith('/static')) {
        fullImageUrl = '${ApiService.baseDomain}$rawImage';
      } else {
        // Nama file saja, misal: "roti_coklat.png"
        final cleaned = rawImage.startsWith('/') ? rawImage : '/$rawImage';
        fullImageUrl = '${ApiService.baseDomain}/static$cleaned';
      }
    }

    return OrderItemModel(
      productId: json['product_id'] ?? 0,
      productName: rawName,
      imageUrl: fullImageUrl,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

// Model utama untuk satu pesanan
class OrderModel {
  final int id;
  final String orderId;
  final String guestName;
  final String guestPhone;
  final String guestAddress;
  final double total;
  final String status;
  final String? pickupTime; // Jam pengambilan yang ditetapkan admin (nullable)
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.guestName,
    required this.guestPhone,
    required this.guestAddress,
    required this.total,
    required this.status,
    this.pickupTime,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<OrderItemModel> parsedItems = [];
    if (json['items'] != null) {
      for (var item in (json['items'] as List)) {
        parsedItems.add(OrderItemModel.fromJson(item));
      }
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['created_at'] ?? '').toLocal();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    // Gunakan order_ref jika ada (ORD-XYZW), bila backend versi lama gunakan ID fallback
    final rawId = json['id'] ?? 0;
    final formattedOrderId = (json['order_ref'] != null && json['order_ref'].toString().isNotEmpty)
        ? json['order_ref'].toString()
        : 'ROTI515-$rawId';

    // Cek objek user yang dipreload
    final userMap = json['user'] as Map<String, dynamic>?;
    
    final String parsedName = (userMap != null && userMap['name'] != null && userMap['name'].toString().isNotEmpty)
        ? userMap['name']
        : (json['guest_name'] != null && json['guest_name'].toString().isNotEmpty ? json['guest_name'] : 'Pelanggan Toko');
        
    final String parsedPhone = (userMap != null && userMap['phone'] != null && userMap['phone'].toString().isNotEmpty)
        ? userMap['phone']
        : (json['guest_phone'] != null && json['guest_phone'].toString().isNotEmpty ? json['guest_phone'] : '-');
        
    final String parsedAddress = (userMap != null && userMap['address'] != null && userMap['address'].toString().isNotEmpty)
        ? userMap['address']
        : (json['guest_address'] != null && json['guest_address'].toString().isNotEmpty ? json['guest_address'] : '-');

    return OrderModel(
      id: rawId,
      orderId: formattedOrderId,
      guestName: parsedName,
      guestPhone: parsedPhone,
      guestAddress: parsedAddress,
      total: (json['total'] ?? 0).toDouble(),
      status: (json['status'] ?? 'Pending').toLowerCase(),
      pickupTime: json['pickup_time'] as String?, // nullable dari backend
      createdAt: parsedDate,
      items: parsedItems,
    );
  }

  // --- HELPER STATUS ---
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed' || status == 'done';
  bool get isCancelled => status == 'cancelled';

  // Apakah jam pengambilan sudah ditetapkan admin
  bool get hasPickupTime => pickupTime != null && pickupTime!.isNotEmpty;

  // Gambar thumbnail: ambil dari item pertama jika ada
  String get thumbnailImage =>
      items.isNotEmpty ? items.first.imageUrl : '';

  // Format waktu relatif
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds} detik lalu';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  // Format harga ke Rupiah
  String get formattedTotal {
    final totalInt = total.toInt();
    final s = totalInt.toString();
    final buf = StringBuffer('Rp. ');
    final mod = s.length % 3;
    buf.write(s.substring(0, mod == 0 ? 3 : mod));
    for (int i = (mod == 0 ? 3 : mod); i < s.length; i += 3) {
      buf.write('.');
      buf.write(s.substring(i, i + 3));
    }
    return buf.toString();
  }
}
