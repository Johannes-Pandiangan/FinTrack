import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/dummy_data.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedType = 'Pengeluaran';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      // 1. Ambil nilai input
      final double amount = double.parse(_amountController.text);
      final String desc = _descController.text;

      // 2. Buat objek transaksi baru
      final newTransaction = TransactionRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID unik acak
        categoryId: _selectedCategoryId!,
        description: desc,
        amount: amount,
        date: DateTime.now(),
        type: _selectedType,
      );

      // 3. Masukkan ke urutan paling atas di list dummy
      dummyTransactions.insert(0, newTransaction);

      // 4. Tutup halaman dan kirim sinyal berhasil (true)
      Navigator.pop(context, true);
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memfilter daftar kategori yang muncul di dropdown berdasarkan tipe yang dipilih
    final availableCategories = dummyCategories.where((c) => c.type == _selectedType).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Catat Transaksi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pemilih Tipe Transaksi (Tombol Toggle)
              Row(
                children: [
                  Expanded(child: _buildTypeButton('Pengeluaran', Icons.arrow_upward, Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTypeButton('Pemasukan', Icons.arrow_downward, Colors.green)),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Input Nominal
              const Text('Nominal (Rp)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nominal tidak boleh kosong';
                  if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Dropdown Kategori
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: const Text('Pilih Kategori'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                items: availableCategories.map((category) {
                  return DropdownMenuItem(value: category.id, child: Text(category.name));
                }).toList(),
                onChanged: (value) {
                  setState(() { _selectedCategoryId = value; });
                },
              ),
              const SizedBox(height: 20),

              // 4. Input Catatan
              const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  hintText: 'Misal: Beli makan siang',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Catatan tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // 5. Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C5A3E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveTransaction,
                  child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, IconData icon, Color color) {
    bool isSelected = _selectedType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = title;
          _selectedCategoryId = null; // Reset kategori saat tipe berubah
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}