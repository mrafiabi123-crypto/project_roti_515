import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _orders = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final response = await http.get(
        // Ganti URL sesuai emulator/device Anda
        Uri.parse('http://localhost:8080/api/orders'), 
        headers: {"Authorization": "Bearer ${auth.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _orders = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal memuat pesanan";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        title: const Text("Order History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F6F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _orders.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildOrderCard(_orders[index]);
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Belum ada riwayat pesanan.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- REVISI: TAMPILKAN SEMUA ITEM ---
  Widget _buildOrderCard(dynamic order) {
    final items = order['items'] as List;
    final dateString = order['created_at'].toString().substring(0, 10);
    
    // Logic Status Color
    Color statusColor = Colors.orange;
    String status = order['status'];
    if (status == "Completed" || status == "Success") statusColor = Colors.green;
    if (status == "Cancelled") statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Tanggal & Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order Date: $dateString", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
              )
            ],
          ),
          
          const Divider(height: 24),

          // 2. LIST ITEM (LOOPING SEMUA MENU)
          // Kita pakai Column di dalam list view agar semua item muncul ke bawah
          Column(
            children: items.map((item) {
              final food = item['food'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Gambar Kecil
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                        image: DecorationImage(
                          image: NetworkImage(food['image_url'] ?? ''),
                          fit: BoxFit.cover,
                          onError: (e,s) {},
                        )
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Nama & Jumlah
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("${item['quantity']}x  @ \$${item['price']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),

                    // Total Harga per Item
                    Text("\$${(item['price'] * item['quantity'])}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),

          const Divider(height: 24),

          // 3. FOOTER (Total Harga & Tombol)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Order", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("\$${order['total']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              ElevatedButton(
                onPressed: () {}, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4913),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Reorder", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }
}