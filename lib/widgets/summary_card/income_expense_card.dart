import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../common/app_card.dart';

class IncomeExpenseCard extends StatelessWidget {
  final String label;
  final int amount;
  final IconData icon;
  final Color color;
  final Color background;

  const IncomeExpenseCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.rupiah(amount),
              style: AppTextStyles.h3.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
