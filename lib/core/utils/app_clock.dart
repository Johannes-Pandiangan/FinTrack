import 'package:flutter/foundation.dart';

/// Sumber waktu tunggal aplikasi.
///
/// Semua layar membaca "hari ini" dari sini (bukan langsung `DateTime.now()`)
/// agar perilaku berbasis tanggal mudah diuji dengan [override].
class AppClock {
  AppClock._();

  static DateTime Function() _now = DateTime.now;

  /// Waktu saat ini.
  static DateTime now() => _now();

  /// Hari ini pada pukul 00:00.
  static DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Mengganti sumber waktu (untuk test). Kirim `null` untuk mengembalikan.
  @visibleForTesting
  static void override(DateTime Function()? clock) {
    _now = clock ?? DateTime.now;
  }
}
