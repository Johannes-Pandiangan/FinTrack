import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../data/dummy_data.dart';

class AddTransactionScreen extends StatefulWidget {
  // Parameter ini menentukan apakah layar ini untuk Tambah (null) atau Edit (ada data)
  final TransactionRecord? transactionToEdit;

  const AddTransactionScreen({Key? key, this.transactionToEdit}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedType = 'Pengeluaran';
  String? _selectedCategory;
  bool _isSubmitting = false; // State untuk simulasi loading

  @override
  void initState() {
    super.initState();
    // Jika ada data yang dilempar (Mode Edit), isi otomatis semua kolom input
    if (widget.transactionToEdit != null) {
      _amountController.text = widget.transactionToEdit!.amount.toInt().toString();
      _descController.text = widget.transactionToEdit!.description;
      _selectedType = widget.transactionToEdit!.type;
      _selectedCategory = widget.transactionToEdit!.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Validasi form agar input tidak boleh kosong dan sesuai format
    if (_formKey.currentState!.validate()) {
      setState(() { _isSubmitting = true; }); // Memulai indikator loading

      // Simulasi jeda pemuatan data ke server (2 detik)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      double amount = double.parse(_amountController.text);

      if (widget.transactionToEdit == null) {
        // PROSES CREATE (Tambah Baru)
        final newTx = TransactionRecord(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          type: _selectedType,
          amount: amount,
          categoryId: _selectedCategory ?? dummyCategories.first.id,
          description: _descController.text,
          date: DateTime.now(),
        );
        dummyTransactions.add(newTx);
      } else {
        // PROSES UPDATE (Edit Data Lama)
        int index = dummyTransactions.indexWhere((t) => t.id == widget.transactionToEdit!.id);
        if (index != -1) {
          // Ganti seluruh objek lama dengan objek baru yang berisi data hasil editan
          dummyTransactions[index] = TransactionRecord(
            id: widget.transactionToEdit!.id, // Pertahankan ID asli
            type: _selectedType,
            amount: amount,
            categoryId: _selectedCategory ?? widget.transactionToEdit!.categoryId,
            description: _descController.text,
            date: widget.transactionToEdit!.date, // Pertahankan tanggal asli
          );
        }
      }

      // Pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.transactionToEdit == null ? 'Transaksi berhasil ditambahkan!' : 'Transaksi berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya dan mengirim sinyal untuk refresh UI
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.transactionToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Jenis Input: Segmented Button (Tipe Transaksi)
              const Text('Jenis Transaksi', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Pengeluaran', style: TextStyle(fontSize: 11)),
                      value: 'Pengeluaran',
                      groupValue: _selectedType,
                      activeColor: Colors.red,
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Pemasukan', style: TextStyle(fontSize: 12)),
                      value: 'Pemasukan',
                      groupValue: _selectedType,
                      activeColor: Colors.green,
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Jenis Input: Teks Numerik (Nominal)
              const Text('Nominal (Rp)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Cegah input selain angka
                decoration: InputDecoration(
                  hintText: '0',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nominal tidak boleh kosong';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Masukkan nominal yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Jenis Input: Dropdown (Kategori)
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Pilih Kategori'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                items: dummyCategories.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Pilih kategori terlebih dahulu' : null,
              ),
              const SizedBox(height: 20),

              // 4. Jenis Input: Teks Panjang (Deskripsi)
              const Text('Deskripsi / Catatan', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis catatan transaksi (cth: Makan siang)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Deskripsi tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Tombol Submit dengan Simulasi Loading
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C5A3E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm, // Nonaktifkan submit saat loading berjalan
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditMode ? 'Simpan Perubahan' : 'Tambah Transaksi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}