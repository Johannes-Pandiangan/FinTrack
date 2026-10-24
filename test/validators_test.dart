import 'package:fintrack/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email valid lolos, nomor HP ditolak sebagai identitas login', () {
    expect(Validators.email('nama@email.com'), isNull);
    expect(Validators.email('081234567890'), isNotNull);
    expect(Validators.email('  '), isNotNull);
  });

  test('kata sandi minimal 6 karakter', () {
    expect(Validators.password('12345'), isNotNull);
    expect(Validators.password('123456'), isNull);
  });

  test('konfirmasi kata sandi harus sama', () {
    expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    expect(Validators.confirmPassword('abc124', 'abc123'), isNotNull);
  });
}
