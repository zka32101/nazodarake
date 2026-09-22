import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/providers/daily_challenge_provider.dart';
import 'package:nazodarake/providers/progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('デイリーチャレンジの日付ロジック', () {
    test('同じ日付を渡すと必ず同じ謎が選ばれる（決定的）', () {
      final date = DateTime(2026, 9, 21);
      final puzzle1 = dailyPuzzleForDate(date);
      final puzzle2 = dailyPuzzleForDate(date);
      expect(puzzle1.id, puzzle2.id);
    });

    test('異なる日付では別の謎が選ばれることがある', () {
      final puzzleA = dailyPuzzleForDate(DateTime(2026, 9, 21));
      final puzzleB = dailyPuzzleForDate(DateTime(2026, 9, 22));
      // 必ず異なるとは限らないが、少なくとも決定的に計算されている。
      expect(puzzleA, isNotNull);
      expect(puzzleB, isNotNull);
    });

    test('formatDateKey は yyyy-MM-dd 形式の文字列を返す', () {
      final key = formatDateKey(DateTime(2026, 1, 5));
      expect(key, '2026-01-05');
    });

    test('formatPreviousDateKey は前日の日付キーを返す', () {
      final key = formatPreviousDateKey(DateTime(2026, 9, 21));
      expect(key, '2026-09-20');
    });

    test('月をまたぐ場合も正しく前日を計算する', () {
      final key = formatPreviousDateKey(DateTime(2026, 3, 1));
      expect(key, '2026-02-28');
    });
  });

  group('デイリーチャレンジのストリーク記録', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('初めてクリアするとストリークが1になる', () async {
      await container
          .read(progressProvider.notifier)
          .recordDailyChallengeCleared('2026-09-21', '2026-09-20');
      expect(container.read(progressProvider).dailyStreak, 1);
    });

    test('前日にもクリアしていれば連続日数が加算される', () async {
      final notifier = container.read(progressProvider.notifier);
      await notifier.recordDailyChallengeCleared('2026-09-20', '2026-09-19');
      await notifier.recordDailyChallengeCleared('2026-09-21', '2026-09-20');
      expect(container.read(progressProvider).dailyStreak, 2);
    });

    test('前日にクリアしていなければストリークは1にリセットされる', () async {
      final notifier = container.read(progressProvider.notifier);
      await notifier.recordDailyChallengeCleared('2026-09-15', '2026-09-14');
      // 1日飛ばして挑戦。
      await notifier.recordDailyChallengeCleared('2026-09-21', '2026-09-20');
      expect(container.read(progressProvider).dailyStreak, 1);
    });

    test('同じ日に2回記録しても重複加算されない', () async {
      final notifier = container.read(progressProvider.notifier);
      await notifier.recordDailyChallengeCleared('2026-09-21', '2026-09-20');
      await notifier.recordDailyChallengeCleared('2026-09-21', '2026-09-20');
      expect(container.read(progressProvider).dailyStreak, 1);
      expect(container.read(progressProvider).clearedDailyDates.length, 1);
    });
  });
}
