import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_clock.dart';
import '../data/dummy_data.dart';
import '../data/ledger.dart';
import '../data/seed_data.dart';
import '../data/repositories/finance_repository.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../services/auth_service.dart';
import '../services/pin_service.dart';
import '../services/reminder_service.dart';

/// State global aplikasi (fasad untuk UI).
///
/// Logikanya dipisah ke bagian-bagian yang bisa diganti/diuji sendiri:
/// - [Ledger]            : dompet, transaksi, aturan saldo
/// - [FinanceRepository] : penyimpanan transaksi + dompet
/// - [AuthService]       : login/akun (sementara di memori)
/// - [PinService]        : kunci PIN
/// Di sini tersisa sesi pengguna, navigasi, notifikasi, dan pengaturan.
class AppState extends ChangeNotifier {
  AppState({
    SharedPreferences? prefs,
    FinanceRepository? finance,
    AuthService? auth,
    ReminderService? reminder,
  })  : _prefs = prefs,
        _reminder = reminder ?? const NoopReminderService(),
        _finance = finance ?? LocalFinanceRepository(prefs),
        _auth = auth ?? InMemoryAuthService(),
        _pin = PinService(prefs);

  static const String _kReminder = 'ft_reminder';
  static const String _kReminderAsked = 'ft_reminder_asked';
  static const String _kLimit = 'ft_daily_limit';
  static const String _kRemember = 'ft_remember_id';
  static const String _kNamePrefix = 'ft_name_';
  static const String _kThemeDark = 'ft_theme_dark';

  final SharedPreferences? _prefs;
  final FinanceRepository _finance;
  final AuthService _auth;
  final PinService _pin;
  final ReminderService _reminder;

  /// Kosong sampai ada yang login; isinya dimuat per akun saat login.
  final Ledger _ledger = Ledger();

  UserModel? _currentUser;
  String? _selectedTransactionId;

  /// 0 Beranda, 1 Transaksi, 2 FinAI, 3 Profil.
  int tabIndex = 0;

  final List<String> _notifications = [
    'Selamat datang di FinTrack. Mulai catat transaksi pertamamu.',
  ];
  int unreadNotifications = 1;

  bool _reminderEnabled = true;
  bool _darkMode = false;
  int? dailyLimit;
  String? rememberedId;

  // ------------------------------------------------------- Penyimpanan

  /// Memuat data tersimpan. Panggil (dan tunggu) sekali sebelum `runApp`.
  Future<void> init() async {
    final p = _prefs;
    if (p != null) {
      _reminderEnabled = p.getBool(_kReminder) ?? true;
      _darkMode = p.getBool(_kThemeDark) ?? false;
      AppColors.dark = _darkMode;
      dailyLimit = p.getInt(_kLimit);
      rememberedId = p.getString(_kRemember);
    }
    _pin.load();
  }

  /// Memuat data keuangan milik akun yang sedang login.
  Future<void> _loadLedger(UserModel user) async {
    final isDemo = user.email == DummyData.demoEmail;
    var snapshot = SeedData.forAccount(isDemo: isDemo);
    try {
      final result = await _finance.load(user.id);
      if (result.snapshot != null) {
        snapshot = result.snapshot!;
      } else if (result.corrupted) {
        addNotification(
          'Data tersimpan tidak bisa dibaca, sehingga data awal dipakai. '
          'Salinan data lama disimpan sebagai cadangan.',
        );
      }
    } catch (_) {
      addNotification('Data tersimpan gagal dimuat. Data awal dipakai.');
    }
    _ledger.replaceAll(snapshot);
  }

  /// Menyimpan transaksi + dompet. Kegagalan tidak boleh diam-diam.
  void _persistData() {
    final userId = _currentUser?.id;
    if (userId == null) return;
    unawaited(
      _finance.save(userId, _ledger.snapshot()).catchError((Object _) {
        addNotification(
          'Perubahan belum tersimpan di perangkat. Periksa ruang penyimpanan.',
        );
        notifyListeners();
      }),
    );
  }

