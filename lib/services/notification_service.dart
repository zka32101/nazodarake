import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// デイリーチャレンジ未挑戦リマインダー通知のID。
const int dailyReminderNotificationId = 1001;

/// ローカル通知（デイリーチャレンジ未挑戦リマインダー）を扱うサービス。
///
/// 通知権限のリクエスト・スケジュール処理は実機/エミュレータでの動作確認が
/// できない前提のため、あらゆる操作を `try-catch` で保護し、失敗しても
/// アプリの他機能に影響が出ないように設計している。
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// プラグインの初期化とタイムゾーンデータのロードを行う。
  /// 複数回呼び出しても安全（2回目以降は何もしない）。
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('NotificationService: failed to initialize: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// 通知権限をリクエストする（iOS/Android 13+ 向け）。
  /// 権限が得られたかどうかを返す（取得できない/失敗時は false）。
  Future<bool> requestPermission() async {
    try {
      await initialize();
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted =
          await androidImpl?.requestNotificationsPermission();
      // どちらのプラットフォームでもない場合（テスト環境等）は true 扱いにしない。
      return (iosGranted ?? false) || (androidGranted ?? false);
    } catch (error, stackTrace) {
      debugPrint('NotificationService: failed to request permission: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// 毎日指定した時刻（デフォルト 20:00）に、デイリーチャレンジ未挑戦の
  /// リマインダー通知をスケジュールする。
  Future<void> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    try {
      await initialize();
      final scheduledDate = _nextInstanceOfTime(hour, minute);
      await _plugin.zonedSchedule(
        dailyReminderNotificationId,
        'なぞだらけ',
        '今日のデイリーチャレンジにまだ挑戦していません！ナゾウが待っています。',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_challenge_reminder',
            'デイリーチャレンジリマインダー',
            channelDescription: 'デイリーチャレンジ未挑戦の際に通知します',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error, stackTrace) {
      debugPrint('NotificationService: failed to schedule reminder: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// スケジュール済みのリマインダー通知をキャンセルする。
  Future<void> cancelDailyReminder() async {
    try {
      await initialize();
      await _plugin.cancel(dailyReminderNotificationId);
    } catch (error, stackTrace) {
      debugPrint('NotificationService: failed to cancel reminder: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// 指定した日付（'yyyy-MM-dd'）時点で、デイリーチャレンジ未挑戦かどうかを
/// 判定する純粋関数（通知を出すべきかの判定ロジックをテスト可能にするため
/// UI/プラグイン呼び出しから分離している）。
bool shouldRemindDailyChallenge({
  required String today,
  required String? lastDailyCompletedDate,
}) {
  return lastDailyCompletedDate != today;
}
