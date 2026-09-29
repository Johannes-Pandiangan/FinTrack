import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activeFilter = 'Semua'; // Filter tipe (Pemasukan/Pengeluaran/Semua)
  String _selectedMonth = 'September 2026'; // Filter bulan aktif

  // Fungsi pembuat format Rupiah
  String formatRp(double amount) {
    String str = amount.toInt().toString();
    String res = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      res = str[i] + res;
      count++;
      if (count % 3 == 0 && i != 0) res = '.$res';
    }
    return res;
  }

  // Fungsi pengubah format tanggal (contoh: 25 September 2026)
  String _formatDateHeader(DateTime date) {
    const List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Kalkulasi Data Saldo Aktif
    double totalPemasukan = 0;
    double totalPengeluaran = 0;

    for (var t in dummyTransactions) {
      if (t.type == 'Pemasukan')
        totalPemasukan += t.amount;
      else
        totalPengeluaran += t.amount;
    }
    double totalSaldo = totalPemasukan - totalPengeluaran;

    // 2. Filter Data Transaksi berdasarkan tipe
    List<TransactionRecord> filteredTransactions = dummyTransactions.where((t) {
      if (_activeFilter == 'Semua') return true;
      return t.type == _activeFilter;
    }).toList();

    // Pastikan data terurut dari yang terbaru (descending)
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    // 3. Kelompokkan Data Berdasarkan Tanggal
    Map<String, List<TransactionRecord>> groupedTransactions = {};
    for (var t in filteredTransactions) {
      String dateString = _formatDateHeader(t.date);
      if (!groupedTransactions.containsKey(dateString)) {
        groupedTransactions[dateString] = [];
      }
      groupedTransactions[dateString]!.add(t);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Halo, Fin Track', style: TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU SALDO UTAMA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C5A3E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('TOTAL SALDO AKTIF', style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.visibility_outlined, color: Colors.white70,
                          size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Rp ${formatRp(totalSaldo)}', style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSubBalance(Icons.arrow_downward, 'Pemasukan',
                            '+Rp ${formatRp(totalPemasukan)}',
                            const Color(0xFF4ADE80)),
                        _buildSubBalance(Icons.arrow_upward, 'Pengeluaran',
                            '-Rp ${formatRp(totalPengeluaran)}',
                            const Color(0xFFF87171)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // TOMBOL FILTER TIPE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterButton(
                    'Pemasukan', 'Catat Masuk', Icons.arrow_downward,
                    const Color(0xFFE5F5EF), const Color(0xFF0C5A3E)),
                _buildFilterButton(
                    'Pengeluaran', 'Catat Keluar', Icons.arrow_upward,
                    const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
                _buildFilterButton(
                    'Semua', 'Semua', Icons.tune, const Color(0xFFEEF2FF),
                    const Color(0xFF4F46E5)),
              ],
            ),
            const SizedBox(height: 24),

            // HEADER RIWAYAT & FILTER BULAN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Transaksi', style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
                // Dropdown Filter Bulan
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Text(_selectedMonth, style: const TextStyle(
                          color: Color(0xFF0C5A3E),
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                      const Icon(
                          Icons.arrow_drop_down, color: Color(0xFF0C5A3E)),
                    ],
                  ),
                  itemBuilder: (context) =>
                      ['September 2026', 'Agustus 2026', 'Juli 2026']
                          .map((month) =>
                          PopupMenuItem(
                            value: month,
                            child: Text(month, style: TextStyle(
                                fontWeight: _selectedMonth == month ? FontWeight
                                    .bold : FontWeight.normal)),
                          ))
                          .toList(),
                  onSelected: (value) {
                    setState(() {
                      _selectedMonth = value;
                      // Catatan: Pada implementasi backend nanti, memori akan mengambil data berdasarkan bulan yang dipilih di sini.
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // DAFTAR TRANSAKSI (Dikelompokkan Berdasarkan Tanggal)
            Expanded(
              child: groupedTransactions.isEmpty
                  ? const Center(child: Text(
                  'Belum ada transaksi.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: groupedTransactions.keys.length,
                itemBuilder: (context, index) {
                  String dateHeader = groupedTransactions.keys.elementAt(index);
                  List<
                      TransactionRecord> dailyTransactions = groupedTransactions[dateHeader]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tanggal Header & Garis Bawah Tipis
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateHeader, style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87)),
                            const SizedBox(height: 4),
                            Divider(color: Colors.grey.shade300,
                                thickness: 1,
                                height: 1),
                          ],
                        ),
                      ),
                      // Daftar item pada hari tersebut
                      ...dailyTransactions.map((t) {
                        bool isIncome = t.type == 'Pemasukan';
                        return _buildTransactionItem(
                          t.description,
                          dummyCategories
                              .firstWhere((c) => c.id == t.categoryId)
                              .name,
                          '${isIncome ? '' : '-'}Rp${formatRp(t.amount)}',
                          isIncome,
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubBalance(IconData icon, String title, String amount,
      Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(amount, style: const TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(String filterValue, String label, IconData icon,
      Color bgColor, Color iconColor) {
    bool isActive = _activeFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = filterValue;
        });
      },
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? iconColor : Colors.grey.shade200,
              width: isActive ? 2 : 1),
        ),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: bgColor,
                radius: 20,
                child: Icon(icon, color: iconColor)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String category, String amount,
      bool isIncome) {
    Color iconColor = isIncome ? Colors.green : Colors.red;
    Color amountColor = isIncome ? const Color(0xFF0C5A3E) : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(
                isIncome ? Icons.account_balance_wallet : Icons.shopping_bag,
                color: iconColor,
                size: 20,
              )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87)),
                const SizedBox(height: 4),
                Text(category.toUpperCase(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(
              color: amountColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}