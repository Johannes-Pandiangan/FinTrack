import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/app_state.dart';
import 'services/finai_service.dart';
import 'services/local_reminder_service.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    // Jika penyimpanan gagal, aplikasi tetap jalan tanpa penyimpanan.
  }

  final appState = AppState(
    prefs: prefs,
    reminder: LocalReminderService.isSupported
        ? LocalReminderService()
        : const NoopReminderService(),
  );
  await appState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        // Ganti dengan implementasi AI sungguhan saat backend siap.
        Provider<FinAIService>(create: (_) => const RuleBasedFinAIService()),
      ],
      child: const FinTrackApp(),
    ),
  );
}
