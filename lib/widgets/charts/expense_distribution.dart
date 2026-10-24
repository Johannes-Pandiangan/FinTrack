import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

class ExpenseDistribution extends StatelessWidget {
  final Map<String, int> totals;

  const ExpenseDistribution({super.key, required this.totals});

  static List<Color> get _palette => [
        AppColors.primary,
        AppColors.purple,
        AppColors.orange,
        AppColors.yellow,
        AppColors.expense,
        const Color(0xFF3B82A0),
      ];

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sum = entries.fold<int>(0, (s, e) => s + e.value);

    if (sum == 0) {
      return Text(
        'Belum ada pengeluaran pada periode ini.',
        style: AppTextStyles.bodySecondary,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (var i = 0; i < entries.length; i++)
                  Expanded(
                    flex:
                        (entries[i].value * 1000 ~/ sum).clamp(1, 1000).toInt(),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: i == entries.length - 1 ? 0 : 2,
                      ),
                      color: _palette[i % _palette.length],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entries[i].key,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(entries[i].value * 100 / sum).round()}%',
                      style: AppTextStyles.label,
                    ),
                    Text(
                      Formatters.rupiah(entries[i].value),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
