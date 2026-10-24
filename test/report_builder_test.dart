import 'package:fintrack/core/utils/report_builder.dart';
import 'package:fintrack/models/report_model.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('laporan bulanan hanya menghitung transaksi dalam bulan itu', () {
    final txs = [
      tx(
        id: 'in',
        type: TransactionType.income,
        amount: 1000000,
        date: DateTime(2026, 10, 3),
      ),
      tx(id: 'out', amount: 400000, date: DateTime(2026, 10, 20)),
      tx(id: 'bulan-lalu', amount: 300000, date: DateTime(2026, 9, 30)),
    ];

    final r = ReportBuilder.build(
      txs,
      ReportPeriod.monthly,
      DateTime(2026, 10, 24),
    );

    expect(r.income, 1000000);
    expect(r.expense, 400000);
    expect(r.net, 600000);
  });

  test('rentang mingguan dimulai hari Senin dengan akhir eksklusif', () {
    // 24 Okt 2026 adalah hari Sabtu.
    final r = ReportBuilder.range(ReportPeriod.weekly, DateTime(2026, 10, 24));
    expect(r.start, DateTime(2026, 10, 19));
    expect(r.end, DateTime(2026, 10, 26));
  });
}
