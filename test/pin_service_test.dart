import 'package:fintrack/services/pin_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('PIN tidak disimpan polos dan bertahan setelah dimuat ulang', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final pin = PinService(prefs)..set('4321');
    expect(prefs.getString('ft_pin_hash'), isNot(equals('4321')));

    final reloaded = PinService(prefs)..load();
    expect(reloaded.hasPin, isTrue);
    expect(reloaded.verify('4321'), isTrue);
    expect(reloaded.verify('1234'), isFalse);

    pin.remove();
    expect(PinService(prefs).hasPin, isFalse);
  });
}
