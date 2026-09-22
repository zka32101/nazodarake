import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/puzzle_model.dart';
import '../providers/free_play_provider.dart';
import '../providers/progress_provider.dart';
import 'puzzle_screen.dart';

/// ジャンル・難易度で横断的に絞り込んでプレイできる「フリープレイ」画面。
///
/// ステージ進行や解放条件とは無関係に、条件に合う謎を自由に選んで挑戦できる。
/// クリア状況・コイン等の記録は通常プレイと同様に [ProgressNotifier] に反映される。
class FreePlayScreen extends ConsumerWidget {
  const FreePlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genre = ref.watch(freePlayGenreFilterProvider);
    final difficulty = ref.watch(freePlayDifficultyFilterProvider);
    final puzzles = ref.watch(filteredFreePlayPuzzlesProvider);
    final clearedIds = ref.watch(progressProvider).clearedPuzzleIds;

    return Scaffold(
      appBar: AppBar(title: const Text('フリープレイ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ジャンルで絞り込み', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('すべて'),
                      selected: genre == null,
                      onSelected: (_) => ref
                          .read(freePlayGenreFilterProvider.notifier)
                          .state = null,
                    ),
                    for (final g in PuzzleGenre.values)
                      ChoiceChip(
                        label: Text(g.label),
                        selected: genre == g,
                        onSelected: (_) => ref
                            .read(freePlayGenreFilterProvider.notifier)
                            .state = g,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('難易度で絞り込み', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('すべて'),
                      selected: difficulty == null,
                      onSelected: (_) => ref
                          .read(freePlayDifficultyFilterProvider.notifier)
                          .state = null,
                    ),
                    for (final d in PuzzleDifficulty.values)
                      ChoiceChip(
                        label: Text(d.label),
                        selected: difficulty == d,
                        onSelected: (_) => ref
                            .read(freePlayDifficultyFilterProvider.notifier)
                            .state = d,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: puzzles.isEmpty
                ? const Center(child: Text('条件に一致する謎がありません'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: puzzles.length,
                    itemBuilder: (context, index) {
                      final puzzle = puzzles[index];
                      final cleared = clearedIds.contains(puzzle.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            cleared
                                ? Icons.check_circle_rounded
                                : Icons.help_outline_rounded,
                            color: cleared ? Colors.green : null,
                          ),
                          title: Text(
                            puzzle.question,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '第${puzzle.stage}ステージ ・ ${puzzle.genre.label} ・ ${puzzle.difficulty.label}',
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PuzzleScreen(
                                  puzzles: [puzzle],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
