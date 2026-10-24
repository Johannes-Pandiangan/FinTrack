import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

/// Memformat angka dengan pemisah ribuan saat mengetik (12000 -> 12.000).
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    if (digits.length > 12) digits = digits.substring(0, 12);
    final text = Formatters.grouped(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final String? errorText;
  final ValueChanged<int> onQuickAdd;
  final VoidCallback onChanged;

  const AmountInput({
    super.key,
    required this.controller,
    required this.color,
    required this.onQuickAdd,
    required this.onChanged,
    this.errorText,
  });

  static const Map<String, int> _quick = {
    '+20rb': 20000,
    '+50rb': 50000,
    '+100rb': 100000,
    '+500rb': 500000,
    '+1jt': 1000000,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NOMINAL TRANSAKSI', style: AppTextStyles.overline),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText == null ? AppColors.border : AppColors.expense,
              width: errorText == null ? 1 : 1.6,
            ),
          ),
          child: Row(
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsFormatter()],
                  onChanged: (_) => onChanged(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: AppColors.expense),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText!,
                    style: TextStyle(fontSize: 12, color: AppColors.expense),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in _quick.entries)
              ActionChip(
                label: Text(e.key),
                onPressed: () => onQuickAdd(e.value),
                backgroundColor: AppColors.lightGreen,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
