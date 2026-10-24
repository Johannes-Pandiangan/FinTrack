import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../common/fintrack_logo.dart';
import '../common/notification_sheet.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;
  final bool showNotification;
  final String? overline;
  final String? title;
  final Widget? menu;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    this.showBack = false,
    this.showNotification = false,
    this.overline,
    this.title,
    this.menu,
    this.onBack,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          IconButton(
            tooltip: 'Kembali',
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          )
        else
          const SizedBox(width: 4),
        const FinTrackLogo(size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: title == null
              ? Text(
                  AppConstants.appName,
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (overline != null)
                      Text(
                        overline!,
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      title!,
                      style: AppTextStyles.h2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
        if (showNotification)
          _NotificationButton(
            onTap: onNotificationTap ?? () => showNotificationSheet(context),
          ),
        if (menu != null) menu!,
        IconButton(
          tooltip: 'Profil',
          onPressed: onProfileTap ?? () => AppRoutes.goToTab(context, 3),
          icon: const Icon(Icons.account_circle_outlined, size: 28),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<AppState, int>((s) => s.unreadNotifications);

    return Stack(
      children: [
        IconButton(
          tooltip:
              unread > 0 ? 'Notifikasi ($unread belum dibaca)' : 'Notifikasi',
          onPressed: onTap,
          icon: const Icon(Icons.notifications_none_rounded, size: 26),
        ),
        if (unread > 0)
          Positioned(
            right: 8,
            top: 8,
            child: IgnorePointer(
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.expense,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
