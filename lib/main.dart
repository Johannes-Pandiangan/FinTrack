import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/finance_repository.dart';
import 'data/repositories/firestore_finance_repository.dart';
import 'providers/app_state.dart';
import 'services/auth_service.dart';
import 'services/finai_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/local_reminder_service.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    // Jika penyimpanan gagal, aplikasi tetap jalan tanpa penyimpanan lokal.
  }

  final localFinance = LocalFinanceRepository(prefs);
  AuthService? authService;
  FinanceRepository financeRepository = localFinance;

  try {
    await Firebase.initializeApp();
    authService = FirebaseAuthService();
    financeRepository = FirestoreFinanceRepository(
      localFallback: localFinance,
    );
  } catch (e) {
    // Jika google-services.json belum dipasang, aplikasi tetap bisa dijalankan
    // menggunakan mode lokal tanpa crash.
    debugPrint('Info: Firebase belum terkonfigurasi, memakai mode lokal ($e)');
  }

  final appState = AppState(
    prefs: prefs,
    auth: authService,
    finance: financeRepository,
    reminder: LocalReminderService.isSupported
        ? LocalReminderService()
        : const NoopReminderService(),
  );
  await appState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        Provider<FinAIService>(create: (_) => const RuleBasedFinAIService()),
      ],
      child: const FinTrackApp(),
    ),
  );
}
