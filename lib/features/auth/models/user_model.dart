class UserModel {
  final int? id; // Menggunakan int? karena ID dari database (seperti MySQL/PostgreSQL) biasanya berupa angka
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? address;
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.photoUrl,
    this.createdAt,
  });

  // Fungsi mengubah JSON (dari Backend Go) menjadi Objek Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']).toLocal();
      } catch (_) {}
    }

    return UserModel(
      id: json['id'], 
      name: json['name'] ?? '', // Tanda ?? '' artinya jika dari backend null/kosong, isi dengan string kosong
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user', // Default role adalah 'user'
      address: json['address'],
      photoUrl: json['photo_url'], // Perhatikan: di Dart pakai camelCase (photoUrl), tapi kunci JSON-nya pakai snake_case (photo_url) sesuai Golang
      createdAt: parsedDate,
    );
  }

  // Fungsi mengubah Objek Dart menjadi JSON (Biasanya dipakai saat update profil)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Format waktu relatif untuk UI Admin
  String get timeAgo {
    if (createdAt == null) return 'Baru saja';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inSeconds < 60) return 'Sekarang';
    if (diff.inMinutes < 60) return '${diff.inMinutes} Menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} Jam lalu';
    return '${diff.inDays} Hari lalu';
  }
}