import 'package:flutter/material.dart';

import '../data/puzzles_data.dart';
import '../providers/progress_provider.dart';
import 'puzzle_model.dart';

/// 実績（バッジ）の定義。
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

/// アプリ内に存在する全実績の定義一覧（10種類）。
const List<Achievement> allAchievements = [
  Achievement(
    id: 'first_clear',
    title: 'はじめの一歩',
    description: '謎を1問クリアする',
    icon: Icons.flag_rounded,
  ),
  Achievement(
    id: 'stage1_complete',
    title: 'はじまりの謎、制覇',
    description: 'ステージ1の全問をクリアする',
    icon: Icons.looks_one_rounded,
  ),
  Achievement(
    id: 'no_hint_clear',
    title: 'ノーヒントの誇り',
    description: 'ヒントを1つも使わずに謎をクリアする',
    icon: Icons.lightbulb_outline_rounded,
  ),
  Achievement(
    id: 'ten_correct_streak',
    title: '連続正解の達人',
    description: '10問連続で正解する',
    icon: Icons.local_fire_department_rounded,
  ),
  Achievement(
    id: 'all_genres',
    title: 'オールジャンル制覇',
    description: '全てのジャンルで1問以上クリアする',
    icon: Icons.category_rounded,
  ),
  Achievement(
    id: 'half_complete',
    title: '道半ば',
    description: '謎を合計50問クリアする',
    icon: Icons.timeline_rounded,
  ),
  Achievement(
    id: 'full_complete',
    title: 'なぞだらけ制覇',
    description: '全100問をクリアする',
    icon: Icons.emoji_events_rounded,
  ),
  Achievement(
    id: 'daily_streak_7',
    title: '継続は力なり',
    description: 'デイリーチャレンジに7日連続で挑戦する',
    icon: Icons.calendar_month_rounded,
  ),
  Achievement(
    id: 'coin_collector',
    title: 'コインコレクター',
    description: 'コインを500枚以上所持する',
    icon: Icons.monetization_on_rounded,
  ),
  Achievement(
    id: 'stage10_clear',
    title: '最果てへの到達',
    description: 'ステージ10までクリアする',
    icon: Icons.terrain_rounded,
  ),
];

/// 現在の進捗状態から、新しく達成された（まだ [ProgressState.unlockedAchievementIds]
/// に含まれていない）実績のID一覧を返す。
Set<String> evaluateNewlyUnlockedAchievements(ProgressState state) {
  final alreadyUnlocked = state.unlockedAchievementIds;
  final newlyUnlocked = <String>{};

  bool has(String id) => alreadyUnlocked.contains(id) || newlyUnlocked.contains(id);

  void unlockIf(String id, bool condition) {
    if (!has(id) && condition) {
      newlyUnlocked.add(id);
    }
  }

  final clearedCount = state.clearedPuzzleIds.length;

  unlockIf('first_clear', clearedCount >= 1);
  unlockIf('half_complete', clearedCount >= 50);
  unlockIf('full_complete', clearedCount >= allPuzzles.length);
  unlockIf('ten_correct_streak', state.bestCorrectStreak >= 10);
  unlockIf('daily_streak_7', state.dailyStreak >= 7);
  unlockIf('coin_collector', state.coins >= 500);

  final stage1Puzzles = allPuzzles.where((p) => p.stage == 1).toList();
  unlockIf(
    'stage1_complete',
    stage1Puzzles.isNotEmpty &&
        stage1Puzzles.every((p) => state.clearedPuzzleIds.contains(p.id)),
  );

  final stage10Puzzles = allPuzzles.where((p) => p.stage == 10).toList();
  unlockIf(
    'stage10_clear',
    stage10Puzzles.isNotEmpty &&
        stage10Puzzles.every((p) => state.clearedPuzzleIds.contains(p.id)),
  );

  final noHintClear = state.clearedPuzzleIds.any(
    (id) => (state.hintsUsedByPuzzleId[id] ?? 0) == 0,
  );
  unlockIf('no_hint_clear', noHintClear);

  final clearedGenres = allPuzzles
      .where((p) => state.clearedPuzzleIds.contains(p.id))
      .map((p) => p.genre)
      .toSet();
  unlockIf('all_genres', clearedGenres.length >= PuzzleGenre.values.length);

  return newlyUnlocked;
}
