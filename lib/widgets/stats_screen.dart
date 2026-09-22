import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/puzzles_data.dart';
import '../providers/progress_provider.dart';

/// クリア数・正答率などの簡易統計画面。
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final totalPuzzles = allPuzzles.length;
    final clearedCount = progress.clearedPuzzleIds.length;
    final accuracyPercent = (progress.accuracy * 100).toStringAsFixed(1);
    final totalHints =
        progress.hintsUsedByPuzzleId.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.titleStats)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            icon: Icons.check_circle_rounded,
            label: 'クリア数',
            value: '$clearedCount / $totalPuzzles 問',
          ),
          _StatCard(
            icon: Icons.percent_rounded,
            label: '正答率',
            value: '$accuracyPercent %',
          ),
          _StatCard(
            icon: Icons.thumb_up_alt_rounded,
            label: '正解した回数',
            value: '${progress.correctAttempts} 回',
          ),
          _StatCard(
            icon: Icons.thumb_down_alt_rounded,
            label: '不正解の回数',
            value: '${progress.wrongAttempts} 回',
          ),
          _StatCard(
            icon: Icons.lightbulb_rounded,
            label: '使用したヒント合計',
            value: '$totalHints 回',
          ),
          _StatCard(
            icon: Icons.monetization_on_rounded,
            label: '所持コイン',
            value: '${progress.coins} 枚',
          ),
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            label: '最高連続正解数',
            value: '${progress.bestCorrectStreak} 問',
          ),
          _StatCard(
            icon: Icons.today_rounded,
            label: 'デイリーチャレンジ連続日数',
            value: '${progress.dailyStreak} 日',
          ),
          _StatCard(
            icon: Icons.emoji_events_rounded,
            label: '獲得済み実績',
            value: '${progress.unlockedAchievementIds.length} / 10 個',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
