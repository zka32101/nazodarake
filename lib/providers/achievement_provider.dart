import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement_model.dart';
import 'progress_provider.dart';

/// 実績の達成を監視し、新規達成時にポップアップ表示用の状態を保持する。
///
/// [progressProvider] の変化を監視し、新たに条件を満たした実績があれば
/// 自動的に [ProgressNotifier.unlockAchievements] で永続化しつつ、
/// 直近に達成した実績を state として公開する（UIはこれを見て通知を表示する）。
class AchievementNotifier extends StateNotifier<Achievement?> {
  AchievementNotifier(this._ref) : super(null) {
    _ref.listen<ProgressState>(
      progressProvider,
      (previous, next) => _checkForNewAchievements(next),
      fireImmediately: true,
    );
  }

  final Ref _ref;

  void _checkForNewAchievements(ProgressState progressState) {
    final newIds = evaluateNewlyUnlockedAchievements(progressState);
    if (newIds.isEmpty) return;
    _ref.read(progressProvider.notifier).unlockAchievements(newIds);
    final popup = allAchievements.where((a) => a.id == newIds.first);
    if (popup.isNotEmpty) {
      state = popup.first;
    }
  }

  /// ポップアップを閉じる（表示済みにする）。
  void dismiss() {
    state = null;
  }
}

final achievementNotifierProvider =
    StateNotifierProvider<AchievementNotifier, Achievement?>((ref) {
  return AchievementNotifier(ref);
});

/// 獲得済み実績の一覧（表示用）。
final unlockedAchievementsProvider = Provider<Set<String>>((ref) {
  return ref.watch(progressProvider).unlockedAchievementIds;
});
