import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_clock.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/report_builder.dart';
import '../../models/report_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../services/export_service.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/category_chip/app_filter_chip.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/primary_button.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  /// Bulan yang dipilih (selalu tanggal 1), atau null untuk "Semua data".
  DateTime? _month = DateTime(AppClock.today().year, AppClock.today().month);
  ExportFormat _format = ExportFormat.pdf;
  bool _busy = false;

  String get _periodLabel =>
      _month == null ? 'Semua data' : Formatters.monthYear(_month!);

  /// Bulan ini + semua bulan yang punya transaksi (terbaru dulu, maksimal 12).
  List<DateTime> _availableMonths(AppState state) {
    final today = AppClock.today();
    final months = <DateTime>{DateTime(today.year, today.month)};
    for (final t in state.transactions) {
      months.add(DateTime(t.date.year, t.date.month));
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted.take(12).toList();
  }

  List<TransactionModel> _selected(AppState state) {
    final month = _month;
    if (month == null) return state.transactions;
    final r = ReportBuilder.range(ReportPeriod.monthly, month);
    return state.transactions
        .where((t) => !t.date.isBefore(r.start) && t.date.isBefore(r.end))
        .toList();
  }

  Future<void> _export() async {
    if (!ExportService.isSupported) {
      AppSnackbar.error(
        context,
        'Ekspor hanya tersedia di aplikasi Android.',
      );
      return;
    }

    final state = context.read<AppState>();
    final txs = _selected(state);
    if (txs.isEmpty) {
      AppSnackbar.error(context, 'Tidak ada transaksi pada periode ini.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ExportService.exportTransactions(
        format: _format,
        transactions: txs,
        walletName: (id) => state.walletById(id)?.name ?? '-',
        periodLabel: _periodLabel,
      );
      if (mounted) AppSnackbar.success(context, 'File berhasil dibuat');
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Gagal membuat file. Silakan coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final count = _selected(state).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(showBack: true),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                children: [
                  Text('Ekspor Data Finansial', style: AppTextStyles.h1),
                  const SizedBox(height: 6),
                  Text(
                    'Buat file lalu bagikan atau simpan lewat menu Bagikan.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 20),
                  Text('PERIODE', style: AppTextStyles.overline),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final m in _availableMonths(state)) ...[
                          AppFilterChip(
                            label: Formatters.monthYear(m),
                            selected: _month == m,
                            onTap: () => setState(() => _month = m),
                          ),
                          const SizedBox(width: 8),
                        ],
                        AppFilterChip(
                          label: 'Semua data',
                          selected: _month == null,
                          onTap: () => setState(() => _month = null),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('FORMAT', style: AppTextStyles.overline),
                  const SizedBox(height: 8),
                  _FormatOption(
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'PDF',
                    subtitle:
                        'Laporan ringkas: ringkasan, distribusi, daftar transaksi',
                    selected: _format == ExportFormat.pdf,
                    onTap: () => setState(() => _format = ExportFormat.pdf),
                  ),
                  const SizedBox(height: 10),
                  _FormatOption(
                    icon: Icons.table_chart_rounded,
                    title: 'CSV (bisa dibuka di Excel)',
                    subtitle:
                        'Data mentah untuk diolah di Excel atau Google Sheets',
                    selected: _format == ExportFormat.csv,
                    onTap: () => setState(() => _format = ExportFormat.csv),
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    color: AppColors.lightGreen,
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$count transaksi akan diekspor ($_periodLabel)',
                            style: AppTextStyles.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Buat & Bagikan File',
                    isLoading: _busy,
                    onPressed: count == 0 ? null : _export,
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

class _FormatOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.lightGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.label.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
