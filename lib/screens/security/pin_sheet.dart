import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_state.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';

enum PinMode { set, change, remove }

Future<void> showPinSheet(BuildContext context, PinMode mode) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PinSheet(mode: mode),
  );
}

class _PinSheet extends StatefulWidget {
  final PinMode mode;

  const _PinSheet({required this.mode});

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _newPin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _pinValidator(String? v) {
    if (v == null || v.isEmpty) return 'PIN wajib diisi';
    if (v.length < 4) return 'PIN minimal 4 digit';
    return null;
  }

  String get _title {
    switch (widget.mode) {
      case PinMode.set:
        return 'Aktifkan Kunci PIN';
      case PinMode.change:
        return 'Ubah PIN';
      case PinMode.remove:
        return 'Matikan Kunci PIN';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    if (widget.mode != PinMode.set && !state.verifyPin(_current.text)) {
      setState(() => _error = 'PIN saat ini salah.');
      return;
    }

    if (widget.mode == PinMode.remove) {
      state.removePin();
      AppSnackbar.info(context, 'Kunci PIN dimatikan');
    } else {
      state.setPin(_newPin.text);
      AppSnackbar.success(
        context,
        widget.mode == PinMode.set ? 'Kunci PIN aktif' : 'PIN berhasil diubah',
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final needCurrent = widget.mode != PinMode.set;
    final needNew = widget.mode != PinMode.remove;
    final formatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ];

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
              Text(_title, style: AppTextStyles.h2),
              const SizedBox(height: 6),
              Text('PIN terdiri dari 4–6 digit angka.',
                  style: AppTextStyles.bodySecondary),
              const SizedBox(height: 16),
              if (needCurrent) ...[
                CustomTextField(
                  label: 'PIN Saat Ini',
                  hint: '••••',
                  controller: _current,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: formatters,
                  prefixIcon: Icons.pin_outlined,
                  validator: _pinValidator,
                ),
                const SizedBox(height: 16),
              ],
              if (needNew) ...[
                CustomTextField(
                  label: 'PIN Baru',
                  hint: '••••',
                  controller: _newPin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: formatters,
                  prefixIcon: Icons.pin_outlined,
                  validator: _pinValidator,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Konfirmasi PIN Baru',
                  hint: '••••',
                  controller: _confirm,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: formatters,
                  prefixIcon: Icons.pin_outlined,
                  validator: (v) =>
                      v != _newPin.text ? 'Konfirmasi PIN tidak sama' : null,
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
                label: widget.mode == PinMode.remove
                    ? 'Matikan PIN'
                    : 'Simpan PIN',
                onPressed: _save,
                color: widget.mode == PinMode.remove
                    ? AppColors.expense
                    : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
