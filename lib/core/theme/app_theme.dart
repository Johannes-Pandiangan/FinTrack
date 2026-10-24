import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Tema yang sesuai dengan [AppColors.dark] saat ini.
  static ThemeData get current => _build(
        AppColors.dark ? Brightness.dark : Brightness.light,
      );

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B5D3B),
      primary: AppColors.primary,
      onPrimary: Colors.white,
      error: AppColors.expense,
      surface: AppColors.surface,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Color(0xFF9AA5A0), fontSize: 14),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, 1.6),
        errorBorder: _border(AppColors.expense),
        focusedErrorBorder: _border(AppColors.expense, 1.6),
      ),
      dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }
}
