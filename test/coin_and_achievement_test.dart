import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/models/achievement_model.dart';
import 'package:nazodarake/models/puzzle_model.dart';
import 'package:nazodarake/providers/game_provider.dart';
import 'package:nazodarake/providers/progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _puzzle1 = Puzzle(
  id: 'coin_test_1',
  stage: 1,
  genre: PuzzleGenre.riddle,
  question: 'テスト問題1',
  answer: 'こたえ',
  hints: ['ヒント1', 'ヒント2', 'ヒント3'],
  difficulty: PuzzleDifficulty.easy,
);

/// audioplayers はテスト環境（プラットフォームチャンネル未実装）で
/// MissingPluginException を送出するため、正誤判定時に呼ばれる
/// SoundService からの呼び出しがテスト失敗の原因にならないよう
/// 関連チャンネルをモックしておく。
void _mockAudioplayersChannels() {
  const globalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const playerChannel = MethodChannel('xyz.luan/audioplayers');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(globalChannel, (MethodCall call) async {
    return null;
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(playerChannel, (MethodCall call) async {
    return null;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _mockAudioplayersChannels();

  group('コインシステム', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('謎をクリアするとコインが加算される', () async {
      container.read(gameProvider.notifier).startPuzzle(_puzzle1);
      container.read(gameProvider.notifier).submitAnswer('こたえ');
      // markCleared は非同期の永続化を待つ必要はないが、状態自体は同期更新される。
      final progress = container.read(progressProvider);
      expect(progress.coins, coinsPerClear);
    });

    test('最初のヒントは無料でコインが減らない', () {
      container.read(gameProvider.notifier).startPuzzle(_puzzle1);
      final revealed = container.read(gameProvider.notifier).revealNextHint();
      expect(revealed, isTrue);
      expect(container.read(progressProvider).coins, 0);
    });

    test('2つ目以降のヒントはコインが不足していると開放できない', () {
      container.read(gameProvider.notifier).startPuzzle(_puzzle1);
      container.read(gameProvider.notifier).revealNextHint(); // 1つ目: 無料
      final revealed = container.read(gameProvider.notifier).revealNextHint();
      expect(revealed, isFalse);
      expect(container.read(gameProvider)!.hintLevel, 1);
    });

    test('コインが十分あれば2つ目以降のヒントを開放してコインを消費する', () async {
      // まず1問クリアしてコインを貯める。
      container.read(gameProvider.notifier).startPuzzle(_puzzle1);
      container.read(gameProvider.notifier).submitAnswer('こたえ');
      final coinsBefore = container.read(progressProvider).coins;
      expect(coinsBefore, greaterThanOrEqualTo(hintCostCoins));

      const puzzle2 = Puzzle(
        id: 'coin_test_2',
        stage: 1,
        genre: PuzzleGenre.riddle,
        question: 'テスト問題2',
        answer: 'こたえ2',
        hints: ['ヒント1', 'ヒント2'],
        difficulty: PuzzleDifficulty.easy,
      );
      container.read(gameProvider.notifier).startPuzzle(puzzle2);
      container.read(gameProvider.notifier).revealNextHint(); // 1つ目: 無料
      final revealed = container.read(gameProvider.notifier).revealNextHint();
      expect(revealed, isTrue);
      expect(container.read(progressProvider).coins, coinsBefore - hintCostCoins);
    });

    test('ステージ6のアンロック費用が正しく計算される', () {
      expect(stageUnlockCost(5), 0);
      expect(stageUnlockCost(6), 50);
      expect(stageUnlockCost(7), 100);
    });

    test('コインが足りない場合はステージをアンロックできない', () async {
      final success =
          await container.read(progressProvider.notifier).unlockStageWithCoins(6);
      expect(success, isFalse);
      expect(container.read(progressProvider).unlockedStages.contains(6), isFalse);
    });

    test('広告視聴でコインを獲得できる', () async {
      await container.read(progressProvider.notifier).addCoinsFromAd();
      expect(container.read(progressProvider).coins, coinsPerAdView);
    });

    test('十分なコインがあればステージをアンロックできる', () async {
      await container.read(progressProvider.notifier).addCoinsFromAd();
      await container.read(progressProvider.notifier).addCoinsFromAd();
      final success =
          await container.read(progressProvider.notifier).unlockStageWithCoins(6);
      expect(success, isTrue);
      expect(container.read(progressProvider).unlockedStages.contains(6), isTrue);
    });
  });

  group('実績システム', () {
    test('1問もクリアしていない場合は実績が達成されない', () {
      const state = ProgressState();
      final newIds = evaluateNewlyUnlockedAchievements(state);
      expect(newIds, isEmpty);
    });

    test('1問クリアすると first_clear 実績が達成される', () {
      final state = const ProgressState().copyWith(
        clearedPuzzleIds: {'s1_01'},
        correctAttempts: 1,
      );
      final newIds = evaluateNewlyUnlockedAchievements(state);
      expect(newIds.contains('first_clear'), isTrue);
    });

    test('既に獲得済みの実績は再度返されない', () {
      final state = const ProgressState().copyWith(
        clearedPuzzleIds: {'s1_01'},
        unlockedAchievementIds: {'first_clear'},
      );
      final newIds = evaluateNewlyUnlockedAchievements(state);
      expect(newIds.contains('first_clear'), isFalse);
    });

    test('連続正解数が10になると ten_correct_streak 実績が達成される', () {
      final state = const ProgressState().copyWith(bestCorrectStreak: 10);
      final newIds = evaluateNewlyUnlockedAchievements(state);
      expect(newIds.contains('ten_correct_streak'), isTrue);
    });

    test('コインを500枚以上所持すると coin_collector 実績が達成される', () {
      final state = const ProgressState().copyWith(coins: 500);
      final newIds = evaluateNewlyUnlockedAchievements(state);
      expect(newIds.contains('coin_collector'), isTrue);
    });

    test('デイリーチャレンジ7日連続で daily_streak_7 実績が達成される', () {
      final state = const ProgressState().copyWith(dailyStreak: 7);
      final newIds = evaluateNewlyUnlockedAchievements(state);
      expect(newIds.contains('daily_streak_7'), isTrue);
    });
  });
}
