import 'package:fintrack/core/utils/app_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppClock.override(null));

  test('today() memotong jam menjadi 00:00', () {
    AppClock.override(() => DateTime(2030, 5, 17, 14, 30));
    expect(AppClock.today(), DateTime(2030, 5, 17));
    expect(AppClock.now(), DateTime(2030, 5, 17, 14, 30));
  });

  test('tanpa override memakai waktu sungguhan', () {
    final before = DateTime.now();
    final now = AppClock.now();
    expect(now.difference(before).inSeconds.abs() < 5, isTrue);
  });
}
