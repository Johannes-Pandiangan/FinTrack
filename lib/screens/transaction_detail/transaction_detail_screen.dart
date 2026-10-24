import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/dummy_data.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/status_badge.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  // Disimpan agar halaman tidak berkedip kosong saat transaksi dihapus
  // dan animasi kembali masih berjalan.
  TransactionModel? _last;

  Future<void> _delete(TransactionModel tx) async {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Hapus Transaksi',
      message: 'Apakah Anda yakin ingin menghapus transaksi ini?',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    state.deleteTransaction(tx.id);
    AppSnackbar.success(context, 'Transaksi berhasil dihapus');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tx = state.selectedTransaction ?? _last;
    _last = tx;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(
                showBack: true,
                menu: tx == null
                    ? null
                    : PopupMenuButton<String>(
                        tooltip: 'Menu',
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.pushNamed(
                                context, AppRoutes.editTransaction);
                          } else {
                            _delete(tx);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'edit', child: Text('Ubah Data')),
                          PopupMenuItem(value: 'delete', child: Text('Hapus')),
                        ],
                      ),
              ),
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
                  : _Content(
                      tx: tx,
                      walletName: state.walletById(tx.walletId)?.name ??
                          'Dompet tidak ditemukan',
                      onEdit: () => Navigator.pushNamed(
                          context, AppRoutes.editTransaction),
                      onDelete: () => _delete(tx),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final TransactionModel tx;
  final String walletName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _Content({
    required this.tx,
    required this.walletName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = tx.isIncome ? AppColors.income : AppColors.expense;
    final background =
        tx.isIncome ? AppColors.incomeSoft : AppColors.expenseSoft;
    final icon =
        DummyData.categoryByName(tx.category)?.icon ?? Icons.category_rounded;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detail Transaksi', style: AppTextStyles.h1),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  tx.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 4),
                Text(
                  '${tx.category} • $walletName',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    Formatters.rupiah(tx.signedAmount, withSign: true),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                StatusBadge(
                  label: '✓ Berhasil Dicatat',
                  color: AppColors.income,
                  background: AppColors.incomeSoft,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Rincian Transaksi', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                _DetailRow(
                    label: 'Jenis',
                    value: tx.isIncome ? 'Pemasukan' : 'Pengeluaran'),
                _DetailRow(label: 'Kategori', value: tx.category),
                _DetailRow(label: 'Sumber Dana', value: walletName),
                _DetailRow(
                  label: 'Waktu & Tanggal',
                  value:
                      '${Formatters.fullDate(tx.date)}, ${Formatters.time(tx.date)}',
                ),
                _DetailRow(
                  label: 'Catatan',
                  value: tx.note.isEmpty ? '-' : tx.note,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Ubah Data', onPressed: onEdit),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Hapus',
            color: AppColors.expense,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(label, style: AppTextStyles.bodySecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.label.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