  // ---------------------------------------------------------------- Auth

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// true jika berhasil. Melempar exception jika layanan tidak terjangkau.
  Future<bool> login(String identifier, String password) async {
    final account = await _auth.login(identifier, password);
    if (account == null) return false;

    final id = account.email;
    final name = _prefs?.getString('$_kNamePrefix$id') ?? account.name;
    _currentUser = id == DummyData.demoEmail
        ? UserModel(
            id: DummyData.user.id,
            name: name,
            email: DummyData.user.email,
            phone: DummyData.user.phone,
          )
        : UserModel(id: 'u_$id', name: name, email: id);
    await _loadLedger(_currentUser!);
    notifyListeners();
    return true;
  }

  /// Mengubah nama tampilan akun yang sedang login. Mengembalikan false jika
  /// nama kosong atau tidak ada sesi login.
  bool updateName(String newName) {
    final user = _currentUser;
    final name = newName.trim();
    if (user == null || name.isEmpty) return false;
    _currentUser = UserModel(
      id: user.id,
      name: name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
    );
    unawaited(_auth.updateName(user.email, name));
    _prefs?.setString('$_kNamePrefix${user.email}', name);
    notifyListeners();
    return true;
  }

  Future<bool> isEmailRegistered(String email) =>
      _auth.isEmailRegistered(email);

  /// Mengembalikan false jika email sudah dipakai.
  Future<bool> register(String name, String email, String password) =>
      _auth.register(name, email, password);

