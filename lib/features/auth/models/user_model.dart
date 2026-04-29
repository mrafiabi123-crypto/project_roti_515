class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.photoUrl,
    this.createdAt,
  });

  /// Factory untuk mengonversi JSON dari API menjadi objek UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'],
      address: json['address'],
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  /// Menghasilkan label waktu relatif (Contoh: "2 hari yang lalu")
  String get timeAgo {
    if (createdAt == null) return 'Baru saja';
    
    final diff = DateTime.now().difference(createdAt!);
    
    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Sekarang' : '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}j';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}h';
    } else {
      // Format sederhana: DD/MM/YYYY
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  /// Mengonversi objek kembali ke Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
