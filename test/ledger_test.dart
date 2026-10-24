import 'package:fintrack/data/ledger.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'package:fintrack/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late Ledger ledger;

  setUp(() {
    ledger = Ledger(
      wallets: const [
        WalletModel(
          id: 'w_cash',
          name: 'Tunai',
          type: WalletType.cash,
          balance: 1000000,
        ),
        WalletModel(
          id: 'w_bank',
          name: 'Bank',
          type: WalletType.bank,
          balance: 5000000,
        ),
      ],
    );
  });

  test('total saldo = jumlah saldo semua dompet', () {
    expect(ledger.totalBalance, 6000000);
  });

  test('memindahkan transaksi ke dompet lain menyesuaikan kedua saldo', () {
    ledger.addTransaction(tx(id: 'a', amount: 200000, walletId: 'w_cash'));
    expect(ledger.walletById('w_cash')!.balance, 800000);

    ledger.updateTransaction(tx(id: 'a', amount: 200000, walletId: 'w_bank'));
    expect(ledger.walletById('w_cash')!.balance, 1000000);
    expect(ledger.walletById('w_bank')!.balance, 4800000);
  });

  test('update/hapus transaksi yang tidak ada tidak mengubah apa pun', () {
    expect(ledger.updateTransaction(tx(id: 'tidak-ada')), isFalse);
    expect(ledger.deleteTransaction('tidak-ada'), isNull);
    expect(ledger.totalBalance, 6000000);
  });

  test('deleteTransaction mengembalikan judul dan memulihkan saldo', () {
    ledger.addTransaction(tx(id: 'b', amount: 100000));
    expect(ledger.deleteTransaction('b'), 'Contoh b');
    expect(ledger.totalBalance, 6000000);
  });

  test('daftar transaksi diurutkan dari yang terbaru', () {
    ledger.addTransaction(tx(id: 'lama', date: DateTime(2026, 1, 1)));
    ledger.addTransaction(tx(id: 'baru', date: DateTime(2026, 6, 1)));
    expect(ledger.transactions.map((t) => t.id).toList(), ['baru', 'lama']);
  });

  test('expenseOn hanya menghitung pengeluaran pada hari itu', () {
    final day = DateTime(2026, 10, 10);
    ledger.addTransaction(tx(id: 'x', amount: 30000, date: day));
    ledger.addTransaction(tx(id: 'y', amount: 20000, date: day));
    ledger.addTransaction(
      tx(id: 'z', amount: 99000, type: TransactionType.income, date: day),
    );
    ledger.addTransaction(
        tx(id: 'w', amount: 5000, date: DateTime(2026, 10, 11)));

    expect(ledger.expenseOn(day), 50000);
    expect(ledger.hasTransactionOn(day), isTrue);
    expect(ledger.hasTransactionOn(DateTime(2026, 10, 12)), isFalse);
  });

  test('dompet yang dipakai transaksi tidak bisa dihapus', () {
    ledger.addTransaction(tx(id: 'p', walletId: 'w_cash'));
    expect(ledger.deleteWallet('w_cash'), isFalse);
    expect(ledger.deleteWallet('w_bank'), isTrue);
  });
}
