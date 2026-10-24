import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../data/dummy_data.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/fintrack_logo.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/sheets/forgot_password_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _remember = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final remembered = context.read<AppState>().rememberedId;
    if (remembered != null) {
      _idController.text = remembered;
      _remember = true;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, 'Periksa kembali data yang kamu isi.');
      return;
    }

    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    setState(() => _loading = true);

    bool ok;
    try {
      ok = await state.login(_idController.text, _passwordController.text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackbar.error(context, 'Tidak dapat terhubung. Coba lagi.');
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      state.setRememberedId(_remember ? _idController.text.trim() : null);
      if (state.hasPin) {
        navigator.pushReplacementNamed(AppRoutes.pinLock, arguments: true);
      } else {
        navigator.pushReplacementNamed(AppRoutes.home);
      }
    } else {
      AppSnackbar.error(context, 'Email atau kata sandi salah.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Center(child: FinTrackLogo(size: 120, showName: true)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'FINANCIAL INTELLIGENCE & TRACKING',
                    style: AppTextStyles.overline,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 36),
                Text('Selamat Datang Kembali 👋', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk mengelola keuangan dan dompet Anda secara terencana.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  label: 'Alamat Email',
                  hint: 'nama@email.com',
                  controller: _idController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Password',
                  hint: 'Masukkan kata sandi',
                  controller: _passwordController,
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => Validators.required(v, 'Kata sandi'),
                  suffixIcon: IconButton(
                    tooltip: _obscure
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _remember = !_remember),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged: (v) =>
                                  setState(() => _remember = v ?? false),
                            ),
                            Flexible(
                              child: Text(
                                'Ingat Saya',
                                style: AppTextStyles.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => showForgotPasswordSheet(
                        context,
                        _idController.text,
                      ),
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: AppTextStyles.link,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Masuk ke Akun →',
                  onPressed: _submit,
                  isLoading: _loading,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun FinTrack? ',
                        style: AppTextStyles.bodySecondary,
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Daftar Sekarang',
                            style: AppTextStyles.link,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Akun demo: ${DummyData.demoEmail} / ${DummyData.demoPassword}',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
