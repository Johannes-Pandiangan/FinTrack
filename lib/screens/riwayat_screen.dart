import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _activeFilter = 'Semua';
  bool _isLoading = true; // State untuk simulasi loading pemuatan data awal

  @override
  void initState() {
    super.initState();
    _simulateLoadingData();
  }

  // Menyimulasikan jeda pemuatan dari server
  void _simulateLoadingData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  // Fungsi DELETE: Menampilkan dialog konfirmasi destruktif
  void _showDeleteConfirmation(TransactionRecord transaction) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Hapus Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus transaksi "${transaction.description}" senilai Rp${formatRp(transaction.amount)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Proses Hapus Data dari Dummy List
                setState(() {
                  dummyTransactions.removeWhere((t) => t.id == transaction.id);
                });
                Navigator.pop(ctx);

                // Pesan Sukses Aksi Selesai
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(TransactionRecord transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionScreen(transactionToEdit: transaction)),
    );

    // Refresh UI jika ada perubahan data dari layar edit
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPengeluaranBulanIni = 0;
    for (var t in dummyTransactions) {
      if (t.type == 'Pengeluaran') totalPengeluaranBulanIni += t.amount;
    }
    int hariBerjalan = DateTime.now().day;
    double rataRataHarian = totalPengeluaranBulanIni / (hariBerjalan > 0 ? hariBerjalan : 1);

    List<TransactionRecord> filteredTransactions = dummyTransactions.where((t) {
      if (_activeFilter == 'Semua') return true;
      return t.type == _activeFilter;
    }).toList();

    // Urutkan dari terbaru
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Riwayat Transaksi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C5A3E))) // Indikator Loading
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildPillButton('Semua'),
                const SizedBox(width: 8),
                _buildPillButton('Pengeluaran'),
                const SizedBox(width: 8),
                _buildPillButton('Pemasukan'),
              ],
            ),
            const SizedBox(height: 20),

            // KARTU RINGKASAN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF6EE7B7), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.insights, color: Color(0xFF065F46), size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text('Ringkasan Bulan Ini', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Pengeluaran', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('Rp ${formatRp(totalPengeluaranBulanIni)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF111827))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rata-rata Harian', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('Rp ${formatRp(rataRataHarian)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF111827))),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // DAFTAR TRANSAKSI DENGAN EMPTY STATE
            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center( // Skenario daftar kosong dengan petunjuk tindakan
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Belum ada riwayat $_activeFilter', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Mulai catat keuangan Anda dengan menekan tombol + di bawah.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final t = filteredTransactions[index];
                  bool isIncome = t.type == 'Pemasukan';
                  String categoryName = dummyCategories.firstWhere((c) => c.id == t.categoryId).name;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.1), child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red, size: 16)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(categoryName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Nominal dan Tombol Aksi (Edit & Hapus)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${isIncome ? '+' : '-'} Rp ${formatRp(t.amount)}', style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _navigateToEditScreen(t),
                                  child: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueGrey),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => _showDeleteConfirmation(t),
                                  child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton(String label) {
    bool isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() { _activeFilter = label; });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0C5A3E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? const Color(0xFF0C5A3E) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12),
        ),
      ),
    );
  }
}