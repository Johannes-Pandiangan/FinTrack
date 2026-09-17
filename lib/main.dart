import 'package:flutter/material.dart';

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan pita debug
      title: 'FinTrack',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinTrack - Halo, Anak Kost!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Widget Card Saldo Utama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Rp 1.500.000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Widget Ringkasan Pemasukan & Pengeluaran
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Pemasukan', 'Rp 2.000.000', Colors.green, Icons.arrow_downward)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Pengeluaran', 'Rp 500.000', Colors.red, Icons.arrow_upward)),
              ],
            ),
            const SizedBox(height: 24),

            // Judul Riwayat
            const Text('Riwayat Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 3. Widget Daftar Transaksi Statis
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionItem('Makan Siang', 'Makanan', '- Rp 25.000', Colors.red),
                  _buildTransactionItem('Beli Paket Data', 'Tagihan', '- Rp 75.000', Colors.red),
                  _buildTransactionItem('Transfer Orang Tua', 'Pemasukan', '+ Rp 1.000.000', Colors.green),
                  _buildTransactionItem('Nonton Bioskop', 'Hiburan', '- Rp 50.000', Colors.red),
                  _buildTransactionItem('Indomie & Telur', 'Makanan', '- Rp 15.000', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
      // 4. Tombol Tambah Transaksi
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Fitur belum aktif, hanya UI statis
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fungsi pembantu untuk membuat card ringkasan (reusable widget)
  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Fungsi pembantu untuk membuat list item transaksi statis
  Widget _buildTransactionItem(String title, String category, String amount, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(color == Colors.green ? Icons.account_balance_wallet : Icons.shopping_bag, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category),
        trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}