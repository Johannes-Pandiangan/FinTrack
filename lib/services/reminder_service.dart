/// Kontrak pengingat pencatatan.
///
/// UI dan `AppState` hanya bergantung pada kelas ini, sehingga plugin
/// notifikasi bisa diganti tanpa mengubah logika aplikasi.
abstract class ReminderService {
  /// Meminta izin notifikasi. true jika diizinkan.
  Future<bool> requestPermission();

  /// Menyelaraskan jadwal pengingat dengan kondisi terbaru.
  ///
  /// [enabled] false berarti semua jadwal dibatalkan.
  /// [hasTransactionToday] true berarti pengingat hari ini tidak perlu.
  Future<void> sync({
    required bool enabled,
    required bool hasTransactionToday,
  });
}

/// Tidak melakukan apa-apa. Dipakai di web/desktop dan di test.
class NoopReminderService implements ReminderService {
  const NoopReminderService();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> sync({
    required bool enabled,
    required bool hasTransactionToday,
  }) async {}
}
