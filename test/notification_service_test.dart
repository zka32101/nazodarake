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
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, defaultHandler);
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  // NOTE: flutter_local_notifications はプラットフォーム別の実装
  // （FlutterLocalNotificationsPlatform.instance）の登録を前提としており、
  // これは実機/エミュレータ上でプラグインが自動登録されて初めて有効になる。
  // 素の `flutter test` 環境（本ユニットテスト）ではこの登録が行われないため、
  // MethodChannel をモックしていても `resolvePlatformSpecificImplementation`
  // 経由の呼び出し（initialize/requestPermission）は内部で例外となる。
  // NotificationService はこれをすべて try-catch で保護している設計なので、
  // ここでは「例外が外部に伝播せず、安全側の既定値（false / 何もしない）に
  // フォールバックすること」をテストする。これは実機での動作確認ができない
  // 前提で書かれた本サービスの設計方針そのものを検証するテストである。
  group('NotificationService（プラグイン未登録環境での安全側フォールバック）', () {
    test('requestPermission はプラグイン未登録環境で例外を伝播せず false を返す', () async {
      final service = NotificationService();
      final granted = await service.requestPermission();
      expect(granted, isFalse);
    });

    test('scheduleDailyReminder は例外を投げずに完了する', () async {
      final service = NotificationService();
      await service.scheduleDailyReminder();
      // 例外を投げずにここまで到達すれば成功。
    });

    test('scheduleDailyReminder はカスタム時刻を渡しても例外を投げずに完了する', () async {
      final service = NotificationService();
      await service.scheduleDailyReminder(hour: 9, minute: 30);
    });

    test('cancelDailyReminder は例外を投げずに完了する', () async {
      final service = NotificationService();
      await service.cancelDailyReminder();
    });

    test('initialize は複数回呼んでも例外を投げずに完了する（冪等）', () async {
      final service = NotificationService();
      await service.initialize();
      await service.initialize();
    });

    test('MethodChannel がエラーを返す場合でも NotificationService は例外を伝播しない', () async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
        throw PlatformException(code: 'error', message: 'mock failure');
      });

      final service = NotificationService();
      expect(await service.requestPermission(), isFalse);
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

    test('末尾の空白があるだけでも厳密な文字列一致では不一致になる', () {
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
