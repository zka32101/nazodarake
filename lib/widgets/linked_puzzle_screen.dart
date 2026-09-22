import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/linked_puzzle_model.dart';
import '../providers/linked_puzzle_provider.dart';
import '../providers/progress_provider.dart';

/// 連動謎（ボーナスステージ）の画面。
///
/// 複数の断片謎を順番に解き、得られた文字を組み合わせて
/// 最終回答を導く。
class LinkedPuzzleScreen extends ConsumerStatefulWidget {
  const LinkedPuzzleScreen({super.key, required this.set});

  final LinkedPuzzleSet set;

  @override
  ConsumerState<LinkedPuzzleScreen> createState() =>
      _LinkedPuzzleScreenState();
}

class _LinkedPuzzleScreenState extends ConsumerState<LinkedPuzzleScreen> {
  final TextEditingController _fragmentController = TextEditingController();
  final TextEditingController _finalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(linkedPuzzleProvider.notifier).startSet(widget.set);
    });
  }

  @override
  void dispose() {
    _fragmentController.dispose();
    _finalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playState = ref.watch(linkedPuzzleProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (playState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.set.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.set.description),
              const SizedBox(height: 16),
              _FragmentProgressRow(
                total: widget.set.fragments.length,
                clearedCount: playState.currentIndex,
              ),
              const SizedBox(height: 20),
              if (playState.isFinalSolved)
                _FinalSolvedCard(set: widget.set)
              else if (playState.allFragmentsCleared)
                _FinalAnswerArea(
                  controller: _finalController,
                  isWrongFeedback: playState.isFinalWrongFeedback,
                  onSubmit: () {
                    ref
                        .read(linkedPuzzleProvider.notifier)
                        .submitFinalAnswer(_finalController.text);
                  },
                )
              else if (playState.currentFragment != null)
                _FragmentArea(
                  fragment: playState.currentFragment!,
                  controller: _fragmentController,
                  isWrongFeedback: playState.isWrongFeedback,
                  colorScheme: colorScheme,
                  onSubmit: () {
                    final correct = ref
                        .read(linkedPuzzleProvider.notifier)
                        .submitFragmentAnswer(_fragmentController.text);
                    if (correct) {
                      _fragmentController.clear();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FragmentProgressRow extends StatelessWidget {
  const _FragmentProgressRow({required this.total, required this.clearedCount});

  final int total;
  final int clearedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              i < clearedCount
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: i < clearedCount ? Colors.green : null,
            ),
          ),
        const Spacer(),
        Text('$clearedCount / $total 断片'),
      ],
    );
  }
}

class _FragmentArea extends StatelessWidget {
  const _FragmentArea({
    required this.fragment,
    required this.controller,
    required this.isWrongFeedback,
    required this.colorScheme,
    required this.onSubmit,
  });

  final LinkedFragmentPuzzle fragment;
  final TextEditingController controller;
  final bool isWrongFeedback;
  final ColorScheme colorScheme;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(fragment.genre.label)),
            Chip(label: Text(fragment.difficulty.label)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              fragment.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isWrongFeedback)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.close_rounded, color: colorScheme.onErrorContainer),
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
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '答えを入力してください',
            prefixIcon: Icon(Icons.edit_rounded),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.send_rounded),
          label: const Text('こたえる'),
        ),
      ],
    );
  }
}

class _FinalAnswerArea extends StatelessWidget {
  const _FinalAnswerArea({
    required this.controller,
    required this.isWrongFeedback,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isWrongFeedback;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '全ての断片を集めました！',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('手に入れた文字を正しい順につなげて、最終回答を入力してください。'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isWrongFeedback)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '残念、最終回答が違います。もう一度考えてみよう！',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '最終回答を入力してください',
            prefixIcon: Icon(Icons.key_rounded),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.send_rounded),
          label: const Text('最終回答する'),
        ),
      ],
    );
  }
}

class _FinalSolvedCard extends ConsumerWidget {
  const _FinalSolvedCard({required this.set});

  final LinkedPuzzleSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(progressProvider).coins;
    return Card(
      color: Colors.amber.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '正解！ 連動謎クリア！',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(set.finalExplanation),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: Colors.amber),
                const SizedBox(width: 4),
                Text('現在のコイン: $coins'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('もどる'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
