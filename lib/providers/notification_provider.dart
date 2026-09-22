import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import 'progress_provider.dart';

/// アプリ全体で共有する [NotificationService] のインスタンス。
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// 通知トグルの操作をまとめるヘルパー。
///
/// 設定画面はこのクラスのメソッドを呼ぶだけでよく、
/// 権限リクエスト・スケジュール・永続化・失敗時のフォールバックを
/// すべてここに集約する。
class NotificationController {
  NotificationController(this._ref);

  final Ref _ref;

  NotificationService get _service => _ref.read(notificationServiceProvider);

  /// 通知を有効化する。権限が得られなかった場合は false を返し、
  /// 設定は有効化しない。
  Future<bool> enable() async {
    final granted = await _service.requestPermission();
    if (!granted) {
      return false;
    }
    await _service.scheduleDailyReminder();
    await _ref.read(progressProvider.notifier).setNotificationsEnabled(true);
    return true;
  }

  /// 通知を無効化する。
  Future<void> disable() async {
    await _service.cancelDailyReminder();
    await _ref.read(progressProvider.notifier).setNotificationsEnabled(false);
  }
}

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref);
});
