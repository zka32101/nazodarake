import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart' show rootScaffoldMessengerKey;
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';

/// 実績一覧画面。獲得済み/未獲得を可視化する。
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedIds = ref.watch(unlockedAchievementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.titleAchievements)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allAchievements.length,
        itemBuilder: (context, index) {
          final achievement = allAchievements[index];
          final unlocked = unlockedIds.contains(achievement.id);
          final colorScheme = Theme.of(context).colorScheme;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: unlocked ? null : colorScheme.surfaceContainerHighest,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    unlocked ? Colors.amber : colorScheme.outlineVariant,
                child: Icon(
                  unlocked ? achievement.icon : Icons.lock_rounded,
                  color: unlocked ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: unlocked ? null : colorScheme.onSurfaceVariant,
                ),
              ),
              subtitle: Text(achievement.description),
              trailing: unlocked
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// 実績を新規達成した際に表示するポップアップ演出。
/// 画面ツリーの上位に配置し、[achievementNotifierProvider] を監視する。
class AchievementPopupListener extends ConsumerWidget {
  const AchievementPopupListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<Achievement?>(achievementNotifierProvider, (previous, next) {
      if (next == null) return;
      // MaterialApp.builder の直下(Navigator/ScaffoldMessengerより外側)からでも
      // 確実に通知を出せるよう、context に依存しないグローバルキー経由で表示する。
      final messenger = rootScaffoldMessengerKey.currentState;
      messenger?.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(next.icon, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text('実績解除: ${next.title}\n${next.description}'),
              ),
            ],
          ),
        ),
      );
      ref.read(achievementNotifierProvider.notifier).dismiss();
    });
    return child;
  }
}
