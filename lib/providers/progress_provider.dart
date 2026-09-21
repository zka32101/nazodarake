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
  });

  final Set<String> clearedPuzzleIds;
  final Map<String, int> hintsUsedByPuzzleId;
  final int wrongAttempts;
  final int correctAttempts;
  final bool soundEnabled;

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
  }) {
    return ProgressState(
      clearedPuzzleIds: clearedPuzzleIds ?? this.clearedPuzzleIds,
      hintsUsedByPuzzleId: hintsUsedByPuzzleId ?? this.hintsUsedByPuzzleId,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'clearedPuzzleIds': clearedPuzzleIds.toList(),
        'hintsUsedByPuzzleId': hintsUsedByPuzzleId,
        'wrongAttempts': wrongAttempts,
        'correctAttempts': correctAttempts,
        'soundEnabled': soundEnabled,
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
    );
  }
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
    state = state.copyWith(
      clearedPuzzleIds: {...state.clearedPuzzleIds, puzzleId},
      correctAttempts: state.correctAttempts + 1,
    );
    await _persist();
  }

  Future<void> recordWrongAttempt() async {
    state = state.copyWith(wrongAttempts: state.wrongAttempts + 1);
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
