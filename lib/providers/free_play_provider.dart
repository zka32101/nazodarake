import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/puzzles_data.dart';
import '../models/puzzle_model.dart';

/// フリープレイ画面で選択中のジャンル絞り込み（nullなら「すべて」）。
final freePlayGenreFilterProvider = StateProvider<PuzzleGenre?>((ref) => null);

/// フリープレイ画面で選択中の難易度絞り込み（nullなら「すべて」）。
final freePlayDifficultyFilterProvider =
    StateProvider<PuzzleDifficulty?>((ref) => null);

/// ジャンル・難易度で謎の一覧を絞り込む純粋関数。
/// [genre] / [difficulty] が null の場合はその軸では絞り込まない。
List<Puzzle> filterPuzzles(
  List<Puzzle> puzzles, {
  PuzzleGenre? genre,
  PuzzleDifficulty? difficulty,
}) {
  return puzzles.where((p) {
    if (genre != null && p.genre != genre) return false;
    if (difficulty != null && p.difficulty != difficulty) return false;
    return true;
  }).toList();
}

/// 現在のフィルタ条件で絞り込んだ謎の一覧（ステージ横断）。
final filteredFreePlayPuzzlesProvider = Provider<List<Puzzle>>((ref) {
  final genre = ref.watch(freePlayGenreFilterProvider);
  final difficulty = ref.watch(freePlayDifficultyFilterProvider);
  return filterPuzzles(allPuzzles, genre: genre, difficulty: difficulty);
});
