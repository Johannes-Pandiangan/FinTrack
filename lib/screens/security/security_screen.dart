import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/menu_tile.dart';
import 'pin_sheet.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(showBack: true),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                children: [
                  Text('Keamanan & Akun', style: AppTextStyles.h1),
                  const SizedBox(height: 6),
                  Text(
                    'Kunci PIN diminta setelah login dan saat kembali ke aplikasi setelah 30 detik.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 16),
                  MenuTile(
                    icon: Icons.pin_outlined,
                    title: 'Kunci PIN',
                    subtitle: state.hasPin ? 'Aktif' : 'Tidak aktif',
                    trailing: Switch(
                      value: state.hasPin,
                      onChanged: (v) => showPinSheet(
                        context,
                        v ? PinMode.set : PinMode.remove,
                      ),
                    ),
                    onTap: () => showPinSheet(
                      context,
                      state.hasPin ? PinMode.remove : PinMode.set,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (state.hasPin) ...[
                    MenuTile(
                      icon: Icons.edit_rounded,
                      title: 'Ubah PIN',
                      onTap: () => showPinSheet(context, PinMode.change),
                    ),
                    const SizedBox(height: 10),
                  ],
                  MenuTile(
                    icon: Icons.password_rounded,
                    title: 'Ubah Kata Sandi',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.changePassword),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
