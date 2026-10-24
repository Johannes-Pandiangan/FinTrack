class AppConstants {
  AppConstants._();

  static const String appName = 'FinTrack';
  static const String tagline = 'Financial Intelligence & Tracking';

  // Ganti kedua file ini untuk mengganti logo.
  // logo.png = logo lengkap dengan tulisan, logo_icon.png = ikon saja.
  static const String logoAsset = 'assets/images/logo.png';
  static const String logoIconAsset = 'assets/images/logo_icon.png';

  static const double pagePadding = 24;
  static const double radiusM = 14;
  static const double radiusL = 20;

  /// Ruang kosong di bawah isi halaman utama agar tombol "+" (yang menonjol
  /// ke atas dari bilah navigasi) tidak menutupi konten paling bawah.
  static const double fabClearance = 44;
}
