import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT STATE & PROVIDER ---
import '../../../presentation/state/cart_provider.dart';
// import '../../presentation/state/auth_provider.dart'; // Aktifkan jika sudah ada AuthProvider

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Warna Tema Roti 515
  final Color primaryOrange = const Color(0xFFD4812C);
  final Color textBrown = const Color(0xFF5D4037);

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _paymentMethod = "COD"; 
  bool _isOrdering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    // 1. Validasi Input
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi data pengiriman.")),
      );
      return;
    }

    setState(() => _isOrdering = true);
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Hitung Total (Karena Rupiah, kita gunakan int)
    int subtotal = cart.totalPrice;
    int deliveryFee = 5000;
    int finalTotal = subtotal + deliveryFee;

    try {
      final orderData = {
        "guest_name": _nameController.text,
        "guest_phone": _phoneController.text,
        "guest_address": _addressController.text,
        "total": finalTotal.toDouble(), // Backend biasanya minta double/float
        "items": cart.items.map((item) => {
          "product_id": item.product.id, // SUDAH DISESUAIKAN (Bukan food_id)
          "quantity": item.quantity,
          "price": item.product.price.toDouble()
        }).toList()
      };

      // Gunakan IP Laptop kamu atau 10.0.2.2 untuk Emulator
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/orders'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        cart.clearCart();
        if (mounted) _showSuccessDialog();
      } else {
        throw Exception("Gagal membuat pesanan.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(Icons.check_circle, color: primaryOrange, size: 80),
        content: Text(
          "Pesanan Berhasil!\nTerima kasih telah memesan di Roti 515.",
          textAlign: TextAlign.center,
          style: GoogleFonts.pragatiNarrow(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(backgroundColor: textBrown),
              child: const Text("Kembali ke Menu", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Checkout", style: GoogleFonts.dmSerifDisplay(color: textBrown)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Detail Pengiriman"),
            const SizedBox(height: 15),
            _buildInputField("Nama Penerima", _nameController, Icons.person_outline),
            _buildInputField("No. WhatsApp", _phoneController, Icons.phone_android, type: TextInputType.phone),
            _buildInputField("Alamat Lengkap", _addressController, Icons.location_on_outlined, maxLines: 3),
            
            const SizedBox(height: 30),
            _buildSectionTitle("Metode Pembayaran"),
            const SizedBox(height: 10),
            _buildPaymentCard("COD", "Bayar di Tempat", Icons.payments_outlined),
            
            const SizedBox(height: 30),
            _buildSectionTitle("Ringkasan Pesanan"),
            const SizedBox(height: 15),
            _buildOrderSummary(cart),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isOrdering ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isOrdering 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("Konfirmasi Pesanan", style: GoogleFonts.pragatiNarrow(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.pragatiNarrow(fontSize: 20, fontWeight: FontWeight.bold, color: textBrown));
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryOrange),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: primaryOrange)),
      child: Row(
        children: [
          Icon(icon, color: primaryOrange),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Icon(Icons.check_circle, color: primaryOrange),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal"),
              Text("Rp ${cart.totalPrice}"),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Biaya Ongkir"),
              Text("Rp 5000"),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold, color: textBrown)),
              Text("Rp ${cart.totalPrice + 5000}", style: TextStyle(fontWeight: FontWeight.bold, color: primaryOrange, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}