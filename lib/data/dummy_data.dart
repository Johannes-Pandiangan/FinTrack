// lib/data/dummy_data.dart

import '../models/transaction.dart';

// 1. DATA REFERENSI: 5 Kategori Sesuai Syarat UTS
final List<TransactionCategory> dummyCategories = [
  TransactionCategory(id: 'c1', name: 'Makanan & Minuman', type: 'Pengeluaran'),
  TransactionCategory(id: 'c2', name: 'Transportasi', type: 'Pengeluaran'),
  TransactionCategory(id: 'c3', name: 'Tagihan & Kos', type: 'Pengeluaran'),
  TransactionCategory(id: 'c4', name: 'Hiburan', type: 'Pengeluaran'),
  TransactionCategory(id: 'c5', name: 'Uang Saku / Gaji', type: 'Pemasukan'),
];

// 2. DATA UTAMA: 20 Record Transaksi Simulasi Sesuai Syarat UTS
// Tanggal diset mundur dari hari ini agar terlihat realistis di riwayat
final List<TransactionRecord> dummyTransactions = [
  // --- Transaksi Terbaru ---
  TransactionRecord(id: 't1', categoryId: 'c1', description: 'Nasi Padang Lauk Ayam', amount: 18000, date: DateTime.now().subtract(const Duration(hours: 2)), type: 'Pengeluaran'),
  TransactionRecord(id: 't2', categoryId: 'c2', description: 'Ojek Online ke Kampus', amount: 12000, date: DateTime.now().subtract(const Duration(hours: 5)), type: 'Pengeluaran'),

  // --- Kemarin ---
  TransactionRecord(id: 't3', categoryId: 'c1', description: 'Kopi Kenangan', amount: 22000, date: DateTime.now().subtract(const Duration(days: 1)), type: 'Pengeluaran'),
  TransactionRecord(id: 't4', categoryId: 'c4', description: 'Langganan Spotify', amount: 54000, date: DateTime.now().subtract(const Duration(days: 1)), type: 'Pengeluaran'),
  TransactionRecord(id: 't5', categoryId: 'c1', description: 'Sate Padang Malam', amount: 20000, date: DateTime.now().subtract(const Duration(days: 1)), type: 'Pengeluaran'),

  // --- 2 Hari Lalu ---
  TransactionRecord(id: 't6', categoryId: 'c3', description: 'Token Listrik Kos', amount: 100000, date: DateTime.now().subtract(const Duration(days: 2)), type: 'Pengeluaran'),
  TransactionRecord(id: 't7', categoryId: 'c5', description: 'Transfer Bulanan Ortu', amount: 1500000, date: DateTime.now().subtract(const Duration(days: 2)), type: 'Pemasukan'),
  TransactionRecord(id: 't8', categoryId: 'c2', description: 'Isi Bensin Motor', amount: 30000, date: DateTime.now().subtract(const Duration(days: 2)), type: 'Pengeluaran'),

  // --- 3 Hari Lalu ---
  TransactionRecord(id: 't9', categoryId: 'c1', description: 'Beli Galon Aqua', amount: 20000, date: DateTime.now().subtract(const Duration(days: 3)), type: 'Pengeluaran'),
  TransactionRecord(id: 't10', categoryId: 'c1', description: 'Mie Gacoan', amount: 25000, date: DateTime.now().subtract(const Duration(days: 3)), type: 'Pengeluaran'),

  // --- 4 Hari Lalu ---
  TransactionRecord(id: 't11', categoryId: 'c3', description: 'Paket Data Telkomsel', amount: 75000, date: DateTime.now().subtract(const Duration(days: 4)), type: 'Pengeluaran'),
  TransactionRecord(id: 't12', categoryId: 'c4', description: 'Nonton Bioskop', amount: 45000, date: DateTime.now().subtract(const Duration(days: 4)), type: 'Pengeluaran'),
  TransactionRecord(id: 't13', categoryId: 'c1', description: 'Pop Mie & Snack', amount: 15000, date: DateTime.now().subtract(const Duration(days: 4)), type: 'Pengeluaran'),

  // --- 5 Hari Lalu ---
  TransactionRecord(id: 't14', categoryId: 'c5', description: 'Uang Kepanitiaan', amount: 250000, date: DateTime.now().subtract(const Duration(days: 5)), type: 'Pemasukan'),
  TransactionRecord(id: 't15', categoryId: 'c2', description: 'Ojek Online Pulang Malam', amount: 15000, date: DateTime.now().subtract(const Duration(days: 5)), type: 'Pengeluaran'),
  TransactionRecord(id: 't16', categoryId: 'c1', description: 'Pecel Lele Pak Kumis', amount: 17000, date: DateTime.now().subtract(const Duration(days: 5)), type: 'Pengeluaran'),

  // --- 6 Hari Lalu ---
  TransactionRecord(id: 't17', categoryId: 'c1', description: 'Sarapan Nasi Gurih', amount: 10000, date: DateTime.now().subtract(const Duration(days: 6)), type: 'Pengeluaran'),
  TransactionRecord(id: 't18', categoryId: 'c3', description: 'Laundry Pakaian', amount: 35000, date: DateTime.now().subtract(const Duration(days: 6)), type: 'Pengeluaran'),
  TransactionRecord(id: 't19', categoryId: 'c4', description: 'Topup Game', amount: 50000, date: DateTime.now().subtract(const Duration(days: 6)), type: 'Pengeluaran'),
  TransactionRecord(id: 't20', categoryId: 'c1', description: 'Ayam Geprek', amount: 15000, date: DateTime.now().subtract(const Duration(days: 6)), type: 'Pengeluaran'),
];