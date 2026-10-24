import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Gelembung pesan dari FinAI. [details] opsional untuk kartu analisis.
class FinAIMessageBubble extends StatelessWidget {
  final String text;
  final String? title;
  final List<MapEntry<String, String>> details;

  const FinAIMessageBubble({
    super.key,
    required this.text,
    this.title,
    this.details = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 16, color: AppColors.primary),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 18, color: AppColors.income),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              title!,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.income,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    for (final d in details)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(d.key,
                                  style: AppTextStyles.bodySecondary),
                            ),
                            const SizedBox(width: 8),
                            Text(d.value, style: AppTextStyles.label),
                          ],
                        ),
                      ),
                    if (details.isNotEmpty) const SizedBox(height: 4),
                    Text(text, style: AppTextStyles.body),
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
