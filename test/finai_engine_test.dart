import 'package:fintrack/core/utils/finai_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinAIEngine.parseAmount', () {
    test('membaca satuan rb/k/jt', () {
      expect(FinAIEngine.parseAmount('batas harian 150rb'), 150000);
      expect(FinAIEngine.parseAmount('150k'), 150000);
      expect(FinAIEngine.parseAmount('laptop 12 juta'), 12000000);
    });

    test('membaca desimal dan pemisah ribuan', () {
      expect(FinAIEngine.parseAmount('2,5 jt'), 2500000);
      expect(FinAIEngine.parseAmount('12.000.000'), 12000000);
    });

    test('mengembalikan null jika bukan nominal', () {
      expect(FinAIEngine.parseAmount('halo apa kabar'), isNull);
      expect(FinAIEngine.parseAmount('500'), isNull);
    });
  });
}
