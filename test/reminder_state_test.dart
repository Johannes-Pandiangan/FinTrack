import 'package:fintrack/providers/app_state.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/services/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

class _FakeReminder implements ReminderService {
  _FakeReminder({this.allow = true});

  bool allow;
  int permissionRequests = 0;
  final List<({bool enabled, bool hasTx})> syncs = [];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return allow;
  }

  @override
  Future<void> sync({
    required bool enabled,
    required bool hasTransactionToday,
  }) async {
    syncs.add((enabled: enabled, hasTx: hasTransactionToday));
  }
}

Future<AppState> _state(_FakeReminder fake) async {
  SharedPreferences.setMockInitialValues({});
  final state = AppState(
    prefs: await SharedPreferences.getInstance(),
    auth: InMemoryAuthService(latency: Duration.zero),
    reminder: fake,
  );
  await state.init();
  return state;
}

void main() {
  test('setupReminder meminta izin sekali, lalu hanya menyelaraskan jadwal',
      () async {
    final fake = _FakeReminder();
    final state = await _state(fake);

    await state.setupReminder();
    await state.setupReminder();

    expect(fake.permissionRequests, 1);
    expect(fake.syncs, isNotEmpty);
    expect(state.reminderEnabled, isTrue);
  });

  test('izin ditolak saat pertama kali: pengingat dimatikan', () async {
    final fake = _FakeReminder(allow: false);
    final state = await _state(fake);

    await state.setupReminder();

    expect(state.reminderEnabled, isFalse);
    expect(fake.syncs.last.enabled, isFalse);
  });

  test('setReminder(true) gagal jika izin ditolak', () async {
    final fake = _FakeReminder(allow: false);
    final state = await _state(fake);
    await state.setReminder(false);

    expect(await state.setReminder(true), isFalse);
    expect(state.reminderEnabled, isFalse);
  });

  test('mencatat transaksi hari ini memperbarui jadwal', () async {
    final fake = _FakeReminder();
    final state = await _state(fake);
    fake.syncs.clear();

    state.addTransaction(tx(id: 'hari-ini', date: DateTime.now()));
    await Future<void>.delayed(Duration.zero);

    expect(fake.syncs.last.hasTx, isTrue);
  });
}
