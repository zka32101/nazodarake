import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/puzzles_data.dart';
import '../models/puzzle_model.dart';
import 'progress_provider.dart';

/// 現在プレイ中の謎解きの一時的な状態（画面遷移では消えてよい情報）。
class PuzzlePlayState {
  const PuzzlePlayState({
    required this.puzzle,
    this.hintLevel = 0,
    this.isWrongFeedback = false,
    this.isSolved = false,
  });

  final Puzzle puzzle;

  /// 現在表示中のヒント段階（0=未使用）。
  final int hintLevel;

  /// 直前の回答が不正解だったかどうか（フィードバック表示用）。
  final bool isWrongFeedback;

  /// 正解済みかどうか。
  final bool isSolved;

  PuzzlePlayState copyWith({
    int? hintLevel,
    bool? isWrongFeedback,
    bool? isSolved,
  }) {
    return PuzzlePlayState(
      puzzle: puzzle,
      hintLevel: hintLevel ?? this.hintLevel,
      isWrongFeedback: isWrongFeedback ?? this.isWrongFeedback,
      isSolved: isSolved ?? this.isSolved,
    );
  }
}

/// 現在の謎解きプレイ状態を管理する StateNotifier。
class GameNotifier extends StateNotifier<PuzzlePlayState?> {
  GameNotifier(this._ref) : super(null);

  final Ref _ref;

  /// 指定した謎で挑戦を開始する。
  void startPuzzle(Puzzle puzzle) {
    state = PuzzlePlayState(puzzle: puzzle);
  }

  /// ヒントを1段階開放する。
  /// コインが不足していて開放できない場合は false を返す。
  bool revealNextHint() {
    final current = state;
    if (current == null) return false;
    final maxLevel = current.puzzle.hints.length;
    if (current.hintLevel >= maxLevel) return false;
    final newLevel = current.hintLevel + 1;
    // hintLevel(0始まり)。1つ目(newLevel==1)は無料、2つ目以降はコイン消費。
    final progressNotifier = _ref.read(progressProvider.notifier);
    if (!progressNotifier.canAffordHint(newLevel - 1)) {
      return false;
    }
    state = current.copyWith(hintLevel: newLevel, isWrongFeedback: false);
    progressNotifier.recordHintUsed(current.puzzle.id);
    progressNotifier.spendCoinsForHint(newLevel - 1);
    return true;
  }

  /// ユーザーの回答を判定する。
  /// 戻り値: 正解なら true。
  bool submitAnswer(String userInput) {
    final current = state;
    if (current == null) return false;
    final correct = current.puzzle.isCorrect(userInput);
    if (correct) {
      state = current.copyWith(isSolved: true, isWrongFeedback: false);
      _ref.read(progressProvider.notifier).markCleared(current.puzzle.id);
    } else {
      state = current.copyWith(isWrongFeedback: true);
      _ref.read(progressProvider.notifier).recordWrongAttempt();
    }
    return correct;
  }

  /// 選択肢形式の回答判定（表示用の選択肢文字列をそのまま渡す）。
  bool submitOption(String option) => submitAnswer(option);

  void clearWrongFeedback() {
    final current = state;
    if (current == null) return;
    if (!current.isWrongFeedback) return;
    state = current.copyWith(isWrongFeedback: false);
  }

  void reset() {
    state = null;
  }
}

final gameProvider =
    StateNotifierProvider<GameNotifier, PuzzlePlayState?>((ref) {
  return GameNotifier(ref);
});

/// ステージ選択画面用: ステージ番号→謎リストのマップ。
final puzzlesByStageProvider = Provider<Map<int, List<Puzzle>>>((ref) {
  return groupPuzzlesByStage();
});

/// 指定ステージがクリア済みかどうか（そのステージの全問がクリア済み）を返す。
final isStageClearedProvider = Provider.family<bool, int>((ref, stage) {
  final progress = ref.watch(progressProvider);
  final puzzles = ref.watch(puzzlesByStageProvider)[stage] ?? [];
  if (puzzles.isEmpty) return false;
  return puzzles.every((p) => progress.clearedPuzzleIds.contains(p.id));
});

/// 指定ステージがアンロックされているか。
/// ステージ1〜5: 1ステージ目は常に開放、それ以外は直前のステージがクリア済みなら開放。
/// ステージ6以降: 直前のステージクリア済み、かつコインでアンロック済みの場合に開放。
final isStageUnlockedProvider = Provider.family<bool, int>((ref, stage) {
  if (stage <= 1) return true;
  if (stage <= 5) {
    return ref.watch(isStageClearedProvider(stage - 1));
  }
  final previousCleared = ref.watch(isStageClearedProvider(stage - 1));
  final progress = ref.watch(progressProvider);
  return previousCleared && progress.unlockedStages.contains(stage);
});

/// コインでアンロック可能なステージかどうか（直前のステージはクリア済みだが
/// まだコインでのアンロックが済んでいない場合に true）。
final isStagePurchasableProvider = Provider.family<bool, int>((ref, stage) {
  if (stage <= 5) return false;
  final previousCleared = ref.watch(isStageClearedProvider(stage - 1));
  final progress = ref.watch(progressProvider);
  return previousCleared && !progress.unlockedStages.contains(stage);
});

/// 指定ステージのクリア済み問題数を返す。
final stageClearedCountProvider = Provider.family<int, int>((ref, stage) {
  final progress = ref.watch(progressProvider);
  final puzzles = ref.watch(puzzlesByStageProvider)[stage] ?? [];
  return puzzles.where((p) => progress.clearedPuzzleIds.contains(p.id)).length;
});
