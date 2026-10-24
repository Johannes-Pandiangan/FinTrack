import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/fintrack_logo.dart';
import '../../widgets/common/primary_button.dart';

class PinLockScreen extends StatefulWidget {
  final bool fromLogin;

  const PinLockScreen({super.key, this.fromLogin = false});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  static const int _maxAttempts = 5;

  final _controller = TextEditingController();
  int _attempts = 0;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _logout() {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    state.logout();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _verify() {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    if (state.verifyPin(_controller.text)) {
      if (widget.fromLogin) {
        navigator.pushReplacementNamed(AppRoutes.home);
      } else {
        navigator.pop();
      }
      return;
    }

    _attempts++;
    _controller.clear();
    if (_attempts >= _maxAttempts) {
      AppSnackbar.error(
          context, 'Terlalu banyak percobaan. Silakan masuk ulang.');
      _logout();
      return;
    }
    setState(() =>
        _error = 'PIN salah. Sisa percobaan: ${_maxAttempts - _attempts}');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Column(
                children: [
                  const FinTrackLogo(size: 72),
                  const SizedBox(height: 20),
                  Text('Masukkan PIN', style: AppTextStyles.h1),
                  const SizedBox(height: 6),
                  Text(
                    'Aplikasi terkunci. Masukkan PIN untuk melanjutkan.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onSubmitted: (_) => _verify(),
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(hintText: '••••'),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 16, color: AppColors.expense),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.expense),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  PrimaryButton(label: 'Buka Kunci', onPressed: _verify),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _logout,
                    child: const Text('Lupa PIN? Keluar dari akun'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
