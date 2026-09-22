import 'puzzle_model.dart';

/// 連動謎（複数の謎を解いて得られる断片を組み合わせて
/// 最終回答を導く形式）の1問分。
///
/// 通常の [Puzzle] と異なり、正解すると「最終回答の1文字/1桁」となる
/// [fragment] が得られる。
class LinkedFragmentPuzzle {
  const LinkedFragmentPuzzle({
    required this.id,
    required this.genre,
    required this.question,
    required this.answer,
    required this.fragment,
    required this.hints,
    required this.difficulty,
    this.explanation,
  });

  /// 一意なID（例: 'linked_s12_01'）。
  final String id;

  final PuzzleGenre genre;
  final String question;

  /// この謎自体の正解（表記ゆれ判定は [Puzzle.isCorrect] と同じロジック）。
  final String answer;

  /// 正解した際に得られる、最終回答を構成する断片（1文字〜数文字）。
  final String fragment;

  final List<String> hints;
  final PuzzleDifficulty difficulty;
  final String? explanation;

  /// ユーザー入力に対する正誤判定（[Puzzle.isCorrect] と同一ロジック）。
  bool isCorrect(String userInput) {
    final normalizedInput = _normalize(userInput);
    final normalizedAnswer = _normalize(answer);
    if (normalizedInput.isEmpty) return false;
    return normalizedInput == normalizedAnswer;
  }

  static String _normalize(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('　', '')
        .toLowerCase();
  }
}

/// 複数の [LinkedFragmentPuzzle] と、それらの断片を組み合わせて得られる
/// 最終回答からなる「連動謎セット」（ボーナスステージ1つ分）。
class LinkedPuzzleSet {
  const LinkedPuzzleSet({
    required this.id,
    required this.stage,
    required this.title,
    required this.description,
    required this.fragments,
    required this.finalAnswer,
    required this.finalExplanation,
  });

  /// 一意なID（例: 'linked_s12'）。
  final String id;

  /// 所属するステージ番号。
  final int stage;

  /// セットのタイトル（例: 「失われた記憶の暗号」）。
  final String title;

  /// セット全体の導入説明文。
  final String description;

  /// 断片謎の一覧（3〜5問）。
  final List<LinkedFragmentPuzzle> fragments;

  /// 全断片を正しい順番で組み合わせたときの最終回答。
  final String finalAnswer;

  /// 最終回答正解時の解説。
  final String finalExplanation;

  /// 全ての断片を正しい順に連結した文字列（ヒント表示・自動生成用）。
  String get combinedFragments => fragments.map((f) => f.fragment).join();

  /// 最終回答の正誤判定（[LinkedFragmentPuzzle.isCorrect] と同一ロジック）。
  bool isFinalAnswerCorrect(String userInput) {
    final normalizedInput = _normalize(userInput);
    final normalizedAnswer = _normalize(finalAnswer);
    if (normalizedInput.isEmpty) return false;
    return normalizedInput == normalizedAnswer;
  }

  static String _normalize(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('　', '')
        .toLowerCase();
  }
}
