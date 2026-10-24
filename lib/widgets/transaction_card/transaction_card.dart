import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/dummy_data.dart';
import '../../models/transaction_model.dart';
import '../common/app_card.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String walletName;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.walletName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color = t.isIncome ? AppColors.income : AppColors.expense;
    final background =
        t.isIncome ? AppColors.incomeSoft : AppColors.expenseSoft;
    final icon =
        DummyData.categoryByName(t.category)?.icon ?? Icons.category_rounded;

    return Semantics(
      button: true,
      label:
          '${t.title}, ${t.isIncome ? 'pemasukan' : 'pengeluaran'} ${Formatters.rupiah(t.amount)}',
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${t.category} • $walletName • ${Formatters.time(t.date)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.rupiah(t.signedAmount, withSign: true),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      t.isIncome ? 'Pemasukan' : 'Pengeluaran',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
