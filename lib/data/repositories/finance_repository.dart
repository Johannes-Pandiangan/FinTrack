import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/dummy_data.dart';
import '../../models/transaction_model.dart';
import '../../models/wallet_model.dart';

/// Satu potret lengkap data keuangan (transaksi + dompet).
class FinanceSnapshot {
  final List<TransactionModel> transactions;
  final List<WalletModel> wallets;

  const FinanceSnapshot({required this.transactions, required this.wallets});
}

/// Hasil membaca data tersimpan.
class FinanceLoadResult {
  /// null jika belum ada data tersimpan (pengguna baru) atau data rusak.
  final FinanceSnapshot? snapshot;

  /// true jika data ada tetapi tidak bisa dibaca.
  final bool corrupted;

  const FinanceLoadResult({this.snapshot, this.corrupted = false});
}

/// Kontrak penyimpanan data keuangan, dipisah per pengguna.
///
/// Sekarang diimplementasikan secara lokal ([LocalFinanceRepository]).
/// Saat backend/database siap, buat implementasi baru (mis.
/// `RemoteFinanceRepository` yang memanggil API) dan berikan ke `AppState`
/// di `main.dart`. Logika aplikasi tidak perlu diubah.
abstract class FinanceRepository {
  /// Membaca data milik [userId].
  Future<FinanceLoadResult> load(String userId);

  /// Menyimpan transaksi dan dompet SEKALIGUS agar keduanya tidak pernah
  /// tidak sinkron.
  Future<void> save(String userId, FinanceSnapshot snapshot);
}

/// Penyimpanan di perangkat memakai SharedPreferences.
class LocalFinanceRepository implements FinanceRepository {
  LocalFinanceRepository(this._prefs);

  final SharedPreferences? _prefs;

  static const String _kUserPrefix = 'ft_finance_u_';
  static const String _kCorruptPrefix = 'ft_finance_corrupt_backup_';

  // Format lama (satu data bersama untuk semua akun). Hanya dibaca untuk
  // migrasi, dan hanya untuk akun demo karena hanya akun itulah yang dulu
  // datanya tersimpan.
  static const String _kGlobalV2 = 'ft_finance_v2';
  static const String _kLegacyTransactions = 'ft_transactions';
  static const String _kLegacyWallets = 'ft_wallets';

  @override
  Future<FinanceLoadResult> load(String userId) async {
    final p = _prefs;
    if (p == null) return const FinanceLoadResult();

    final raw = p.getString('$_kUserPrefix$userId');
    final isMigrationOwner = userId == DummyData.user.id;
    final globalV2 = isMigrationOwner ? p.getString(_kGlobalV2) : null;
    final legacyTx =
        isMigrationOwner ? p.getString(_kLegacyTransactions) : null;
    final legacyWallets =
        isMigrationOwner ? p.getString(_kLegacyWallets) : null;

    try {
      if (raw != null) return FinanceLoadResult(snapshot: _decodeJson(raw));
      if (globalV2 != null) {
        return FinanceLoadResult(snapshot: _decodeJson(globalV2));
      }
      if (legacyTx != null && legacyWallets != null) {
        return FinanceLoadResult(
          snapshot: _decode(jsonDecode(legacyTx), jsonDecode(legacyWallets)),
        );
      }
      return const FinanceLoadResult();
    } catch (_) {
      // Jangan buang data pengguna diam-diam: simpan salinannya.
      try {
        await p.setString(
          '$_kCorruptPrefix$userId',
          raw ??
              globalV2 ??
              jsonEncode({'transactions': legacyTx, 'wallets': legacyWallets}),
        );
      } catch (_) {}
      return const FinanceLoadResult(corrupted: true);
    }
  }

  @override
  Future<void> save(String userId, FinanceSnapshot snapshot) async {
    final p = _prefs;
    if (p == null) return;
    final ok = await p.setString(
      '$_kUserPrefix$userId',
      jsonEncode({
        'transactions': snapshot.transactions.map((t) => t.toJson()).toList(),
        'wallets': snapshot.wallets.map((w) => w.toJson()).toList(),
      }),
    );
    if (!ok) throw StateError('Gagal menulis data ke penyimpanan perangkat.');
  }

  static FinanceSnapshot _decodeJson(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return _decode(map['transactions'], map['wallets']);
  }

  static FinanceSnapshot _decode(Object? transactions, Object? wallets) {
    return FinanceSnapshot(
      transactions: (transactions as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      wallets: (wallets as List)
          .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
