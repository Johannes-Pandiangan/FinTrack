import '../models/wallet_model.dart';
import 'dummy_data.dart';
import 'repositories/finance_repository.dart';

/// Data awal sebuah akun saat belum ada data tersimpan.
class SeedData {
  SeedData._();

  /// Akun demo mendapat data contoh; akun lain mulai bersih dengan satu
  /// dompet tunai agar bisa langsung mencatat transaksi.
  static FinanceSnapshot forAccount({required bool isDemo}) {
    if (isDemo) {
      return FinanceSnapshot(
        transactions: List.of(DummyData.transactions),
        wallets: List.of(DummyData.wallets),
      );
    }
    return const FinanceSnapshot(
      transactions: [],
      wallets: [
        WalletModel(
          id: 'w_cash',
          name: 'Tunai / Cash',
          type: WalletType.cash,
          balance: 0,
        ),
      ],
    );
  }
}
