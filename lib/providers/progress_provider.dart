import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ユーザーの進捗状態（永続化対象）。
class ProgressState {
  const ProgressState({
    this.clearedPuzzleIds = const <String>{},
    this.hintsUsedByPuzzleId = const <String, int>{},
    this.wrongAttempts = 0,
    this.correctAttempts = 0,
    this.soundEnabled = true,
    this.coins = 0,
    this.unlockedStages = const <int>{},
    this.unlockedAchievementIds = const <String>{},
    this.currentCorrectStreak = 0,
    this.bestCorrectStreak = 0,
    this.dailyStreak = 0,
    this.lastDailyCompletedDate,
    this.clearedDailyDates = const <String>{},
  });

  final Set<String> clearedPuzzleIds;
  final Map<String, int> hintsUsedByPuzzleId;
  final int wrongAttempts;
  final int correctAttempts;
  final bool soundEnabled;

  /// 所持コイン数（課金要素・広告視聴報酬・謎クリア報酬で増減）。
  final int coins;

  /// コインでアンロック済みのステージ番号（6ステージ目以降が対象）。
  final Set<int> unlockedStages;

  /// 獲得済みの実績ID一覧。
  final Set<String> unlockedAchievementIds;

  /// 現在の連続正解数（不正解でリセット）。
  final int currentCorrectStreak;

  /// これまでの最高連続正解数。
  final int bestCorrectStreak;

  /// デイリーチャレンジの連続挑戦日数（ストリーク）。
  final int dailyStreak;

  /// 直近でデイリーチャレンジをクリアした日付（yyyy-MM-dd）。
  final String? lastDailyCompletedDate;

  /// クリア済みのデイリーチャレンジ日付一覧。
  final Set<String> clearedDailyDates;

  int get totalAttempts => wrongAttempts + correctAttempts;

  double get accuracy {
    if (totalAttempts == 0) return 0;
    return correctAttempts / totalAttempts;
  }

  ProgressState copyWith({
    Set<String>? clearedPuzzleIds,
    Map<String, int>? hintsUsedByPuzzleId,
    int? wrongAttempts,
    int? correctAttempts,
    bool? soundEnabled,
    int? coins,
    Set<int>? unlockedStages,
    Set<String>? unlockedAchievementIds,
    int? currentCorrectStreak,
    int? bestCorrectStreak,
    int? dailyStreak,
    String? lastDailyCompletedDate,
    Set<String>? clearedDailyDates,
  }) {
    return ProgressState(
      clearedPuzzleIds: clearedPuzzleIds ?? this.clearedPuzzleIds,
      hintsUsedByPuzzleId: hintsUsedByPuzzleId ?? this.hintsUsedByPuzzleId,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      coins: coins ?? this.coins,
      unlockedStages: unlockedStages ?? this.unlockedStages,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      currentCorrectStreak: currentCorrectStreak ?? this.currentCorrectStreak,
      bestCorrectStreak: bestCorrectStreak ?? this.bestCorrectStreak,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastDailyCompletedDate:
          lastDailyCompletedDate ?? this.lastDailyCompletedDate,
      clearedDailyDates: clearedDailyDates ?? this.clearedDailyDates,
    );
  }

  Map<String, dynamic> toJson() => {
        'clearedPuzzleIds': clearedPuzzleIds.toList(),
        'hintsUsedByPuzzleId': hintsUsedByPuzzleId,
        'wrongAttempts': wrongAttempts,
        'correctAttempts': correctAttempts,
        'soundEnabled': soundEnabled,
        'coins': coins,
        'unlockedStages': unlockedStages.toList(),
        'unlockedAchievementIds': unlockedAchievementIds.toList(),
        'currentCorrectStreak': currentCorrectStreak,
        'bestCorrectStreak': bestCorrectStreak,
        'dailyStreak': dailyStreak,
        'lastDailyCompletedDate': lastDailyCompletedDate,
        'clearedDailyDates': clearedDailyDates.toList(),
      };

  factory ProgressState.fromJson(Map<String, dynamic> json) {
    return ProgressState(
      clearedPuzzleIds:
          ((json['clearedPuzzleIds'] as List?) ?? []).cast<String>().toSet(),
      hintsUsedByPuzzleId:
          ((json['hintsUsedByPuzzleId'] as Map?) ?? {}).map(
        (key, value) => MapEntry(key as String, value as int),
      ),
      wrongAttempts: json['wrongAttempts'] as int? ?? 0,
      correctAttempts: json['correctAttempts'] as int? ?? 0,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      coins: json['coins'] as int? ?? 0,
      unlockedStages:
          ((json['unlockedStages'] as List?) ?? []).cast<int>().toSet(),
      unlockedAchievementIds:
          ((json['unlockedAchievementIds'] as List?) ?? [])
              .cast<String>()
              .toSet(),
      currentCorrectStreak: json['currentCorrectStreak'] as int? ?? 0,
      bestCorrectStreak: json['bestCorrectStreak'] as int? ?? 0,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      lastDailyCompletedDate: json['lastDailyCompletedDate'] as String?,
      clearedDailyDates:
          ((json['clearedDailyDates'] as List?) ?? []).cast<String>().toSet(),
    );
  }
}

