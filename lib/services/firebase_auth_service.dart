import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/dummy_data.dart';
import 'auth_service.dart';

/// Implementasi autentikasi menggunakan Firebase Authentication dan Cloud Firestore.
class FirebaseAuthService extends AuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static String _cleanEmail(String email) => email.trim().toLowerCase();

  @override
  bool get usesEmailResetLink => true;

  @override
  Future<AuthAccount?> login(String identifier, String password) async {
    final email = _cleanEmail(identifier);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _buildAccount(credential.user, fallbackEmail: email);
    } on FirebaseAuthException catch (e) {
      // Jika pengguna mencoba akun demo untuk pertama kalinya di proyek Firebase baru,
      // otomatis buatkan akun demo di Firebase agar kredensial demo di README langsung jalan.
      if (email == DummyData.demoEmail &&
          password == DummyData.demoPassword &&
          (e.code == 'user-not-found' || e.code == 'invalid-credential')) {
        try {
          final created = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          await created.user?.updateDisplayName(DummyData.user.name);
          await _saveUserProfile(
            created.user!.uid,
            name: DummyData.user.name,
            email: email,
          );
          return AuthAccount(
            uid: created.user!.uid,
            name: DummyData.user.name,
            email: email,
          );
        } on FirebaseAuthException {
          return null;
        }
      }

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email' ||
          e.code == 'user-disabled') {
        return null;
      }
      rethrow;
    }
  }

  Future<AuthAccount?> _buildAccount(
    User? user, {
    required String fallbackEmail,
  }) async {
    if (user == null) return null;
    final email = _cleanEmail(user.email ?? fallbackEmail);
    var name = (user.displayName ?? '').trim();

    if (name.isEmpty) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null && data['name'] is String) {
          name = (data['name'] as String).trim();
        }
      } catch (_) {}
    }

    if (name.isEmpty) {
      name = email == DummyData.demoEmail
          ? DummyData.user.name
          : email.split('@').first;
    }

    return AuthAccount(
      uid: user.uid,
      name: name,
      email: email,
    );
  }

  Future<void> _saveUserProfile(
    String uid, {
    required String name,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'name': name.trim(),
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Jangan gagalkan alur login/register jika penyimpanan profil metadata tertunda.
    }
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    final cleanEmail = _cleanEmail(email);
    final cleanName = name.trim();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(cleanName);
        await _saveUserProfile(user.uid, name: cleanName, email: cleanEmail);
      }
      // RegisterScreen mengarahkan pengguna kembali ke halaman Login untuk masuk.
      await _auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    final cleanEmail = _cleanEmail(email);
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) return false;
    try {
      // Pada Firebase Auth, sendPasswordResetEmail digunakan untuk mereset sandi.
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword(String email, String newPassword) async {
    final cleanEmail = _cleanEmail(email);
    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<String?> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'Sesi login tidak ditemukan. Silakan masuk ulang.';
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: _cleanEmail(user.email ?? email),
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Kata sandi saat ini salah.';
      }
      if (e.code == 'weak-password') {
        return 'Kata sandi baru terlalu lemah (minimal 6 karakter).';
      }
      if (e.code == 'requires-recent-login') {
        return 'Demi keamanan, silakan keluar lalu masuk kembali sebelum mengubah sandi.';
      }
      return 'Gagal mengubah kata sandi. Periksa koneksi internet Anda.';
    }
  }

  @override
  Future<void> updateName(String email, String name) async {
    final cleanName = name.trim();
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await user.updateDisplayName(cleanName);
      await _saveUserProfile(
        user.uid,
        name: cleanName,
        email: _cleanEmail(user.email ?? email),
      );
    } catch (_) {}
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
