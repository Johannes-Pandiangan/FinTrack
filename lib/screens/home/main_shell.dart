import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_clock.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/bottom_navigation/app_bottom_nav.dart';
import '../../widgets/bottom_navigation/floating_add_button.dart';
import '../finai/finai_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/transactions_screen.dart';
import 'home_screen.dart';

/// Kerangka halaman utama dengan bottom navigation dan tombol "+".
class MainShell extends StatefulWidget {
  final int initialTab;

  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  static const int _lockAfterSeconds = 30;
  DateTime? _pausedAt;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = AppClock.now();
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) unawaited(context.read<AppState>().refreshReminder());
      final paused = _pausedAt;
      _pausedAt = null;
      if (paused != null &&
          AppClock.now().difference(paused).inSeconds >= _lockAfterSeconds &&
          mounted &&
          context.read<AppState>().hasPin) {
        Navigator.pushNamed(context, AppRoutes.pinLock, arguments: false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = context.read<AppState>();
      appState.setTab(widget.initialTab);
      unawaited(appState.setupReminder());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tab = context.select<AppState, int>((s) => s.tabIndex);
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // Tombol Kembali di tab selain Beranda membawa ke Beranda dulu.
    return PopScope(
      canPop: tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.read<AppState>().setTab(0);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab,
            sizing: StackFit.expand,
            children: const [
              HomeScreen(),
              TransactionsScreen(),
              FinAIScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: keyboardOpen
            ? null
            : FloatingAddButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.addTransaction),
              ),
        bottomNavigationBar: keyboardOpen
            ? null
            : AppBottomNav(
                currentIndex: tab,
                onTap: (i) => context.read<AppState>().setTab(i),
              ),
      ),
    );
  }
}
