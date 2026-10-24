import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: 'Catat transaksi',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
    );
  }
}
