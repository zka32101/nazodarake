import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/progress_provider.dart';

/// 簡易設定画面：音のオン/オフ、進捗リセット。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('効果音'),
            subtitle: const Text('正解・不正解時の効果音のオン/オフ'),
            value: progress.soundEnabled,
            onChanged: (value) {
              ref.read(progressProvider.notifier).setSoundEnabled(value);
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: const Text('進捗をリセット'),
            subtitle: const Text('クリア状況・ヒント使用履歴・統計をすべて削除します'),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('進捗をリセットしますか？'),
        content: const Text('この操作は取り消せません。すべてのクリア状況が失われます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('リセットする'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(progressProvider.notifier).resetProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('進捗をリセットしました')),
        );
      }
    }
  }
}
