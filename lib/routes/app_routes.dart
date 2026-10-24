import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../screens/add_transaction/add_transaction_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/export/export_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/security/change_password_screen.dart';
import '../screens/security/pin_lock_screen.dart';
import '../screens/security/security_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/common/not_found_screen.dart';
import '../screens/edit_transaction/edit_transaction_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/transaction_detail/transaction_detail_screen.dart';
import '../screens/wallets/wallets_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String addTransaction = '/add-transaction';
  static const String transactionDetail = '/transaction-detail';
  static const String editTransaction = '/edit-transaction';
  static const String reports = '/reports';
  static const String finai = '/finai';
  static const String profile = '/profile';
  static const String wallets = '/wallets';
  static const String export = '/export';
  static const String security = '/security';
  static const String changePassword = '/change-password';
  static const String pinLock = '/pin-lock';
  static const String help = '/help';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(settings, (_) => const SplashScreen());
      case login:
        return _fade(settings, (_) => const LoginScreen());
      case register:
        return _fade(settings, (_) => const RegisterScreen());
      case home:
        return _fade(settings, (_) => const MainShell(initialTab: 0));
      case transactions:
        return _fade(settings, (_) => const MainShell(initialTab: 1));
      case finai:
        return _fade(settings, (_) => const MainShell(initialTab: 2));
      case profile:
        return _fade(settings, (_) => const MainShell(initialTab: 3));
      case addTransaction:
        return _fade(settings, (_) => const AddTransactionScreen());
      case transactionDetail:
        return _fade(settings, (_) => const TransactionDetailScreen());
      case editTransaction:
        return _fade(settings, (_) => const EditTransactionScreen());
      case reports:
        return _fade(settings, (_) => const ReportsScreen());
      case wallets:
        return _fade(settings, (_) => const WalletsScreen());
      case export:
        return _fade(settings, (_) => const ExportScreen());
      case security:
        return _fade(settings, (_) => const SecurityScreen());
      case changePassword:
        return _fade(settings, (_) => const ChangePasswordScreen());
      case help:
        return _fade(settings, (_) => const HelpScreen());
      case pinLock:
        final fromLogin = settings.arguments == true;
        return _fade(settings, (_) => PinLockScreen(fromLogin: fromLogin));
      default:
        return _fade(settings, (_) => const NotFoundScreen());
    }
  }

  /// Kembali ke halaman utama lalu membuka tab tertentu
  /// (0 Beranda, 1 Transaksi, 2 FinAI, 3 Profil).
  static void goToTab(BuildContext context, int index) {
    context.read<AppState>().setTab(index);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Memilih transaksi lalu membuka halaman detailnya.
  static void openTransaction(BuildContext context, String id) {
    context.read<AppState>().selectTransaction(id);
    Navigator.pushNamed(context, transactionDetail);
  }

  static PageRoute<dynamic> _fade(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
