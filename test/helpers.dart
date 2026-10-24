import 'package:fintrack/core/constants/app_categories.dart';
import 'package:fintrack/models/transaction_model.dart';

TransactionModel tx({
  String id = 't',
  int amount = 100000,
  TransactionType type = TransactionType.expense,
  String category = AppCategories.food,
  String walletId = 'w_cash',
  DateTime? date,
}) {
  return TransactionModel(
    id: id,
    title: 'Contoh $id',
    amount: amount,
    type: type,
    category: category,
    walletId: walletId,
    date: date ?? DateTime(2026, 10, 10, 12),
  );
}
