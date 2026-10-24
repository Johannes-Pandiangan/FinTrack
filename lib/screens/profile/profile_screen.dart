import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/menu_tile.dart';
import '../../widgets/sheets/daily_limit_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Keluar dari Akun',
      message: 'Apakah Anda yakin ingin keluar dari akun FinTrack?',
      confirmLabel: 'Keluar',
      destructive: true,
    );
    if (!confirmed) return;
    state.logout();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  Future<void> _toggleReminder(BuildContext context, bool value) async {
    final ok = await context.read<AppState>().setReminder(value);
    if (!ok && context.mounted) {
      AppSnackbar.error(
        context,
        'Izin notifikasi ditolak. Aktifkan lewat Pengaturan HP > Aplikasi > FinTrack > Notifikasi.',
      );
    }
  }

  Future<void> _pickTheme(BuildContext context) {
    final state = context.read<AppState>();
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        Widget option(String label, IconData icon, bool dark) {
          final selected = state.darkMode == dark;
          return ListTile(
            leading: Icon(icon, color: AppColors.primary),
            title:
                Text(label, style: AppTextStyles.label.copyWith(fontSize: 15)),
            trailing: selected
                ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                : null,
            onTap: () {
              state.setDarkMode(dark);
              Navigator.pop(ctx);
            },
          );
        }

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Tema', style: AppTextStyles.h3),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option('Terang', Icons.light_mode_outlined, false),
              option('Gelap', Icons.dark_mode_outlined, true),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editName(BuildContext context, String current) async {
    final state = context.read<AppState>();
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initial: current),
    );
    if (newName == null || !context.mounted) return;
    if (state.updateName(newName)) {
      AppSnackbar.success(context, 'Nama berhasil diperbarui');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final name = user?.name ?? 'Pengguna';
    final limit = state.dailyLimit;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24 + AppConstants.fabClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(showNotification: true),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.lightGreen,
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style:
                            AppTextStyles.h1.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.h2),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ubah nama',
                      onPressed:
                          user == null ? null : () => _editName(context, name),
                      icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Stat(
                        value: '${state.transactions.length}',
                        label: 'Transaksi'),
                    _Stat(
                        value: '${state.wallets.length}',
                        label: 'Dompet Aktif'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _Section('MANAJEMEN FINANSIAL'),
          MenuTile(
            icon: Icons.file_download_outlined,
            title: 'Ekspor Data Finansial',
            subtitle: 'Laporan instan format CSV & PDF',
            onTap: () => Navigator.pushNamed(context, AppRoutes.export),
          ),
          const SizedBox(height: 10),
          MenuTile(
            icon: Icons.alarm_rounded,
            title: 'Pengingat Pencatatan',
            subtitle: 'Pengingat pintar jam 20:00 WIB',
            trailing: Switch(
              value: state.reminderEnabled,
              onChanged: (value) => _toggleReminder(context, value),
            ),
            onTap: () => _toggleReminder(context, !state.reminderEnabled),
          ),
          const SizedBox(height: 10),
          MenuTile(
            icon: Icons.speed_rounded,
            title: 'Batas Pengeluaran Harian',
            subtitle: limit == null ? 'Belum diatur' : Formatters.rupiah(limit),
            onTap: () => showDailyLimitDialog(context),
          ),
          const SizedBox(height: 20),
          const _Section('TAMPILAN'),
          MenuTile(
            icon: Icons.palette_outlined,
            title: 'Tema',
            subtitle: state.darkMode ? 'Gelap' : 'Terang',
            onTap: () => _pickTheme(context),
          ),
          const SizedBox(height: 20),
          const _Section('KEAMANAN & AKUN'),
          MenuTile(
            icon: Icons.lock_outline_rounded,
            title: 'Ubah PIN & Kata Sandi',
            onTap: () => Navigator.pushNamed(context, AppRoutes.security),
          ),
          const SizedBox(height: 20),
          const _Section('DUKUNGAN & INFORMASI'),
          MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Pusat Bantuan & FAQ',
            onTap: () => Navigator.pushNamed(context, AppRoutes.help),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label:
                  const Text('Keluar dari Akun', style: AppTextStyles.button),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.expenseSoft,
                foregroundColor: AppColors.expense,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;

  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(text, style: AppTextStyles.overline),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String initial;

  const _EditNameDialog({required this.initial});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama tidak boleh kosong');
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Ubah Nama', style: AppTextStyles.h3),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          hintText: 'Nama lengkap',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
