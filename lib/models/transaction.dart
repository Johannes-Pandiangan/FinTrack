// lib/models/transaction.dart

class TransactionCategory {
  final String id;
  final String name;
  final String type; // 'Pemasukan' atau 'Pengeluaran'

  TransactionCategory({
    required this.id,
    required this.name,
    required this.type,
  });
}

class TransactionRecord {
  final String id;
  final String categoryId; // Ini adalah bentuk Relasi ID ke TransactionCategory
  final String description;
  final double amount;
  final DateTime date;
  final String type; // 'Pemasukan' atau 'Pengeluaran'

  TransactionRecord({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });
}