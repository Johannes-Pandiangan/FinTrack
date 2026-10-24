/// Nama kategori bawaan. Satu-satunya tempat string kategori didefinisikan,
/// agar tidak tersebar sebagai teks mentah di banyak file.
class AppCategories {
  AppCategories._();

  // Pemasukan
  static const String salary = 'Gaji';
  static const String bonus = 'Bonus';
  static const String investment = 'Investasi';
  static const String business = 'Usaha';

  // Pengeluaran
  static const String food = 'Makanan & Minuman';
  static const String shopping = 'Belanja';
  static const String transport = 'Transportasi';
  static const String bills = 'Tagihan';
  static const String entertainment = 'Hiburan';

  /// Pengeluaran tidak wajib (bisa dipangkas). Dipakai FinAI dan simulasi
  /// anggaran.
  static const List<String> discretionary = [food, shopping, entertainment];
}
