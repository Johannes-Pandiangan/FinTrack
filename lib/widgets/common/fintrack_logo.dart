import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Logo FinTrack dari asset.
/// [showName] true memakai logo lengkap dengan tulisan, false memakai ikon saja.
/// Jika file asset belum ada, otomatis tampil ikon cadangan.
class FinTrackLogo extends StatelessWidget {
  final double size;
  final bool onDark;
  final bool showName;

  const FinTrackLogo({
    super.key,
    this.size = 64,
    this.onDark = false,
    this.showName = false,
  });

  @override
  Widget build(BuildContext context) {
    final asset =
        showName ? AppConstants.logoAsset : AppConstants.logoIconAsset;

    return Semantics(
      label: 'Logo FinTrack',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.savings_rounded,
              size: size * 0.55,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
