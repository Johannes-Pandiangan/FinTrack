import 'package:fintrack/data/dummy_data.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'package:fintrack/providers/app_state.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  late AppState state;

  setUp(() async {
    state = AppState(auth: InMemoryAuthService(latency: Duration.zero));
    await state.init();
    // Akun demo membawa dompet dan transaksi contoh.
    await state.login(DummyData.demoEmail, DummyData.demoPassword);
  });

  int cash() => state.walletById('w_cash')!.balance;

  test('pengeluaran mengurangi saldo dompet, hapus mengembalikannya', () {
    final before = cash();
    state.addTransaction(tx(id: 'x1', amount: 100000));
    expect(cash(), before - 100000);

    state.deleteTransaction('x1');
    expect(cash(), before);
  });

  test('pemasukan menambah saldo dan edit menyesuaikan selisih', () {
    final before = cash();
    state.addTransaction(
      tx(id: 'x2', amount: 200000, type: TransactionType.income),
    );
    expect(cash(), before + 200000);

    state.updateTransaction(
      tx(id: 'x2', amount: 50000, type: TransactionType.income),
    );
    expect(cash(), before + 50000);
  });

  test('dompet yang dipakai transaksi tidak bisa dihapus', () {
    state.addTransaction(tx(id: 'x3'));
    expect(state.deleteWallet('w_cash'), isFalse);
  });

  test('login demo berhasil, sandi salah gagal', () async {
    state.logout();
    expect(await state.login(DummyData.demoEmail, 'salah'), isFalse);
    expect(state.isLoggedIn, isFalse);

    expect(
      await state.login(DummyData.demoEmail, DummyData.demoPassword),
      isTrue,
    );
    expect(state.isLoggedIn, isTrue);

    state.logout();
    expect(state.isLoggedIn, isFalse);
  });

  test('ubah kata sandi memakai sandi lama yang benar', () async {
    await state.login(DummyData.demoEmail, DummyData.demoPassword);

    expect(await state.changePassword('salah', 'baru12345'), isNotNull);
    expect(await state.changePassword(DummyData.demoPassword, 'baru12345'),
        isNull);

    state.logout();
    expect(await state.login(DummyData.demoEmail, 'baru12345'), isTrue);
  });

  test('PIN disimpan sebagai hash dan bisa diverifikasi', () {
    state.setPin('1234');
    expect(state.hasPin, isTrue);
    expect(state.verifyPin('1234'), isTrue);
    expect(state.verifyPin('0000'), isFalse);
  });

  test('akun baru mulai bersih dengan satu dompet tunai', () async {
    state.logout();
    await state.register('Budi', 'budi@email.com', 'rahasia123');
    await state.login('budi@email.com', 'rahasia123');

    expect(state.transactions, isEmpty);
    expect(state.wallets.single.balance, 0);
    expect(state.totalBalance, 0);
  });

  test('logout mengosongkan data sehingga akun lain tidak melihatnya',
      () async {
    state.addTransaction(tx(id: 'rahasia-demo'));
    state.logout();
    expect(state.transactions, isEmpty);
    expect(state.wallets, isEmpty);

    await state.register('Sari', 'sari@email.com', 'rahasia123');
    await state.login('sari@email.com', 'rahasia123');
    expect(state.transactions.where((t) => t.id == 'rahasia-demo'), isEmpty);
  });

  test('data tersimpan per akun dan dimuat lagi saat login', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = InMemoryAuthService(latency: Duration.zero);

    final first = AppState(prefs: prefs, auth: auth);
    await first.init();
    await first.login(DummyData.demoEmail, DummyData.demoPassword);
    first.addTransaction(tx(id: 'tersimpan', amount: 12345));
    await Future<void>.delayed(Duration.zero);

    final second = AppState(prefs: prefs, auth: auth);
    await second.init();
    await second.login(DummyData.demoEmail, DummyData.demoPassword);

    expect(second.transactions.any((t) => t.id == 'tersimpan'), isTrue);
  });
}
