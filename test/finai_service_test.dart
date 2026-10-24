import 'package:fintrack/services/finai_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('RuleBasedFinAIService menjawab dari data transaksi', () async {
    const service = RuleBasedFinAIService(latency: Duration.zero);
    final answer = await service.reply(
      'berapa saldo saya?',
      FinAIContext(
        transactions: [tx(id: 'a'), tx(id: 'b', amount: 50000)],
        anchor: DateTime(2026, 10, 15),
        totalBalance: 5000000,
      ),
    );
    expect(answer, contains('Total saldo'));
  });

  test('menjawab sopan saat belum ada transaksi', () async {
    const service = RuleBasedFinAIService(latency: Duration.zero);
    final answer = await service.reply(
      'ringkas',
      FinAIContext(
        transactions: const [],
        anchor: DateTime(2026, 10, 15),
        totalBalance: 0,
      ),
    );
    expect(answer, contains('Belum ada transaksi'));
  });
}
