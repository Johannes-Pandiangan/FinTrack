import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_state.dart';
import '../common/app_snackbar.dart';
import '../common/custom_text_field.dart';
import '../common/primary_button.dart';

Future<void> showForgotPasswordSheet(
    BuildContext context, String initialEmail) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ForgotPasswordSheet(initialEmail: initialEmail),
  );
}

class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordSheet({required this.initialEmail});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _verified = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(
      text: widget.initialEmail.contains('@') ? widget.initialEmail.trim() : '',
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();

    bool registered;
    try {
      registered = await state.isEmailRegistered(_email.text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Tidak dapat terhubung. Coba lagi.');
      return;
    }
    if (!mounted) return;
    if (!registered) {
      setState(() => _error = 'Email ini belum terdaftar di perangkat.');
      return;
    }
    setState(() {
      _error = null;
      _verified = true;
    });
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    bool ok;
    try {
      ok = await state.resetPassword(_email.text, _password.text);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = 'Gagal mengatur ulang kata sandi.');
      return;
    }
    AppSnackbar.success(context, 'Kata sandi diperbarui. Silakan masuk.');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lupa Kata Sandi', style: AppTextStyles.h2),
              const SizedBox(height: 6),
              Text(
                _verified
                    ? 'Buat kata sandi baru untuk ${_email.text.trim()}.'
                    : 'Masukkan email akunmu. Prototype ini belum mengirim email verifikasi, jadi kata sandi dapat langsung diatur ulang untuk akun yang terdaftar di perangkat ini.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 16),
              if (!_verified)
                CustomTextField(
                  label: 'Alamat Email',
                  hint: 'nama@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: Validators.email,
                )
              else ...[
                CustomTextField(
                  label: 'Kata Sandi Baru',
                  hint: 'Minimal 6 karakter',
                  controller: _password,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi baru',
                  controller: _confirm,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) =>
                      Validators.confirmPassword(v, _password.text),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 16, color: AppColors.expense),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _error!,
                          style:
                              TextStyle(fontSize: 12, color: AppColors.expense),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _verified ? 'Simpan Kata Sandi Baru' : 'Lanjut',
                onPressed: _verified ? _reset : _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
