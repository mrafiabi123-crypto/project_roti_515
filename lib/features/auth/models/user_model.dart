class UserModel {
  final int? id; // Menggunakan int? karena ID dari database (seperti MySQL/PostgreSQL) biasanya berupa angka
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? address;
  final String? photoUrl;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.photoUrl,
  });

  // Fungsi mengubah JSON (dari Backend Go) menjadi Objek Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'], 
      name: json['name'] ?? '', // Tanda ?? '' artinya jika dari backend null/kosong, isi dengan string kosong
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user', // Default role adalah 'user'
      address: json['address'],
      photoUrl: json['photo_url'], // Perhatikan: di Dart pakai camelCase (photoUrl), tapi kunci JSON-nya pakai snake_case (photo_url) sesuai Golang
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
    };
  }
}