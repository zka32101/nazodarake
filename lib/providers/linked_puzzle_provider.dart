import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/linked_puzzle_model.dart';
import 'progress_provider.dart';
import 'sound_provider.dart';

/// 連動謎セットのプレイ中の一時的な状態。
class LinkedPuzzlePlayState {
  const LinkedPuzzlePlayState({
    required this.set,
    this.currentIndex = 0,
    this.isWrongFeedback = false,
    this.allFragmentsCleared = false,
    this.isFinalSolved = false,
    this.isFinalWrongFeedback = false,
  });

  final LinkedPuzzleSet set;

  /// 現在挑戦中の断片謎のインデックス。
  final int currentIndex;
  final bool isWrongFeedback;

  /// 全ての断片謎をクリアしたか（最終回答入力に進めるか）。
  final bool allFragmentsCleared;
  final bool isFinalSolved;
  final bool isFinalWrongFeedback;

  LinkedFragmentPuzzle? get currentFragment {
    if (currentIndex >= set.fragments.length) return null;
    return set.fragments[currentIndex];
  }

  LinkedPuzzlePlayState copyWith({
    int? currentIndex,
    bool? isWrongFeedback,
    bool? allFragmentsCleared,
    bool? isFinalSolved,
    bool? isFinalWrongFeedback,
  }) {
    return LinkedPuzzlePlayState(
      set: set,
      currentIndex: currentIndex ?? this.currentIndex,
      isWrongFeedback: isWrongFeedback ?? this.isWrongFeedback,
      allFragmentsCleared: allFragmentsCleared ?? this.allFragmentsCleared,
      isFinalSolved: isFinalSolved ?? this.isFinalSolved,
      isFinalWrongFeedback:
          isFinalWrongFeedback ?? this.isFinalWrongFeedback,
    );
  }
}

/// 連動謎セットの進行状態を管理する StateNotifier。
class LinkedPuzzleNotifier extends StateNotifier<LinkedPuzzlePlayState?> {
  LinkedPuzzleNotifier(this._ref) : super(null);

  final Ref _ref;

  void startSet(LinkedPuzzleSet set) {
    state = LinkedPuzzlePlayState(set: set);
  }

  /// 現在の断片謎に回答する。正解なら true。
  bool submitFragmentAnswer(String userInput) {
    final current = state;
    if (current == null) return false;
    final fragment = current.currentFragment;
    if (fragment == null) return false;
    final correct = fragment.isCorrect(userInput);
    if (correct) {
      _ref.read(soundProvider).playCorrect();
      _ref.read(progressProvider.notifier).markLinkedFragmentCleared(
            fragment.id,
          );
      final nextIndex = current.currentIndex + 1;
      final allCleared = nextIndex >= current.set.fragments.length;
      state = current.copyWith(
        currentIndex: nextIndex,
        isWrongFeedback: false,
        allFragmentsCleared: allCleared,
      );
    } else {
      _ref.read(soundProvider).playWrong();
      state = current.copyWith(isWrongFeedback: true);
    }
    return correct;
  }

  /// 最終回答を判定する。正解なら true。
  bool submitFinalAnswer(String userInput) {
    final current = state;
    if (current == null) return false;
    final correct = current.set.isFinalAnswerCorrect(userInput);
    if (correct) {
      _ref.read(soundProvider).playCorrect();
      _ref
          .read(progressProvider.notifier)
          .markLinkedSetCleared(current.set.id);
      state = current.copyWith(
        isFinalSolved: true,
        isFinalWrongFeedback: false,
      );
    } else {
      _ref.read(soundProvider).playWrong();
      state = current.copyWith(isFinalWrongFeedback: true);
    }
    return correct;
  }

  void reset() {
    state = null;
  }
}

final linkedPuzzleProvider =
    StateNotifierProvider<LinkedPuzzleNotifier, LinkedPuzzlePlayState?>(
  (ref) => LinkedPuzzleNotifier(ref),
);

/// 指定ステージの連動謎セットが最終回答までクリア済みかどうか。
final isLinkedSetClearedProvider = Provider.family<bool, String>((ref, setId) {
  final progress = ref.watch(progressProvider);
  return progress.clearedLinkedSetIds.contains(setId);
});
