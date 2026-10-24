import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_schedule.dart';
import 'reminder_service.dart';

/// Pengingat nyata lewat notifikasi lokal Android.
///
/// Catatan perawatan: semua pemanggilan plugin `flutter_local_notifications`
/// ada di berkas ini. Jika versi plugin berubah dan nama parameter berbeda,
/// cukup sesuaikan di sini.
class LocalReminderService implements ReminderService {
  LocalReminderService();

  /// Proyek ini khusus Android.
  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static const int _baseId = 7000;
  static const String _channelId = 'daily_reminder';
  static const String _title = 'FinTrack';
  static const String _body =
      'Belum ada transaksi hari ini. Catat pengeluaranmu sebelum tidur.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  late final tz.Location _wib;
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    _wib = tz.getLocation('Asia/Jakarta');
    await _plugin.initialize(
      settings: const InitializationSettings(
        android:
            AndroidInitializationSettings('@drawable/ic_launcher_foreground'),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureReady();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<void> sync({
    required bool enabled,
    required bool hasTransactionToday,
  }) async {
    await _ensureReady();

    for (var i = 0; i < reminderWindowDays; i++) {
      await _plugin.cancel(id: _baseId + i);
    }
    if (!enabled) return;

    final now = tz.TZDateTime.now(_wib);
    final offsets = reminderDayOffsets(
      nowHour: now.hour,
      hasTransactionToday: hasTransactionToday,
    );

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Pengingat harian',
        channelDescription: 'Pengingat mencatat transaksi setiap malam',
      ),
    );

    for (final i in offsets) {
      final at =
          tz.TZDateTime(_wib, now.year, now.month, now.day + i, reminderHour);
      await _plugin.zonedSchedule(
        id: _baseId + i,
        title: _title,
        body: _body,
        scheduledDate: at,
        notificationDetails: details,
        // Tidak butuh izin alarm presisi; telat beberapa menit tidak masalah.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