/// 謎を1問クリアしたときに得られるコイン報酬。
const int coinsPerClear = 10;

/// 広告視聴（モック）1回あたりのコイン報酬。
const int coinsPerAdView = 30;

/// ヒント1回あたりのコイン消費（最初のヒントのみ無料）。
const int hintCostCoins = 5;

/// ステージ6以降をアンロックするためのコイン費用を返す。
int stageUnlockCost(int stage) {
  if (stage <= 5) return 0;
  return 50 * (stage - 5);
}

const _prefsKey = 'nazodarake_progress_v1';

/// SharedPreferences を用いたローカル進捗永続化を担う StateNotifier。
class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(const ProgressState()) {
    _load();
  }

  SharedPreferences? _prefs;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = ProgressState.fromJson(decoded);
      } catch (_) {
        // 破損データの場合は初期状態のまま。
      }
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  Future<void> markCleared(String puzzleId) async {
    if (state.clearedPuzzleIds.contains(puzzleId)) return;
    final newStreak = state.currentCorrectStreak + 1;
    state = state.copyWith(
      clearedPuzzleIds: {...state.clearedPuzzleIds, puzzleId},
      correctAttempts: state.correctAttempts + 1,
      coins: state.coins + coinsPerClear,
      currentCorrectStreak: newStreak,
      bestCorrectStreak:
          newStreak > state.bestCorrectStreak ? newStreak : state.bestCorrectStreak,
    );
    await _persist();
  }

  Future<void> recordWrongAttempt() async {
    state = state.copyWith(
      wrongAttempts: state.wrongAttempts + 1,
      currentCorrectStreak: 0,
    );
    await _persist();
  }

  Future<void> recordHintUsed(String puzzleId) async {
    final current = state.hintsUsedByPuzzleId[puzzleId] ?? 0;
    state = state.copyWith(
      hintsUsedByPuzzleId: {
        ...state.hintsUsedByPuzzleId,
        puzzleId: current + 1,
      },
    );
    await _persist();
  }

  /// ヒントの利用にコインを消費できるか判定する（[hintLevel]は0始まりの
  /// これから開放する段階数。最初のヒント=0は常に無料）。
  bool canAffordHint(int hintLevel) {
    if (hintLevel <= 0) return true;
    return state.coins >= hintCostCoins;
  }

  /// ヒント使用時のコイン消費を行う。最初のヒントは無料。
  Future<void> spendCoinsForHint(int hintLevel) async {
    if (hintLevel <= 0) return;
    state = state.copyWith(coins: state.coins - hintCostCoins);
    await _persist();
  }

  /// 広告視聴（モック）でコインを付与する。
  Future<void> addCoinsFromAd() async {
    state = state.copyWith(coins: state.coins + coinsPerAdView);
    await _persist();
  }

  /// コインを消費してステージをアンロックする。
  /// 成功したら true、コインが足りなければ false を返す。
  Future<bool> unlockStageWithCoins(int stage) async {
    if (state.unlockedStages.contains(stage)) return true;
    final cost = stageUnlockCost(stage);
    if (state.coins < cost) return false;
    state = state.copyWith(
      coins: state.coins - cost,
      unlockedStages: {...state.unlockedStages, stage},
    );
    await _persist();
    return true;
  }

  Future<void> unlockAchievements(Set<String> newIds) async {
    if (newIds.isEmpty) return;
    state = state.copyWith(
      unlockedAchievementIds: {...state.unlockedAchievementIds, ...newIds},
    );
    await _persist();
  }

  /// デイリーチャレンジをクリアした際のストリーク更新。
  /// [today] は 'yyyy-MM-dd' 形式。前日にもクリアしていれば連続日数を+1、
  /// そうでなければ1にリセットする。
  Future<void> recordDailyChallengeCleared(String today, String? yesterday) async {
    if (state.clearedDailyDates.contains(today)) return;
    final continued = yesterday != null &&
        state.lastDailyCompletedDate == yesterday;
    final newStreak = continued ? state.dailyStreak + 1 : 1;
    state = state.copyWith(
      dailyStreak: newStreak,
      lastDailyCompletedDate: today,
      clearedDailyDates: {...state.clearedDailyDates, today},
      coins: state.coins + coinsPerClear,
    );
    await _persist();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _persist();
  }

  Future<void> resetProgress() async {
    state = const ProgressState();
    await _persist();
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier();
});
