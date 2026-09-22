import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';
import '../providers/progress_provider.dart';
import 'onboarding_screen.dart';

/// 簡易設定画面：音のオン/オフ、通知のオン/オフ、チュートリアル再表示、進捗リセット。
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
          SwitchListTile(
            title: const Text('デイリーチャレンジ通知'),
            subtitle: const Text('未挑戦の日に毎日20時ごろリマインド通知します'),
            value: progress.notificationsEnabled,
            onChanged: (value) => _handleNotificationToggle(context, ref, value),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.school_rounded),
            title: const Text('あそびかたをもう一度見る'),
            subtitle: const Text('初回起動時のチュートリアルを再表示します'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(isReplay: true),
                ),
              );
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

  Future<void> _handleNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final controller = ref.read(notificationControllerProvider);
    if (value) {
      final granted = await controller.enable();
      if (!granted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('通知の権限が許可されなかったため、有効にできませんでした')),
        );
      }
    } else {
      await controller.disable();
    }
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
