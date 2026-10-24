import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/info_dialog.dart';
import '../../widgets/common/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agree = false;
  bool _termsError = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState!.validate();
    setState(() => _termsError = !_agree);
    if (!formValid || !_agree) {
      AppSnackbar.error(context, 'Periksa kembali data yang kamu isi.');
      return;
    }

    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    setState(() => _loading = true);

    bool ok;
    try {
      ok = await state.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackbar.error(context, 'Tidak dapat terhubung. Coba lagi.');
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      AppSnackbar.error(context, 'Email sudah terdaftar. Gunakan email lain.');
      return;
    }
    AppSnackbar.success(context, 'Akun berhasil dibuat. Silakan masuk.');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pagePadding,
            vertical: 8,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  showBack: true,
                  onProfileTap: () => AppSnackbar.info(
                    context,
                    'Masuk atau daftar untuk membuka profil.',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'AKSES GRATIS 100%',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Mulai Kelola Keuanganmu 🚀', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  'Daftar akun gratis dan pantau keuangan dengan FinAI dalam satu ketukan.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Nama Lengkap',
                  hint: 'Nama lengkap kamu',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'Nama lengkap'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Alamat Email',
                  hint: 'nama@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Kata Sandi',
                  hint: 'Minimal 6 karakter',
                  controller: _passwordController,
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    tooltip: _obscure
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                  suffixIcon: IconButton(
                    tooltip: _obscureConfirm
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() {
                    _agree = !_agree;
                    if (_agree) _termsError = false;
                  }),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agree,
                        onChanged: (v) => setState(() {
                          _agree = v ?? false;
                          if (_agree) _termsError = false;
                        }),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi FinTrack.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_termsError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 16, color: AppColors.expense),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Anda harus menyetujui syarat dan ketentuan.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.expense),
                          ),
                        ),
                      ],
                    ),
                  ),
                Wrap(
                  children: [
                    TextButton(
                      onPressed: () => showInfoDialog(
                        context,
                        title: 'Syarat & Ketentuan',
                        message:
                            'FinTrack digunakan untuk mencatat dan memantau keuangan pribadi. Kamu bertanggung jawab atas keakuratan data yang dimasukkan. Ini adalah prototype sehingga hasil analisis bersifat informatif, bukan nasihat keuangan.',
                      ),
                      child: const Text('Baca Syarat & Ketentuan'),
                    ),
                    TextButton(
                      onPressed: () => showInfoDialog(
                        context,
                        title: 'Kebijakan Privasi',
                        message:
                            'Data transaksi dan dompet disimpan di perangkat ini dan tidak dikirim ke server. Kata sandi tidak disimpan permanen.',
                      ),
                      child: const Text('Baca Kebijakan Privasi'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Daftar Akun Baru',
                  onPressed: _submit,
                  isLoading: _loading,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Sudah punya akun? ',
                          style: AppTextStyles.bodySecondary),
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child:
                              Text('Masuk di sini', style: AppTextStyles.link),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
