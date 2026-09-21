import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/puzzle_model.dart';
import '../providers/game_provider.dart';
import 'puzzle_screen.dart';

/// ステージ選択画面。クリア状況・アンロック状況を可視化する。
class StageSelectScreen extends ConsumerWidget {
  const StageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzlesByStage = ref.watch(puzzlesByStageProvider);
    final stageNumbers = puzzlesByStage.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('ステージ選択')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stageNumbers.length,
        itemBuilder: (context, index) {
          final stage = stageNumbers[index];
          final puzzles = puzzlesByStage[stage]!;
          final unlocked = ref.watch(isStageUnlockedProvider(stage));
          final cleared = ref.watch(isStageClearedProvider(stage));
          final clearedCount = ref.watch(stageClearedCountProvider(stage));

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              enabled: unlocked,
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
                          : Icons.lock_rounded),
                  color: cleared
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                'ステージ $stage',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                unlocked
                    ? 'クリア: $clearedCount / ${puzzles.length} 問'
                    : '前のステージをクリアすると解放されます',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: unlocked
                  ? () => _openStage(context, ref, puzzles)
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _openStage(
    BuildContext context,
    WidgetRef ref,
    List<Puzzle> puzzles,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PuzzleScreen(puzzles: puzzles),
      ),
    );
  }
}
