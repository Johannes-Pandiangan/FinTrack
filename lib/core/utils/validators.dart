class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, 'Alamat email');
    if (empty != null) return empty;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    final empty = required(value, 'Kata sandi');
    if (empty != null) return empty;
    if (value!.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final empty = required(value, 'Konfirmasi kata sandi');
    if (empty != null) return empty;
    if (value != original) return 'Konfirmasi kata sandi tidak sama';
    return null;
  }
}
