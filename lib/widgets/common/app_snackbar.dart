import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Snackbar dengan ikon + teks agar makna tidak hanya bergantung pada warna.
class AppSnackbar {
  AppSnackbar._();

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) => _show(
        context,
        message,
        Icons.check_circle_rounded,
        AppColors.primary,
      );

  static void error(BuildContext context, String message) => _show(
        context,
        message,
        Icons.error_rounded,
        AppColors.expense,
      );

  static void info(BuildContext context, String message) => _show(
        context,
        message,
        Icons.info_rounded,
        const Color(0xFF3B4A44),
      );
}
