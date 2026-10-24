import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    String? error;
    try {
      error = await state.changePassword(_current.text, _newPassword.text);
    } catch (_) {
      error = 'Tidak dapat terhubung. Coba lagi.';
    }
    if (!mounted) return;
    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }
    AppSnackbar.success(context, 'Kata sandi berhasil diubah');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(showBack: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubah Kata Sandi', style: AppTextStyles.h1),
                      const SizedBox(height: 6),
                      Text(
                        'Kata sandi tidak disimpan permanen di prototype ini, jadi perubahan berlaku selama aplikasi berjalan.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Kata Sandi Saat Ini',
                        hint: 'Masukkan kata sandi saat ini',
                        controller: _current,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.required(v, 'Kata sandi saat ini'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Kata Sandi Baru',
                        hint: 'Minimal 6 karakter',
                        controller: _newPassword,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Konfirmasi Kata Sandi Baru',
                        hint: 'Ulangi kata sandi baru',
                        controller: _confirm,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (v) =>
                            Validators.confirmPassword(v, _newPassword.text),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                          label: 'Simpan Kata Sandi', onPressed: _save),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
