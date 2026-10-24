import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/report_model.dart';

/// Grafik batang pemasukan vs pengeluaran (tanpa library eksternal).
///
/// Ketuk sebuah batang untuk melihat nilai pemasukan, pengeluaran, dan selisih
/// periode tersebut. Ketuk lagi untuk menutup.
class CashFlowChart extends StatefulWidget {
  final List<ReportBucket> buckets;
  final double height;
  final bool showLabels;

  const CashFlowChart({
    super.key,
    required this.buckets,
    this.height = 150,
    this.showLabels = true,
  });

  @override
  State<CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends State<CashFlowChart> {
  int? _selected;

  static String _signature(List<ReportBucket> buckets) =>
      buckets.map((b) => '${b.label}:${b.income}:${b.expense}').join('|');

  @override
  void didUpdateWidget(CashFlowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Data berganti (periode lain / transaksi berubah): tutup detail.
    if (_signature(oldWidget.buckets) != _signature(widget.buckets)) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buckets = widget.buckets;
    final height = widget.height;

    var maxValue = 0;
    var total = 0;
    for (final b in buckets) {
      maxValue = math.max(maxValue, math.max(b.income, b.expense));
      total += b.income + b.expense;
    }

    if (maxValue == 0) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('Belum ada data', style: AppTextStyles.caption),
        ),
      );
    }

    final barWidth = buckets.length > 8 ? 6.0 : 14.0;
    final labelSize = buckets.length > 8 ? 10.0 : 12.0;
    final selected =
        _selected != null && _selected! < buckets.length ? _selected : null;

    return Semantics(
      label: 'Grafik batang arus kas pemasukan dan pengeluaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey('${buckets.length}-$maxValue-$total'),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < buckets.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(
                          () => _selected = selected == i ? null : i,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: selected == i
                                ? AppColors.lightGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: height,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _bar(buckets[i].income, maxValue, t,
                                        AppColors.income),
                                    SizedBox(width: barWidth > 8 ? 4 : 2),
                                    _bar(buckets[i].expense, maxValue, t,
                                        AppColors.expense),
                                  ],
                                ),
                              ),
                              if (widget.showLabels)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    buckets[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption
                                        .copyWith(fontSize: labelSize),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          if (selected == null)
            Text(
              'Ketuk batang untuk melihat nilainya',
              style: AppTextStyles.caption,
            )
          else
            _Detail(bucket: buckets[selected]),
        ],
      ),
    );
  }

  Widget _bar(int value, int maxValue, double t, Color color) {
    final width = widget.buckets.length > 8 ? 6.0 : 14.0;
    final h =
        value == 0 ? 0.0 : math.max(3.0, value / maxValue * widget.height * t);
    return Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(width / 2)),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final ReportBucket bucket;

  const _Detail({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final net = bucket.income - bucket.expense;

    Widget row(String label, int amount, Color color) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
              Text(
                Formatters.rupiah(amount),
                style: AppTextStyles.label.copyWith(color: color),
              ),
            ],
          ),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bucket.label, style: AppTextStyles.label),
          const SizedBox(height: 6),
          row('Pemasukan', bucket.income, AppColors.income),
          row('Pengeluaran', bucket.expense, AppColors.expense),
          const Divider(height: 14),
          row(
            net >= 0 ? 'Surplus' : 'Defisit',
            net.abs(),
            net >= 0 ? AppColors.income : AppColors.expense,
          ),
        ],
      ),
    );
  }
}

/// Keterangan warna grafik; memakai teks agar tidak bergantung pada warna saja.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.caption),
          ],
        );

    return Wrap(
      spacing: 16,
      children: [
        item(AppColors.income, 'Pemasukan'),
        item(AppColors.expense, 'Pengeluaran'),
      ],
    );
  }
}
