import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/transaction_model.dart';
import '../../models/wallet_model.dart';
import 'finance_repository.dart';

/// Implementasi penyimpanan data keuangan di Cloud Firestore (`users/{userId}`),
/// dilengkapi fallback cache lokal (`LocalFinanceRepository`) agar tetap aman
/// ketika perangkat sedang offline.
class FirestoreFinanceRepository implements FinanceRepository {
  FirestoreFinanceRepository({
    FirebaseFirestore? firestore,
    FinanceRepository? localFallback,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _localFallback = localFallback;

  final FirebaseFirestore _firestore;
  final FinanceRepository? _localFallback;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  Future<FinanceLoadResult> load(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      if (!doc.exists) {
        // Jika belum ada di Firestore, cek apakah ada data lokal yang bisa dimigrasi
        if (_localFallback != null) {
          final local = await _localFallback.load(userId);
          if (local.snapshot != null) {
            await save(userId, local.snapshot!);
            return local;
          }
        }
        return const FinanceLoadResult();
      }

      final data = doc.data();
      if (data == null ||
          (!data.containsKey('transactions') && !data.containsKey('wallets'))) {
        // Dokumen user baru dibuat saat registrasi (hanya berisi name & email),
        // sehingga belum memiliki snapshot keuangan.
        return const FinanceLoadResult();
      }

      final rawTransactions = data['transactions'] as List<dynamic>? ?? const [];
      final rawWallets = data['wallets'] as List<dynamic>? ?? const [];

      final snapshot = FinanceSnapshot(
        transactions: rawTransactions
            .map(
              (e) => TransactionModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
        wallets: rawWallets
            .map(
              (e) => WalletModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );

      // Simpan salinannya ke cache perangkat lokal
      if (_localFallback != null) {
        try {
          await _localFallback.save(userId, snapshot);
        } catch (_) {}
      }

      return FinanceLoadResult(snapshot: snapshot);
    } on FormatException {
      return const FinanceLoadResult(corrupted: true);
    } on TypeError {
      return const FinanceLoadResult(corrupted: true);
    } catch (_) {
      // Jika jaringan bermasalah dan Firestore tidak terjangkau, gunakan cache lokal
      if (_localFallback != null) {
        return _localFallback.load(userId);
      }
      rethrow;
    }
  }

  @override
  Future<void> save(String userId, FinanceSnapshot snapshot) async {
    // Simpan ke cache perangkat terlebih dahulu agar responsif
    if (_localFallback != null) {
      try {
        await _localFallback.save(userId, snapshot);
      } catch (_) {}
    }

    await _userDoc(userId).set(
      {
        'transactions': snapshot.transactions.map((t) => t.toJson()).toList(),
        'wallets': snapshot.wallets.map((w) => w.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
