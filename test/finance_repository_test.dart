import 'dart:convert';

import 'package:fintrack/data/dummy_data.dart';
import 'package:fintrack/data/repositories/finance_repository.dart';
import 'package:fintrack/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

const _wallet = WalletModel(
  id: 'w1',
  name: 'Dompet',
  type: WalletType.cash,
  balance: 1000,
);

final String _demoId = DummyData.user.id;

Future<LocalFinanceRepository> _repo(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  return LocalFinanceRepository(await SharedPreferences.getInstance());
}

void main() {
  test('simpan lalu muat mengembalikan data yang sama', () async {
    final repo = await _repo({});

    await repo.save(
      'u_budi',
      FinanceSnapshot(transactions: [tx(id: 'a')], wallets: const [_wallet]),
    );
    final result = await repo.load('u_budi');

    expect(result.corrupted, isFalse);
    expect(result.snapshot!.transactions.single.id, 'a');
    expect(result.snapshot!.wallets.single.balance, 1000);
  });

  test('data tiap akun terpisah', () async {
    final repo = await _repo({});

    await repo.save(
      'u_budi',
      FinanceSnapshot(transactions: [tx(id: 'milik-budi')], wallets: const []),
    );

    expect((await repo.load('u_budi')).snapshot, isNotNull);
    expect((await repo.load('u_sari')).snapshot, isNull);
  });

  test('pengguna baru: tidak ada data, tidak dianggap rusak', () async {
    final repo = await _repo({});
    final result = await repo.load('u_baru');
    expect(result.snapshot, isNull);
    expect(result.corrupted, isFalse);
  });

  test('data rusak ditandai dan salinannya dicadangkan', () async {
    final repo = await _repo({'ft_finance_u_u_budi': '{bukan json'});
    final result = await repo.load('u_budi');
    final prefs = await SharedPreferences.getInstance();

    expect(result.corrupted, isTrue);
    expect(prefs.getString('ft_finance_corrupt_backup_u_budi'), '{bukan json');
  });

  test('migrasi format lama dua key hanya untuk akun demo', () async {
    final repo = await _repo({
      'ft_transactions': jsonEncode([tx(id: 'lama').toJson()]),
      'ft_wallets': jsonEncode([_wallet.toJson()]),
    });

    final demo = await repo.load(_demoId);
    expect(demo.snapshot!.transactions.single.id, 'lama');

    final other = await repo.load('u_budi');
    expect(other.snapshot, isNull);
  });

  test('migrasi dari data bersama versi v2 hanya untuk akun demo', () async {
    final repo = await _repo({
      'ft_finance_v2': jsonEncode({
        'transactions': [tx(id: 'v2').toJson()],
        'wallets': [_wallet.toJson()],
      }),
    });

    expect((await repo.load(_demoId)).snapshot!.transactions.single.id, 'v2');
    expect((await repo.load('u_budi')).snapshot, isNull);
  });
}
