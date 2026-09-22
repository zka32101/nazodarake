import 'package:flutter/material.dart';
import 'package:nazodarake/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/puzzle_model.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import 'ad_reward_dialog.dart';
import 'puzzle_screen.dart';
import 'story_intro_dialog.dart';

/// ステージ選択画面。クリア状況・アンロック状況を可視化する。
class StageSelectScreen extends ConsumerWidget {
  const StageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzlesByStage = ref.watch(puzzlesByStageProvider);
    final stageNumbers = puzzlesByStage.keys.toList()..sort();
    final coins = ref.watch(progressProvider).coins;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stageSelectTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('$coins'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stageNumbers.length,
        itemBuilder: (context, index) {
          final stage = stageNumbers[index];
          final puzzles = puzzlesByStage[stage]!;
          final unlocked = ref.watch(isStageUnlockedProvider(stage));
          final purchasable = ref.watch(isStagePurchasableProvider(stage));
          final cleared = ref.watch(isStageClearedProvider(stage));
          final clearedCount = ref.watch(stageClearedCountProvider(stage));
          final cost = stageUnlockCost(stage);

          String subtitle;
          if (unlocked) {
            subtitle = 'クリア: $clearedCount / ${puzzles.length} 問';
          } else if (purchasable) {
            subtitle = '$cost コインでアンロックできます';
          } else {
            subtitle = '前のステージをクリアすると解放されます';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              enabled: unlocked || purchasable,
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: cleared
                    ? Colors.amber
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  cleared
                      ? Icons.emoji_events_rounded
                      : (unlocked
                          ? Icons.lock_open_rounded
                          : (purchasable
                              ? Icons.monetization_on_rounded
                              : Icons.lock_rounded)),
                  color: cleared
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                'ステージ $stage',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(subtitle),
              trailing: purchasable
                  ? FilledButton.tonal(
                      onPressed: () => _handlePurchase(context, ref, stage),
                      child: const Text('アンロック'),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: unlocked
                  ? () => _openStage(context, ref, stage, puzzles)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    WidgetRef ref,
    int stage,
  ) async {
    final success =
        await ref.read(progressProvider.notifier).unlockStageWithCoins(stage);
    if (!context.mounted) return;
    if (!success) {
      final watchAd = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('コインが足りません'),
          content: const Text('広告を見てコインを獲得しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('やめる'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('広告を見る'),
            ),
          ],
        ),
      );
      if (watchAd == true && context.mounted) {
        await AdRewardDialog.show(context);
      }
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ステージ$stageをアンロックしました！')),
      );
    }
  }

  Future<void> _openStage(
    BuildContext context,
    WidgetRef ref,
    int stage,
    List<Puzzle> puzzles,
  ) async {
    await StoryIntroDialog.show(context, stage);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PuzzleScreen(puzzles: puzzles),
      ),
    );
  }
}
