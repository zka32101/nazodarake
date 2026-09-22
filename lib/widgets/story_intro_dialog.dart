import 'package:flutter/material.dart';

import '../data/story_data.dart';

/// ステージ挑戦前に表示するミニストーリーダイアログ。
class StoryIntroDialog extends StatelessWidget {
  const StoryIntroDialog({super.key, required this.stage});

  final int stage;

  /// ダイアログを表示し、閉じられるまで待つ。
  static Future<void> show(BuildContext context, int stage) {
    return showDialog<void>(
      context: context,
      builder: (_) => StoryIntroDialog(stage: stage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.auto_stories_rounded, color: colorScheme.primary, size: 40),
      title: Text('ステージ$stage $navigatorName からの言葉'),
      content: Text(storyForStage(stage)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('挑戦する'),
        ),
      ],
    );
  }
}
