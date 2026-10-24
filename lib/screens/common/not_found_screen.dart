import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../widgets/common/empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.construction_rounded,
          title: 'Halaman Belum Tersedia',
          message: 'Halaman ini belum dibuat atau tidak ditemukan.',
          buttonLabel: 'Kembali ke Beranda',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          ),
        ),
      ),
    );
  }
}
