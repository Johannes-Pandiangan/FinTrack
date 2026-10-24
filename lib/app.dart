import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'routes/app_routes.dart';

class FinTrackApp extends StatefulWidget {
  const FinTrackApp({super.key});

  @override
  State<FinTrackApp> createState() => _FinTrackAppState();
}

class _FinTrackAppState extends State<FinTrackApp> {
  bool? _lastDark;

  /// Warna dibaca dari [AppColors], bukan dari Theme, sehingga saat tema
  /// berganti seluruh widget perlu dibangun ulang (halaman yang sedang terbuka
  /// tidak ikut tertutup).
  void _rebuildAll() {
    if (!mounted) return;
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.select<AppState, bool>((s) => s.darkMode);
    AppColors.dark = dark;

    if (_lastDark != null && _lastDark != dark) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildAll());
    }
    _lastDark = dark;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: AppRoutes.splash,
      // Hanya buat halaman awal. Tanpa ini Flutter juga membuat rute '/' yang
      // jatuh ke NotFoundScreen dan menjadi dasar tumpukan halaman, sehingga
      // popUntil(isFirst) (mis. tombol profil) berakhir di "Halaman Belum
      // Tersedia".
      onGenerateInitialRoutes: (initialRoute) => [
        AppRoutes.onGenerateRoute(RouteSettings(name: initialRoute)),
      ],
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
