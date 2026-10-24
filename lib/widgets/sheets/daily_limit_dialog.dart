import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_state.dart';
import '../common/app_snackbar.dart';
import '../transaction_form/amount_input.dart';

Future<void> showDailyLimitDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _LimitDialog(),
  );
}

class _LimitDialog extends StatefulWidget {
  const _LimitDialog();

  @override
  State<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<_LimitDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = context.read<AppState>().dailyLimit;
    _controller = TextEditingController(
      text: current == null ? '' : Formatters.grouped(current),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = int.tryParse(_controller.text.replaceAll('.', '')) ?? 0;
    if (value <= 0) {
      AppSnackbar.error(context, 'Batas harian harus lebih dari Rp0');
      return;
    }
    context.read<AppState>().setDailyLimit(value);
    AppSnackbar.success(
      context,
      'Batas harian ${Formatters.rupiah(value)} disimpan',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasLimit = context.read<AppState>().dailyLimit != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Batas Pengeluaran Harian', style: AppTextStyles.h3),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Beranda akan menampilkan pemakaian harianmu terhadap batas ini.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsFormatter()],
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              hintText: '150.000',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        if (hasLimit)
          TextButton(
            onPressed: () {
              context.read<AppState>().setDailyLimit(null);
              AppSnackbar.info(context, 'Batas harian dihapus');
              Navigator.pop(context);
            },
            child: const Text('Hapus Batas'),
          ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
