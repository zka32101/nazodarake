import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/puzzle_model.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import 'result_screen.dart';

/// 謎解き画面。渡された [puzzles] を順番に出題する。
class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key, required this.puzzles, this.startIndex = 0});

  final List<Puzzle> puzzles;
  final int startIndex;

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  late int _index;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCurrent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startCurrent() {
    ref.read(gameProvider.notifier).startPuzzle(widget.puzzles[_index]);
    _controller.clear();
  }

  Future<void> _goToNext() async {
    if (_index >= widget.puzzles.length - 1) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
    _startCurrent();
  }

  void _handleSubmit(String userInput) {
    final correct = ref.read(gameProvider.notifier).submitAnswer(userInput);
    if (correct) {
      final puzzle = widget.puzzles[_index];
      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                puzzle: puzzle,
                isLastPuzzle: _index >= widget.puzzles.length - 1,
              ),
            ),
          )
          .then((_) => _goToNext());
    }
  }

  @override
  Widget build(BuildContext context) {
    final playState = ref.watch(gameProvider);
    if (playState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final puzzle = playState.puzzle;
    final colorScheme = Theme.of(context).colorScheme;

    final coins = ref.watch(progressProvider).coins;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '第${puzzle.stage}ステージ  ${_index + 1}/${widget.puzzles.length}問',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Semantics(
                label: '所持コイン $coins 枚',
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$coins'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (playState.isWrongFeedback)
                Semantics(
                  liveRegion: true,
                  label: '不正解です。もう一度考えてみましょう。',
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.close_rounded,
                            color: colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '残念、正解ではありません。もう一度考えてみよう！',
                            style: TextStyle(color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (puzzle.isFreeInput)
                _FreeInputArea(
                  controller: _controller,
                  onSubmit: _handleSubmit,
                )
              else
                _OptionsArea(
                  options: puzzle.options!,
                  onSelected: _handleSubmit,
                ),
              const SizedBox(height: 24),
              _HintSection(playState: playState),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreeInputArea extends StatelessWidget {
  const _FreeInputArea({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '答えを入力してください',
            prefixIcon: Icon(Icons.edit_rounded),
          ),
          onSubmitted: onSubmit,
        ),
        const SizedBox(height: 12),
        Tooltip(
          message: '入力した答えを送信します',
          child: ElevatedButton.icon(
            onPressed: () => onSubmit(controller.text),
            icon: const Icon(Icons.send_rounded),
            label: const Text('こたえる'),
          ),
        ),
      ],
    );
  }
}

class _OptionsArea extends StatelessWidget {
  const _OptionsArea({required this.options, required this.onSelected});

  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: () => onSelected(option),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(option),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HintSection extends ConsumerWidget {
  const _HintSection({required this.playState});

  final PuzzlePlayState playState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = playState.puzzle;
    final hintLevel = playState.hintLevel;
    final hasMoreHints = hintLevel < puzzle.hints.length;
    // 最初のヒント(hintLevel==0)は無料、以降はコインを消費する。
    final nextHintCost = hintLevel == 0 ? 0 : hintCostCoins;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < hintLevel; i++)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('ヒント${i + 1}: ${puzzle.hints[i]}'),
                  ),
                ],
              ),
            ),
          ),
        if (hasMoreHints)
          Tooltip(
            message: nextHintCost == 0
                ? '無料で次のヒントを表示します'
                : '$nextHintCostコインを消費して次のヒントを表示します',
            child: OutlinedButton.icon(
              onPressed: () {
                final revealed =
                    ref.read(gameProvider.notifier).revealNextHint();
                if (!revealed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('コインが足りません。広告を見てコインを獲得しよう！')),
                  );
                }
              },
              icon: const Icon(Icons.lightbulb_outline_rounded),
              label: Text(
                nextHintCost == 0
                    ? 'ヒントを見る (${hintLevel + 1}/${puzzle.hints.length}) ・無料'
                    : 'ヒントを見る (${hintLevel + 1}/${puzzle.hints.length}) ・$nextHintCostコイン',
              ),
            ),
          ),
      ],
    );
  }
}
