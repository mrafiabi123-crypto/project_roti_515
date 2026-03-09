class User {
  final String id;
  final String name;
  final String email;
  final String token; // Token untuk otorisasi sesi

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });
}