  /// Atur ulang kata sandi (alur Lupa Kata Sandi).
  Future<bool> resetPassword(String email, String newPassword) =>
      _auth.resetPassword(email, newPassword);

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _currentUser;
    if (user == null) return 'Sesi login tidak ditemukan.';
    return _auth.changePassword(user.email, currentPassword, newPassword);
  }

  void logout() {
    _currentUser = null;
    _selectedTransactionId = null;
    tabIndex = 0;
    // Data akun ini jangan sampai terlihat oleh akun berikutnya.
    _ledger.replaceAll(const FinanceSnapshot(transactions: [], wallets: []));
    // Batalkan pengingat; dijadwalkan ulang saat login berikutnya.
    unawaited(
      _reminder
          .sync(enabled: false, hasTransactionToday: false)
          .catchError((Object _) {}),
    );
    notifyListeners();
  }

  void setRememberedId(String? id) {
    rememberedId = id;
    final p = _prefs;
    if (p != null) {
      if (id == null) {
        p.remove(_kRemember);
      } else {
        p.setString(_kRemember, id);
      }
    }
  }

  // ----------------------------------------------------------------- PIN

  bool get hasPin => _pin.hasPin;

  void setPin(String pin) {
    _pin.set(pin);
    notifyListeners();
  }

  bool verifyPin(String pin) => _pin.verify(pin);

  void removePin() {
    _pin.remove();
    notifyListeners();
  }

  // ----------------------------------------------------------- Navigasi

  void setTab(int index) {
    if (index == tabIndex) return;
    tabIndex = index;
    notifyListeners();
  }

  // -------------------------------------------------------------- Wallets

  List<WalletModel> get wallets => _ledger.wallets;

  WalletModel? walletById(String id) => _ledger.walletById(id);

  int get totalBalance => _ledger.totalBalance;

  void addWallet({
    required String name,
    required WalletType type,
    required int initialBalance,
  }) {
    _ledger.addWallet(name: name, type: type, initialBalance: initialBalance);
    _persistData();
    notifyListeners();
  }

  void updateWallet(String id,
      {required String name, required WalletType type}) {
    if (!_ledger.updateWallet(id, name: name, type: type)) return;
    _persistData();
    notifyListeners();
  }

  /// Gagal (false) jika dompet masih dipakai oleh transaksi.
  bool deleteWallet(String id) {
    if (!_ledger.deleteWallet(id)) return false;
    _persistData();
    notifyListeners();
    return true;
  }

  // --------------------------------------------------------- Transactions

  /// Diurutkan dari yang terbaru.
  List<TransactionModel> get transactions => _ledger.transactions;

  TransactionModel? get selectedTransaction {
    final id = _selectedTransactionId;
    return id == null ? null : _ledger.transactionById(id);
  }

  void selectTransaction(String? id) {
    _selectedTransactionId = id;
    notifyListeners();
  }

  bool hasTransactionOn(DateTime day) => _ledger.hasTransactionOn(day);

  int expenseOn(DateTime day) => _ledger.expenseOn(day);

  void addTransaction(TransactionModel t) {
    _ledger.addTransaction(t);
    _persistData();
    unawaited(refreshReminder());
    addNotification('Transaksi "${t.title}" berhasil dicatat.');
    notifyListeners();
  }

  void updateTransaction(TransactionModel updated) {
    if (!_ledger.updateTransaction(updated)) return;
    _persistData();
    unawaited(refreshReminder());
    addNotification('Transaksi "${updated.title}" diperbarui.');
    notifyListeners();
  }

  void deleteTransaction(String id) {
    final title = _ledger.deleteTransaction(id);
    if (title == null) return;
    if (_selectedTransactionId == id) _selectedTransactionId = null;
    _persistData();
    unawaited(refreshReminder());
    addNotification('Transaksi "$title" dihapus.');
    notifyListeners();
  }

  // ------------------------------------------------------- Notifikasi

  List<String> get notifications => List.unmodifiable(_notifications);

  void addNotification(String text) {
    _notifications.insert(0, text);
    if (_notifications.length > 20) _notifications.removeLast();
    unreadNotifications++;
  }

  void markNotificationsRead() {
    if (unreadNotifications == 0) return;
    unreadNotifications = 0;
    notifyListeners();
  }

  // ------------------------------------------------------------ Pengaturan

  bool get reminderEnabled => _reminderEnabled;
  bool get darkMode => _darkMode;

  /// Mengganti tema terang/gelap dan menyimpannya di perangkat.
  void setDarkMode(bool value) {
    if (_darkMode == value) return;
    _darkMode = value;
    AppColors.dark = value;
    _prefs?.setBool(_kThemeDark, value);
    notifyListeners();
  }

  /// Mengaktifkan/mematikan pengingat. Mengembalikan false jika pengguna
  /// menolak izin notifikasi (pengingat tetap mati).
  Future<bool> setReminder(bool value) async {
    if (value) {
      var granted = false;
      try {
        granted = await _reminder.requestPermission();
      } catch (_) {}
      if (!granted) return false;
    }
    _reminderEnabled = value;
    await _prefs?.setBool(_kReminder, value);
    notifyListeners();
    await refreshReminder();
    return true;
  }

  /// Dipanggil sekali setelah masuk ke halaman utama: meminta izin notifikasi
  /// untuk pertama kali (jika pengingat aktif), lalu menyelaraskan jadwal.
  Future<void> setupReminder() async {
    final p = _prefs;
    if (_reminderEnabled &&
        p != null &&
        !(p.getBool(_kReminderAsked) ?? false)) {
      await p.setBool(_kReminderAsked, true);
      var granted = false;
      try {
        granted = await _reminder.requestPermission();
      } catch (_) {}
      if (!granted) {
        _reminderEnabled = false;
        await p.setBool(_kReminder, false);
        notifyListeners();
      }
    }
    await refreshReminder();
  }

  /// Menyelaraskan jadwal notifikasi. Tidak pernah melempar error.
  Future<void> refreshReminder() async {
    try {
      await _reminder.sync(
        enabled: _reminderEnabled,
        hasTransactionToday: _ledger.hasTransactionOn(AppClock.today()),
      );
    } catch (_) {}
  }

  void setDailyLimit(int? value) {
    dailyLimit = value;
    final p = _prefs;
    if (p != null) {
      if (value == null) {
        p.remove(_kLimit);
      } else {
        p.setInt(_kLimit, value);
      }
    }
    notifyListeners();
  }
}
