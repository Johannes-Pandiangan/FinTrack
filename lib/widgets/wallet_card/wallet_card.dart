import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_model.dart';
import '../common/app_card.dart';

/// Kartu dompet untuk daftar horizontal di Beranda.
class WalletCard extends StatelessWidget {
  final WalletModel? wallet;
  final VoidCallback? onTap;

  /// Jika [wallet] null, kartu tampil sebagai tombol "Tambah".
  const WalletCard({super.key, this.wallet, this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = wallet;
    return SizedBox(
      width: 156,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: w == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 30, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text('Tambah', style: AppTextStyles.link),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Icon(w.type.icon, size: 20, color: AppColors.primary),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Formatters.rupiah(w.balance),
                          style: AppTextStyles.h3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// Baris dompet untuk halaman Dompet & Rekening.
class WalletTile extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WalletTile({
    super.key,
    required this.wallet,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(wallet.type.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 2),
                Text(wallet.type.label, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatters.rupiah(wallet.balance),
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              tooltip: 'Menu dompet',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) =>
                  v == 'edit' ? onEdit?.call() : onDelete?.call(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Ubah')),
                PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
        ],
      ),
    );
  }
}
