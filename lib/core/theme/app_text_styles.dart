import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gaya teks. Yang memakai warna tema berupa getter agar ikut berganti
/// antara tema terang dan gelap.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get h1 => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.25,
      );
  static TextStyle get h2 => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
  static TextStyle get h3 => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
  static TextStyle get body => TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.4,
      );
  static TextStyle get bodySecondary => TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.45,
      );
  static TextStyle get label => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
  static TextStyle get caption => TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      );
  static TextStyle get overline => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      );
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get link => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
}
