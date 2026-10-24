import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import 'repositories/finance_repository.dart';

/// Buku besar: dompet + transaksi beserta aturan saldonya.
///
/// Kelas Dart murni (tanpa Flutter/penyimpanan) sehingga mudah diuji.
/// Penyimpanan dan notifikasi ke UI ditangani `AppState`.
class Ledger {
  Ledger({
    List<TransactionModel> transactions = const [],
    List<WalletModel> wallets = const [],
  })  : _transactions = List.of(transactions),
        _wallets = List.of(wallets);

  final List<TransactionModel> _transactions;
  final List<WalletModel> _wallets;

  /// Mengganti seluruh isi (mis. setelah memuat dari penyimpanan).
  void replaceAll(FinanceSnapshot snapshot) {
    _transactions
      ..clear()
      ..addAll(snapshot.transactions);
    _wallets
      ..clear()
      ..addAll(snapshot.wallets);
  }

  FinanceSnapshot snapshot() => FinanceSnapshot(
        transactions: List.of(_transactions),
        wallets: List.of(_wallets),
      );

  // ---------------------------------------------------------------- Dompet

  List<WalletModel> get wallets => List.unmodifiable(_wallets);

  WalletModel? walletById(String id) {
    for (final w in _wallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  int get totalBalance => _wallets.fold(0, (sum, w) => sum + w.balance);

  void addWallet({
    required String name,
    required WalletType type,
    required int initialBalance,
  }) {
    _wallets.add(
      WalletModel(
        id: 'w_${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        type: type,
        balance: initialBalance,
      ),
    );
  }

  /// false jika dompet tidak ditemukan.
  bool updateWallet(
    String id, {
    required String name,
    required WalletType type,
  }) {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index == -1) return false;
    _wallets[index] = _wallets[index].copyWith(name: name.trim(), type: type);
    return true;
  }

  /// Gagal (false) jika dompet masih dipakai oleh transaksi.
  bool deleteWallet(String id) {
    if (_transactions.any((t) => t.walletId == id)) return false;
    _wallets.removeWhere((w) => w.id == id);
    return true;
  }

  // ------------------------------------------------------------- Transaksi

  /// Diurutkan dari yang terbaru.
  List<TransactionModel> get transactions {
    final sorted = List<TransactionModel>.of(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  TransactionModel? transactionById(String id) {
    for (final t in _transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool hasTransactionOn(DateTime day) =>
      _transactions.any((t) => _sameDay(t.date, day));

  int expenseOn(DateTime day) => _transactions
      .where((t) => !t.isIncome && _sameDay(t.date, day))
      .fold(0, (sum, t) => sum + t.amount);

  void _applyEffect(TransactionModel t, {required bool reverse}) {
    final index = _wallets.indexWhere((w) => w.id == t.walletId);
    if (index == -1) return;
    final delta = reverse ? -t.signedAmount : t.signedAmount;
    _wallets[index] =
        _wallets[index].copyWith(balance: _wallets[index].balance + delta);
  }

  void addTransaction(TransactionModel t) {
    _transactions.add(t);
    _applyEffect(t, reverse: false);
  }

  /// false jika transaksi tidak ditemukan.
  bool updateTransaction(TransactionModel updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index == -1) return false;
    _applyEffect(_transactions[index], reverse: true);
    _transactions[index] = updated;
    _applyEffect(updated, reverse: false);
    return true;
  }

  /// Mengembalikan judul transaksi yang dihapus, atau null jika tidak ada.
  String? deleteTransaction(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final title = _transactions[index].title;
    _applyEffect(_transactions[index], reverse: true);
    _transactions.removeAt(index);
    return title;
  }
}
