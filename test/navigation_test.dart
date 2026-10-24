import 'package:fintrack/app.dart';
import 'package:fintrack/providers/app_state.dart';
import 'package:fintrack/routes/app_routes.dart';
import 'package:fintrack/screens/common/not_found_screen.dart';
import 'package:fintrack/data/dummy_data.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/services/finai_service.dart';
import 'package:fintrack/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'ikon profil di Beranda membuka tab Profil, bukan "Halaman Belum Tersedia"',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      final state = AppState(
        prefs: await SharedPreferences.getInstance(),
        auth: InMemoryAuthService(latency: Duration.zero),
        reminder: const NoopReminderService(),
      );
      await state.init();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: state),
            Provider<FinAIService>(
              create: (_) =>
                  const RuleBasedFinAIService(latency: Duration.zero),
            ),
          ],
          child: const FinTrackApp(),
        ),
      );

      // Splash menunggu 3 detik lalu pindah ke halaman masuk.
      await tester.pump(const Duration(milliseconds: 3100));
      await tester.pump(const Duration(milliseconds: 400));

      // Masuk seperti yang dilakukan layar login.
      await state.login(DummyData.demoEmail, DummyData.demoPassword);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushReplacementNamed(AppRoutes.home);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.byTooltip('Profil').first);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(NotFoundScreen), findsNothing);
      expect(state.tabIndex, 3);
    },
  );
}
