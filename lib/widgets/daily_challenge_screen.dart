import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/puzzle_model.dart';
import '../providers/daily_challenge_provider.dart';
import '../providers/progress_provider.dart';

/// 日替わりで1問だけ出題される「デイリーチャレンジ」モード。
/// 同じ日付には常に同じ問題が出題され（決定的選択）、連続挑戦日数を記録する。
class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  final TextEditingController _controller = TextEditingController();
  int _hintLevel = 0;
  bool _wrongFeedback = false;
  bool _solved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(Puzzle puzzle, String todayKey) {
    final correct = puzzle.isCorrect(_controller.text);
    if (correct) {
      _handleCorrect(puzzle, todayKey);
    } else {
      setState(() => _wrongFeedback = true);
    }
  }

  void _handleOptionSelected(Puzzle puzzle, String option, String todayKey) {
    if (puzzle.isCorrect(option)) {
      _handleCorrect(puzzle, todayKey);
    } else {
      setState(() => _wrongFeedback = true);
    }
  }

  Future<void> _handleCorrect(Puzzle puzzle, String todayKey) async {
    final notifier = ref.read(progressProvider.notifier);
    await notifier.markCleared(puzzle.id);
    final yesterdayKey = formatPreviousDateKey(todayDateOnly());
    await notifier.recordDailyChallengeCleared(todayKey, yesterdayKey);
    if (!mounted) return;
    setState(() {
      _solved = true;
      _wrongFeedback = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = ref.watch(todayDailyPuzzleProvider);
    final todayKey = ref.watch(todayDateKeyProvider);
    final progress = ref.watch(progressProvider);
    final alreadyClearedToday = progress.clearedDailyDates.contains(todayKey);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('デイリーチャレンジ')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '連続挑戦: ${progress.dailyStreak}日',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('今日の日付: $todayKey', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(puzzle.genre.label)),
                  Chip(label: Text(puzzle.difficulty.label)),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    puzzle.question,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (alreadyClearedToday || _solved)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.celebration_rounded,
                              color: colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            '本日のデイリーチャレンジはクリア済みです！',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (puzzle.explanation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          puzzle.explanation!,
                          style:
                              TextStyle(color: colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ],
                  ),
                )
              else ...[
                if (_wrongFeedback)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '残念、正解ではありません。もう一度考えてみよう！',
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                  ),
                if (puzzle.isFreeInput)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: '答えを入力してください',
                          prefixIcon: Icon(Icons.edit_rounded),
                        ),
                        onSubmitted: (_) => _submit(puzzle, todayKey),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _submit(puzzle, todayKey),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('こたえる'),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: puzzle.options!
                        .map(
                          (option) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OutlinedButton(
                              onPressed: () =>
                                  _handleOptionSelected(puzzle, option, todayKey),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(option),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 20),
                for (var i = 0; i < _hintLevel; i++)
                  Card(
                    color: colorScheme.secondaryContainer,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('ヒント${i + 1}: ${puzzle.hints[i]}'),
                    ),
                  ),
                if (_hintLevel < puzzle.hints.length)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _hintLevel++),
                    icon: const Icon(Icons.lightbulb_outline_rounded),
                    label: Text('ヒントを見る (${_hintLevel + 1}/${puzzle.hints.length})'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
