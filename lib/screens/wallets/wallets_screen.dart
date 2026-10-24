import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/wallet_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/category_chip/app_filter_chip.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/transaction_form/amount_input.dart';
import '../../widgets/wallet_card/wallet_card.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  Future<void> _openAddSheet(BuildContext context, [WalletModel? wallet]) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddWalletSheet(wallet: wallet),
    );
  }

  Future<void> _delete(BuildContext context, WalletModel wallet) async {
    final state = context.read<AppState>();
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Hapus Dompet',
      message: 'Hapus dompet "${wallet.name}"?',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    if (state.deleteWallet(wallet.id)) {
      AppSnackbar.success(context, 'Dompet berhasil dihapus');
    } else {
      AppSnackbar.error(
        context,
        'Dompet masih dipakai transaksi dan tidak bisa dihapus.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final wallets = state.wallets;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(showBack: true),
            ),
            Expanded(
              child: wallets.isEmpty
                  ? EmptyState(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Belum Ada Dompet',
                      message: 'Tambahkan dompet untuk mulai mencatat saldo.',
                      buttonLabel: 'Tambah Dompet',
                      onPressed: () => _openAddSheet(context),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppConstants.pagePadding),
                      children: [
                        Text('Dompet & Rekening', style: AppTextStyles.h1),
                        const SizedBox(height: 4),
                        Text(
                          'Total saldo ${Formatters.rupiah(state.totalBalance)}',
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: 16),
                        for (final w in wallets)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WalletTile(
                              wallet: w,
                              onEdit: () => _openAddSheet(context, w),
                              onDelete: () => _delete(context, w),
                            ),
                          ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          label: '+ Tambah Dompet',
                          onPressed: () => _openAddSheet(context),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWalletSheet extends StatefulWidget {
  final WalletModel? wallet;

  const _AddWalletSheet({this.wallet});

  @override
  State<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<_AddWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  WalletType _type = WalletType.cash;

  bool get _editing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    if (w != null) {
      _nameController.text = w.name;
      _type = w.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final balance =
        int.tryParse(_balanceController.text.replaceAll('.', '')) ?? 0;
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    if (_editing) {
      state.updateWallet(widget.wallet!.id,
          name: _nameController.text, type: _type);
      AppSnackbar.success(context, 'Dompet berhasil diperbarui');
      navigator.pop();
      return;
    }
    state.addWallet(
      name: _nameController.text,
      type: _type,
      initialBalance: balance,
    );
    AppSnackbar.success(context, 'Dompet berhasil ditambahkan');
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
              Text(_editing ? 'Ubah Dompet' : 'Tambah Dompet',
                  style: AppTextStyles.h2),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nama Dompet',
                hint: 'Contoh: Bank Mandiri',
                controller: _nameController,
                prefixIcon: Icons.account_balance_wallet_outlined,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'Nama dompet'),
              ),
              const SizedBox(height: 16),
              Text('Jenis', style: AppTextStyles.label),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final t in WalletType.values) ...[
                      AppFilterChip(
                        label: t.label,
                        selected: _type == t,
                        onTap: () => setState(() => _type = t),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!_editing) ...[
                CustomTextField(
                  label: 'Saldo Awal',
                  hint: '0',
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_outlined,
                  inputFormatters: [ThousandsFormatter()],
                ),
                const SizedBox(height: 4),
                Text(
                  'Kosongkan jika saldo awal Rp0.',
                  style: AppTextStyles.caption,
                ),
              ] else
                Text(
                  'Saldo berubah otomatis mengikuti transaksi.',
                  style: AppTextStyles.caption,
                ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Simpan Dompet', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
