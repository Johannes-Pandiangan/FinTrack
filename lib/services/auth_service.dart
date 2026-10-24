import '../data/dummy_data.dart';

/// Akun yang berhasil diautentikasi.
class AuthAccount {
  final String name;
  final String email;

  const AuthAccount({required this.name, required this.email});
}

/// Kontrak autentikasi.
///
/// Semua metode async karena implementasi sungguhan akan memanggil backend.
/// Implementasi boleh melempar exception (mis. tidak ada koneksi); layar
/// menanganinya dan menampilkan pesan gagal.
abstract class AuthService {
  /// Mengembalikan akun jika email/sandi benar, atau null jika salah.
  Future<AuthAccount?> login(String identifier, String password);

  /// false jika email sudah dipakai.
  Future<bool> register(String name, String email, String password);

  Future<bool> isEmailRegistered(String email);

  /// false jika akun tidak ditemukan.
  Future<bool> resetPassword(String email, String newPassword);

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  );

  Future<void> updateName(String email, String name);
}

class _Account {
  final String name;
  final String password;
  const _Account(this.name, this.password);
}

/// Implementasi sementara untuk prototype: akun hidup di memori saja dan
/// hilang saat aplikasi ditutup. BUKAN autentikasi sungguhan.
class InMemoryAuthService implements AuthService {
  InMemoryAuthService({
    this.latency = const Duration(milliseconds: 700),
  }) : _accounts = {
          DummyData.demoEmail:
              const _Account('FinTrack', DummyData.demoPassword),
        };

  /// Jeda buatan agar terasa seperti memanggil server. Set `Duration.zero`
  /// di test.
  final Duration latency;

  final Map<String, _Account> _accounts;

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  static String _key(String email) => email.trim().toLowerCase();

  @override
  Future<AuthAccount?> login(String identifier, String password) async {
    await _wait();
    final id = _key(identifier);
    final account = _accounts[id];
    if (account == null || account.password != password) return null;
    return AuthAccount(name: account.name, email: id);
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    await _wait();
    final id = _key(email);
    if (_accounts.containsKey(id)) return false;
    _accounts[id] = _Account(name.trim(), password);
    return true;
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    await _wait();
    return _accounts.containsKey(_key(email));
  }

  @override
  Future<bool> resetPassword(String email, String newPassword) async {
    await _wait();
    final id = _key(email);
    final account = _accounts[id];
    if (account == null) return false;
    _accounts[id] = _Account(account.name, newPassword);
    return true;
  }

  @override
  Future<String?> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    await _wait();
    final id = _key(email);
    final account = _accounts[id];
    if (account == null || account.password != currentPassword) {
      return 'Kata sandi saat ini salah.';
    }
    _accounts[id] = _Account(account.name, newPassword);
    return null;
  }

  @override
  Future<void> updateName(String email, String name) async {
    final id = _key(email);
    final account = _accounts[id];
    if (account != null) _accounts[id] = _Account(name, account.password);
  }
}
