import 'package:fintrack/data/dummy_data.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryAuthService auth;

  setUp(() => auth = InMemoryAuthService(latency: Duration.zero));

  test('login: email tidak peka huruf besar/kecil', () async {
    final account = await auth.login(
      ' ${DummyData.demoEmail.toUpperCase()} ',
      DummyData.demoPassword,
    );
    expect(account?.email, DummyData.demoEmail);
  });

  test('register menolak email yang sudah dipakai', () async {
    expect(await auth.register('Budi', 'budi@email.com', 'rahasia123'), isTrue);
    expect(await auth.register('Budi 2', 'BUDI@email.com', 'lain'), isFalse);
    expect(await auth.login('budi@email.com', 'rahasia123'), isNotNull);
  });

  test('reset password hanya untuk akun yang terdaftar', () async {
    expect(await auth.resetPassword('tidak@ada.com', 'x'), isFalse);
    expect(await auth.resetPassword(DummyData.demoEmail, 'baru'), isTrue);
    expect(await auth.login(DummyData.demoEmail, 'baru'), isNotNull);
  });
}
