import 'package:flutter/material.dart';

import '../../core/constants/app_categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/report_model.dart';
import '../common/primary_button.dart';

Future<void> showBudgetSimulator(BuildContext context, ReportModel report) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _BudgetSimulator(report: report),
  );
}

class _BudgetSimulator extends StatefulWidget {
  final ReportModel report;

  const _BudgetSimulator({required this.report});

  @override
  State<_BudgetSimulator> createState() => _BudgetSimulatorState();
}

class _BudgetSimulatorState extends State<_BudgetSimulator> {
  static const List<String> _flexible = AppCategories.discretionary;

  double _cut = 15;

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final byCat = r.expenseByCategory;
    final flexibleTotal = _flexible.fold<int>(0, (s, c) => s + (byCat[c] ?? 0));
    final saving = (flexibleTotal * _cut / 100).round();
    final newExpense = r.expense - saving;
    final newNet = r.income - newExpense;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simulasi Anggaran', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            Text(
              'Geser untuk melihat dampak memangkas pengeluaran tidak wajib (makanan & minuman, belanja, hiburan).',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Pangkas pengeluaran tidak wajib',
                      style: AppTextStyles.label),
                ),
                Text('${_cut.round()}%',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
              ],
            ),
            Slider(
              value: _cut,
              min: 0,
              max: 40,
              divisions: 8,
              label: '${_cut.round()}%',
              onChanged: (v) => setState(() => _cut = v),
            ),
            const SizedBox(height: 8),
            for (final c in _flexible)
              if ((byCat[c] ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(c, style: AppTextStyles.body)),
                      Text(
                        '${Formatters.rupiah(byCat[c]!)} → ${Formatters.rupiah((byCat[c]! * (1 - _cut / 100)).round())}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
            const Divider(height: 28),
            _Row('Penghematan', Formatters.rupiah(saving), AppColors.income),
            _Row('Pengeluaran baru', Formatters.rupiah(newExpense),
                AppColors.textPrimary),
            _Row(
              'Surplus',
              '${Formatters.rupiah(r.net)} → ${Formatters.rupiah(newNet)}',
              AppColors.primary,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Tutup',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Row(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
          Text(
            value,
            style: AppTextStyles.label.copyWith(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}
