# FinTrack - Financial Intelligence & Tracking

Aplikasi Flutter pencatat keuangan, **dikembangkan dan diuji di Android** pada tahap ini. Semua data disimpan di perangkat (tanpa backend/Firebase). ID aplikasi: `com.marathon.fintrack`.

## Menjalankan
1. `flutter pub get`
2. `flutter analyze` dan `flutter test` (pastikan bersih)
3. `flutter run`

Folder platform lain (iOS, web, desktop) berasal dari template Flutter dan belum diuji. Sebagian fitur (notifikasi lokal, menu Bagikan) dirancang untuk Android.

Login demo: `fintrack@email.com` / `fintrack123`

## Kebutuhan (WAJIB dicek sebelum menjalankan)
- **Flutter 3.44 atau lebih baru** (Dart 3.12+) - cek dengan `flutter --version`, perbarui dengan `flutter upgrade`.
- **JDK 17 atau lebih baru** dan Android SDK (Android Studio).
- Build Android memakai Gradle 9.3.1, Android Gradle Plugin 9.1.0, Kotlin 2.4.0 (diunduh otomatis; butuh internet saat build pertama).

## Alur kerja tim (Git)
1. `git clone <url-repo>` lalu `cd fintrack`.
2. `flutter pub get` (jangan hapus/ubah `pubspec.lock` kecuali menambah paket, lalu commit bersama).
3. `flutter analyze` dan `flutter test` harus bersih sebelum commit.
4. Satu fitur = satu branch (contoh: `fitur-laporan`), gabungkan lewat Pull Request. Jangan push langsung ke `main`.
5. `git pull` lalu `flutter pub get` sebelum mulai bekerja setiap hari.
6. Jangan commit `android/local.properties`, `.gradle/`, `build/` (sudah ada di `.gitignore`). File itu dibuat otomatis oleh Flutter di tiap komputer.

## Jika error saat build pertama
- `flutter.sdk not set` / `SDK location not found`: hapus `android/local.properties`, jalankan `flutter pub get` (dibuat ulang otomatis).
- Error versi Dart/Flutter: jalankan `flutter upgrade`.
- Error Gradle aneh: `flutter clean` lalu `flutter pub get` dan jalankan ulang.

## Untuk yang hanya ingin mencoba
Gunakan APK: `flutter build apk --release` -> `build/app/outputs/flutter-apk/app-release.apk`.

## Fitur yang berfungsi
- Catat/ubah/hapus transaksi, saldo dompet otomatis, data tersimpan di perangkat.
- Dompet: tambah, ubah, hapus (jika belum dipakai transaksi).
- Laporan mingguan/bulanan/tahunan + simulasi anggaran; Beranda menampilkan laporan & analisis bulan berjalan.
- Ekspor PDF dan CSV per bulan atau semua data (dibagikan lewat menu Bagikan Android).
- Pengingat pencatatan: notifikasi jam 20:00 WIB, dilewati jika hari itu sudah ada transaksi. Di HP Xiaomi/Oppo/Vivo, izinkan "Mulai otomatis" dan atur baterai ke "Tanpa batasan".
- Data keuangan dipisah per akun; akun demo membawa data contoh, akun baru mulai bersih.
- Kunci PIN, ubah kata sandi, lupa kata sandi.
- Kategori transaksi bisa dipilih atau diketik sendiri (Kategori Lain).
- Profil: ubah nama, Tema (terang/gelap), dan Batas Pengeluaran Harian.
- FinAI sementara berbasis aturan (BUKAN AI sungguhan) yang membaca data transaksi, batas pengeluaran harian, pengingat.

## Catatan
- Kata sandi tidak disimpan permanen; akun Register dan perubahan sandi berlaku selama aplikasi berjalan.
- Tema Terang/Gelap bisa diganti dari Profil > Tema (pilihan tersimpan di perangkat).
- Logo ada di `assets/images/` (`logo.png` lengkap, `logo_icon.png` ikon saja). Ganti file ini untuk mengganti logo.

## Ikon aplikasi (launcher icon)
Setelah `flutter pub get`, jalankan sekali:

    dart run flutter_launcher_icons

lalu `flutter run` ulang (jika ikon lama masih tampil, uninstall aplikasinya dulu).
Untuk mengganti ikon, timpa `assets/icon/app_icon.png` dan `assets/icon/app_icon_foreground.png` (1024x1024), lalu jalankan perintah di atas lagi.

## Arsitektur & rencana ke depan
Tahap ini hanya frontend. Titik sambung untuk tahap berikutnya sudah disiapkan:

| Kebutuhan | Titik sambung | Yang perlu dilakukan nanti |
|---|---|---|
| Backend / database | `FinanceRepository` (`lib/data/repositories/`) | Buat `RemoteFinanceRepository`, berikan ke `AppState(finance: ...)` di `main.dart` |
| AI sungguhan | `FinAIService` (`lib/services/finai_service.dart`) | Buat implementasi yang memanggil backend/LLM, ganti `RuleBasedFinAIService` di `main.dart` |
| Login sungguhan | `AuthService` (`lib/services/auth_service.dart`) | Buat implementasi yang memanggil backend (sudah async), simpan token di secure storage, lalu berikan ke `AppState(auth: ...)` |

Catatan:
- Seluruh tanggal "hari ini" dibaca dari `AppClock` (`lib/core/utils/app_clock.dart`), bukan tanggal tetap. Data contoh (`dummy_data.dart`) dibuat relatif terhadap hari ini.
- Nama kategori ada di `lib/core/constants/app_categories.dart`.
- Transaksi dan dompet disimpan bersamaan dalam satu key (`ft_finance_v2`); data format lama dimigrasi otomatis. Jika data rusak, salinannya disimpan di `ft_finance_corrupt_backup`.
- Data di perangkat belum dipisah per akun; ini akan tertangani saat ada backend.

Pembagian tanggung jawab `AppState` (fasad untuk UI): `Ledger` (dompet, transaksi, aturan saldo), `FinanceRepository` (penyimpanan), `AuthService` (akun), `PinService` (kunci PIN).
