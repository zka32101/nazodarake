import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/providers/progress_provider.dart';
import 'package:nazodarake/services/notification_service.dart';

void main() {
  group('ProgressState onboarding/notifications フラグ', () {
    test('初期状態ではオンボーディング未表示・通知OFF', () {
      const state = ProgressState();
      expect(state.hasSeenOnboarding, isFalse);
      expect(state.notificationsEnabled, isFalse);
    });

    test('copyWith でオンボーディング表示済みにできる', () {
      const state = ProgressState();
      final updated = state.copyWith(hasSeenOnboarding: true);
      expect(updated.hasSeenOnboarding, isTrue);
    });

    test('toJson/fromJson で連動謎・オンボーディング・通知設定が復元される', () {
      const state = ProgressState(
        clearedLinkedFragmentIds: {'linked_s12_01'},
        clearedLinkedSetIds: {'linked_s12'},
        hasSeenOnboarding: true,
        notificationsEnabled: true,
      );
      final restored = ProgressState.fromJson(state.toJson());
      expect(restored.clearedLinkedFragmentIds, {'linked_s12_01'});
      expect(restored.clearedLinkedSetIds, {'linked_s12'});
      expect(restored.hasSeenOnboarding, isTrue);
      expect(restored.notificationsEnabled, isTrue);
    });

    test('fromJson は欠損フィールドをデフォルト値で補完する（後方互換性）', () {
      final restored = ProgressState.fromJson(const {
        'clearedPuzzleIds': ['s1_01'],
      });
      expect(restored.hasSeenOnboarding, isFalse);
      expect(restored.notificationsEnabled, isFalse);
      expect(restored.clearedLinkedFragmentIds, isEmpty);
      expect(restored.clearedLinkedSetIds, isEmpty);
    });
  });

  group('shouldRemindDailyChallenge', () {
    test('今日まだ挑戦していない場合は true', () {
      expect(
        shouldRemindDailyChallenge(
          today: '2026-09-22',
          lastDailyCompletedDate: '2026-09-21',
        ),
        isTrue,
      );
    });

    test('lastDailyCompletedDate が null の場合も true', () {
      expect(
        shouldRemindDailyChallenge(
          today: '2026-09-22',
          lastDailyCompletedDate: null,
        ),
        isTrue,
      );
    });

    test('今日すでに挑戦済みの場合は false', () {
      expect(
        shouldRemindDailyChallenge(
          today: '2026-09-22',
          lastDailyCompletedDate: '2026-09-22',
        ),
        isFalse,
      );
    });
  });
}
