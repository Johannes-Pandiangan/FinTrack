import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/transaction_form/transaction_form.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = context.read<AppState>().selectedTransaction;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(showBack: true),
            ),
            Expanded(
              child: tx == null
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Transaksi Tidak Ditemukan',
                      message: 'Data transaksi ini sudah tidak tersedia.',
                      buttonLabel: 'Kembali',
                      onPressed: () => Navigator.maybePop(context),
                    )
                  : SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePadding,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Transaksi', style: AppTextStyles.h1),
                          const SizedBox(height: 16),
                          TransactionForm(
                            initial: tx,
                            submitLabel: 'Simpan Perubahan',
                            onSubmit: (TransactionModel updated) {
                              final state = context.read<AppState>();
                              final navigator = Navigator.of(context);
                              state.updateTransaction(updated);
                              AppSnackbar.success(
                                context,
                                'Transaksi berhasil diperbarui',
                              );
                              navigator.pop();
                            },
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
