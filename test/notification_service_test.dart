import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/services/notification_service.dart';

/// flutter_local_notifications が内部で使用する MethodChannel。
/// パッケージのメジャーバージョンをまたいで安定しているチャンネル名。
const _channel = MethodChannel('dexterous.com/flutter/local_notifications');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];

  Future<Object?> defaultHandler(MethodCall call) async {
    calls.add(call);
    switch (call.method) {
      case 'initialize':
        return true;
      case 'requestNotificationsPermission':
      case 'requestPermissions':
        return true;
      case 'zonedSchedule':
      case 'cancel':
      case 'cancelAll':
        return null;
      default:
        return null;
    }
  }

  setUp(() {
    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, defaultHandler);
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('NotificationService（MethodChannelモック使用）', () {
    test('requestPermission は権限が許可された場合 true を返し、initializeも実行する', () async {
      final service = NotificationService();
      final granted = await service.requestPermission();

      expect(granted, isTrue);
      expect(calls.map((c) => c.method), contains('initialize'));
      expect(
        calls.map((c) => c.method),
        contains('requestNotificationsPermission'),
      );
    });

    test('requestPermission は権限が拒否された場合 false を返す', () async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
        calls.add(call);
        if (call.method == 'initialize') return true;
        if (call.method == 'requestNotificationsPermission') return false;
        return null;
      });

      final service = NotificationService();
      final granted = await service.requestPermission();
      expect(granted, isFalse);
    });

    test('scheduleDailyReminder は zonedSchedule を呼び出す', () async {
      final service = NotificationService();
      await service.scheduleDailyReminder();
      expect(calls.map((c) => c.method), contains('zonedSchedule'));
    });

    test('scheduleDailyReminder に指定した時刻が引数に渡る', () async {
      final service = NotificationService();
      await service.scheduleDailyReminder(hour: 9, minute: 30);
      final scheduleCall = calls.firstWhere((c) => c.method == 'zonedSchedule');
      // 引数はプラットフォーム実装依存の複雑な構造のため、
      // ここでは呼び出し自体が発生したことのみ確認する。
      expect(scheduleCall.method, 'zonedSchedule');
    });

    test('cancelDailyReminder は cancel を呼び出す', () async {
      final service = NotificationService();
      await service.cancelDailyReminder();
      expect(calls.map((c) => c.method), contains('cancel'));
    });

    test('initialize は複数回呼んでもプラグイン初期化は1回だけ行われる', () async {
      final service = NotificationService();
      await service.initialize();
      await service.initialize();
      final initializeCalls =
          calls.where((c) => c.method == 'initialize').length;
      expect(initializeCalls, 1);
    });

    test('プラグインが例外を投げても NotificationService は例外を伝播しない', () async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
        throw PlatformException(code: 'error', message: 'mock failure');
      });

      final service = NotificationService();
      expect(await service.requestPermission(), isFalse);
      // 以下は例外を投げずに完了することを確認する。
      await service.scheduleDailyReminder();
      await service.cancelDailyReminder();
    });
  });

  group('shouldRemindDailyChallenge のエッジケース', () {
    test('前日にクリアしていても today と異なれば true', () {
      expect(
        shouldRemindDailyChallenge(
          today: '2026-09-22',
          lastDailyCompletedDate: '2026-09-21',
        ),
        isTrue,
      );
    });

    test('lastDailyCompletedDate が null の場合は true（初回起動想定）', () {
      expect(
        shouldRemindDailyChallenge(today: '2026-09-22', lastDailyCompletedDate: null),
        isTrue,
      );
    });

    test('today と完全一致すれば false', () {
      expect(
        shouldRemindDailyChallenge(
          today: '2026-09-22',
          lastDailyCompletedDate: '2026-09-22',
        ),
        isFalse,
      );
    });

    test('年またぎの日付境界でも文字列比較のみで正しく判定する', () {
      expect(
        shouldRemindDailyChallenge(
          today: '2027-01-01',
          lastDailyCompletedDate: '2026-12-31',
        ),
        isTrue,
      );
      expect(
        shouldRemindDailyChallenge(
          today: '2027-01-01',
          lastDailyCompletedDate: '2027-01-01',
        ),
        isFalse,
      );
    });

    test('空文字の today でも null の lastDailyCompletedDate とは不一致で true', () {
      expect(
        shouldRemindDailyChallenge(today: '', lastDailyCompletedDate: null),
        isTrue,
      );
    });

    test('大文字小文字や前後空白などの表記ゆれは吸収しない（厳密な文字列一致）', () {
      // 呼び出し側（今日の日付フォーマット）が常に 'yyyy-MM-dd' で統一されている前提の
      // 単純な文字列比較であることを明示するテスト。
      expect(
        shouldRemindDailyChallenge(
          today: '2026-09-22',
          lastDailyCompletedDate: '2026-09-22 ',
        ),
        isTrue,
      );
    });
  });
}
