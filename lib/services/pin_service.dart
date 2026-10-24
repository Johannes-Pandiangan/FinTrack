import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kunci PIN perangkat. PIN tidak pernah disimpan polos, hanya hash
/// SHA-256 dengan salt.
class PinService {
  PinService(this._prefs);

  final SharedPreferences? _prefs;

  static const String _kHash = 'ft_pin_hash';
  static const String _kSalt = 'ft_pin_salt';

  String? _hash;
  String? _salt;

  /// Membaca PIN tersimpan. Panggil sekali saat aplikasi dimulai.
  void load() {
    final p = _prefs;
    if (p == null) return;
    _hash = p.getString(_kHash);
    _salt = p.getString(_kSalt);
  }

  bool get hasPin => _hash != null;

  String _digest(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  void set(String pin) {
    final random = Random.secure();
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    _salt = salt;
    _hash = _digest(pin, salt);
    _prefs?.setString(_kSalt, salt);
    _prefs?.setString(_kHash, _hash!);
  }

  bool verify(String pin) {
    final hash = _hash;
    if (hash == null) return false;
    return _digest(pin, _salt ?? '') == hash;
  }

  void remove() {
    _hash = null;
    _salt = null;
    _prefs?.remove(_kHash);
    _prefs?.remove(_kSalt);
  }
}
