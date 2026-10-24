/// Jam pengingat harian (WIB).
const int reminderHour = 20;

/// Berapa hari ke depan yang dijadwalkan sekaligus.
///
/// Dijadwalkan per hari (bukan berulang otomatis) supaya hari yang sudah ada
/// transaksinya bisa dilewati. Jadwal diperbarui setiap aplikasi dibuka atau
/// ada perubahan transaksi.
const int reminderWindowDays = 7;

/// Hari ke berapa (0 = hari ini) yang perlu diberi pengingat.
///
/// Hari ini dilewati jika jam [reminderHour] sudah lewat atau pengguna sudah
/// mencatat transaksi hari ini. Hari-hari berikutnya selalu dijadwalkan.
List<int> reminderDayOffsets({
  required int nowHour,
  required bool hasTransactionToday,
  int days = reminderWindowDays,
  int hour = reminderHour,
}) {
  final offsets = <int>[];
  for (var i = 0; i < days; i++) {
    if (i == 0 && (nowHour >= hour || hasTransactionToday)) continue;
    offsets.add(i);
  }
  return offsets;
}
