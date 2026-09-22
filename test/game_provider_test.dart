import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/models/puzzle_model.dart';
import 'package:nazodarake/providers/game_provider.dart';
import 'package:nazodarake/providers/progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testPuzzle = Puzzle(
  id: 'gp_test_1',
  stage: 1,
  genre: PuzzleGenre.riddle,
  question: 'テスト問題',
  answer: 'せいかい',
  hints: ['ヒント1', 'ヒント2'],
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

  group('GameNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('startPuzzle で状態が初期化される', () {
      container.read(gameProvider.notifier).startPuzzle(_testPuzzle);
      final state = container.read(gameProvider);
      expect(state, isNotNull);
      expect(state!.puzzle.id, 'gp_test_1');
      expect(state.hintLevel, 0);
      expect(state.isSolved, isFalse);
    });

    test('submitAnswer に正解を渡すと isSolved が true になる', () {
      container.read(gameProvider.notifier).startPuzzle(_testPuzzle);
      final correct =
          container.read(gameProvider.notifier).submitAnswer('せいかい');
      expect(correct, isTrue);
      expect(container.read(gameProvider)!.isSolved, isTrue);
    });

    test('submitAnswer に不正解を渡すと isWrongFeedback が true になる', () {
      container.read(gameProvider.notifier).startPuzzle(_testPuzzle);
      final correct =
          container.read(gameProvider.notifier).submitAnswer('まちがい');
      expect(correct, isFalse);
      expect(container.read(gameProvider)!.isWrongFeedback, isTrue);
      expect(container.read(gameProvider)!.isSolved, isFalse);
    });

    test('revealNextHint でヒント段階が1つずつ進む', () {
      container.read(gameProvider.notifier).startPuzzle(_testPuzzle);
      container.read(gameProvider.notifier).revealNextHint();
      expect(container.read(gameProvider)!.hintLevel, 1);
      container.read(gameProvider.notifier).revealNextHint();
      expect(container.read(gameProvider)!.hintLevel, 2);
      // ヒント上限を超えては増えない
      container.read(gameProvider.notifier).revealNextHint();
      expect(container.read(gameProvider)!.hintLevel, 2);
    });

    test('正解すると progressProvider にクリア記録が反映される', () {
      container.read(gameProvider.notifier).startPuzzle(_testPuzzle);
      container.read(gameProvider.notifier).submitAnswer('せいかい');
      final progress = container.read(progressProvider);
      expect(progress.clearedPuzzleIds.contains('gp_test_1'), isTrue);
      expect(progress.correctAttempts, 1);
    });

    test('reset で状態が null に戻る', () {
      container.read(gameProvider.notifier).startPuzzle(_testPuzzle);
      container.read(gameProvider.notifier).reset();
      expect(container.read(gameProvider), isNull);
    });
  });
}
