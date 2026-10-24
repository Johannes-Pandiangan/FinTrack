enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final int amount;
  final TransactionType type;
  final String category;
  final String walletId;
  final DateTime date;
  final String note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.walletId,
    required this.date,
    this.note = '',
  });

  bool get isIncome => type == TransactionType.income;

  /// Nominal bertanda: positif untuk pemasukan, negatif untuk pengeluaran.
  int get signedAmount => isIncome ? amount : -amount;

  TransactionModel copyWith({
    String? title,
    int? amount,
    TransactionType? type,
    String? category,
    String? walletId,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category,
        'walletId': walletId,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toInt(),
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      category: json['category'] as String,
      walletId: json['walletId'] as String,
      date: DateTime.parse(json['date'] as String),
      note: (json['note'] as String?) ?? '',
    );
  }
}
