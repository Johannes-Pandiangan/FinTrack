import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/transaction_form/transaction_form.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<TransactionFormState>();

  void _save(TransactionModel t) {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    state.addTransaction(t);
    state.setTab(0);
    AppSnackbar.success(context, 'Transaksi berhasil disimpan');
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePadding,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Catat Transaksi',
                            style: AppTextStyles.h1,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => _formKey.currentState?.reset(),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TransactionForm(
                      key: _formKey,
                      submitLabel: '✓ Simpan Transaksi',
                      onSubmit: _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
