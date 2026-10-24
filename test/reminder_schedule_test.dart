import 'package:fintrack/services/reminder_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sebelum jam 20 dan belum ada transaksi: hari ini + 6 hari ke depan',
      () {
    expect(
      reminderDayOffsets(nowHour: 9, hasTransactionToday: false),
      [0, 1, 2, 3, 4, 5, 6],
    );
  });

  test('sudah ada transaksi hari ini: hari ini dilewati', () {
    expect(
      reminderDayOffsets(nowHour: 9, hasTransactionToday: true),
      [1, 2, 3, 4, 5, 6],
    );
  });

  test('jam 20 sudah lewat: hari ini dilewati', () {
    expect(
      reminderDayOffsets(nowHour: 20, hasTransactionToday: false),
      [1, 2, 3, 4, 5, 6],
    );
    expect(
      reminderDayOffsets(nowHour: 23, hasTransactionToday: false),
      [1, 2, 3, 4, 5, 6],
    );
  });

  test('jam 19: hari ini masih dijadwalkan', () {
    expect(
        reminderDayOffsets(nowHour: 19, hasTransactionToday: false).first, 0);
  });
}
