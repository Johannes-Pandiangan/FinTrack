import 'package:flutter/material.dart';

/// Palet warna aplikasi.
///
/// Warna netral dan "soft" berganti sesuai tema lewat [dark]. Nilai [dark]
/// diatur oleh `AppState` sebelum aplikasi dibangun ulang, sehingga setiap
/// getter di bawah selalu mengembalikan warna tema yang sedang aktif.
/// Warna merek (gradien hijau, warna di atas gradien) sama di kedua tema.
class AppColors {
  AppColors._();

  /// true jika tema gelap aktif.
  static bool dark = false;

  static Color _pick(Color light, Color darkColor) => dark ? darkColor : light;

  // Hijau merek. Pada tema gelap sedikit lebih terang agar terbaca di latar gelap.
  static Color get primary =>
      _pick(const Color(0xFF0B5D3B), const Color(0xFF2F9E6E));
  static const Color primaryDark = Color(0xFF07402A);
  static const Color primaryLight = Color(0xFF1E7A52);
  static Color get lightGreen =>
      _pick(const Color(0xFFDDF3E6), const Color(0xFF1C3A2C));

  static Color get income =>
      _pick(const Color(0xFF1E8E5A), const Color(0xFF45C48A));
  static Color get incomeSoft =>
      _pick(const Color(0xFFE3F5EA), const Color(0xFF173528));
  static Color get expense =>
      _pick(const Color(0xFFD64545), const Color(0xFFEF6A6A));
  static Color get expenseSoft =>
      _pick(const Color(0xFFFDE8E8), const Color(0xFF3A1F21));

  static const Color purple = Color(0xFF7B61C9);
  static Color get lavender =>
      _pick(const Color(0xFFEDE9FB), const Color(0xFF28234A));
  static const Color orange = Color(0xFFE8862A);
  static Color get orangeSoft =>
      _pick(const Color(0xFFFFEBD9), const Color(0xFF3A2A18));
  static const Color yellow = Color(0xFFC99700);
  static Color get yellowSoft =>
      _pick(const Color(0xFFFFF4CC), const Color(0xFF38311A));

  static Color get background =>
      _pick(const Color(0xFFF7F8FB), const Color(0xFF0F1512));
  static Color get surface => _pick(Colors.white, const Color(0xFF18211C));
  static Color get textPrimary =>
      _pick(const Color(0xFF1B2A24), const Color(0xFFE8EFEB));
  static Color get textSecondary =>
      _pick(const Color(0xFF5F6D67), const Color(0xFF9DB0A7));
  static Color get border =>
      _pick(const Color(0xFFE4E8EC), const Color(0xFF2A3731));
  static Color get shadow =>
      _pick(const Color(0x14000000), const Color(0x66000000));

  static const List<Color> splashGradient = [
    Color(0xFF0E7048),
    Color(0xFF0B5D3B),
    Color(0xFF06341F),
  ];

  static const Color incomeOnDark = Color(0xFF8CE8B4);
  static const Color expenseOnDark = Color(0xFFFFA3A3);
}
