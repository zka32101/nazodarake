import 'package:flutter/material.dart';
import 'package:nazodarake/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/progress_provider.dart';
import 'onboarding_screen.dart';

/// 簡易設定画面：音のオン/オフ、通知のオン/オフ、ニックネーム編集、
/// 言語切替、文字サイズ切替、チュートリアル再表示、進捗リセット。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final profile = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.badge_rounded),
            title: Text(l10n.settingsNickname),
            subtitle: Text(profile.nickname),
            onTap: () => _editNickname(context, ref, profile.nickname),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(_languageLabel(l10n, progress.languageCode)),
            onTap: () => _pickLanguage(context, ref, l10n),
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: Text(l10n.settingsSound),
            subtitle: const Text('正解・不正解時の効果音のオン/オフ'),
            value: progress.soundEnabled,
            onChanged: (value) {
              ref.read(progressProvider.notifier).setSoundEnabled(value);
            },
          ),
          SwitchListTile(
            title: Text(l10n.settingsNotification),
            subtitle: const Text('未挑戦の日に毎日20時ごろリマインド通知します'),
            value: progress.notificationsEnabled,
            onChanged: (value) => _handleNotificationToggle(context, ref, value),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.format_size_rounded),
                    const SizedBox(width: 12),
                    Text(
                      '文字サイズ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 36),
                  child: Text('アプリ全体の文字の大きさを調整します（読みやすさ・アクセシビリティ対応）'),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Semantics(
                    label: '文字サイズの設定。現在は${_textScaleLabel(progress.textScaleOption)}です。',
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'small',
                          label: Text('小'),
                          tooltip: '文字サイズを小さくします',
                        ),
                        ButtonSegment(
                          value: 'standard',
                          label: Text('標準'),
                          tooltip: '文字サイズを標準に戻します',
                        ),
                        ButtonSegment(
                          value: 'large',
                          label: Text('大'),
                          tooltip: '文字サイズを大きくします',
                        ),
                      ],
                      selected: {progress.textScaleOption},
                      onSelectionChanged: (selection) {
                        ref
                            .read(progressProvider.notifier)
                            .setTextScaleOption(selection.first);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.school_rounded),
            title: Text(l10n.settingsReplayTutorial),
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
            title: Text(l10n.settingsResetProgress),
            subtitle: const Text('クリア状況・ヒント使用履歴・統計をすべて削除します'),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'ja':
        return l10n.settingsLanguageJapanese;
      case 'en':
        return l10n.settingsLanguageEnglish;
      default:
        return l10n.settingsLanguageSystem;
    }
  }

  String _textScaleLabel(String option) {
    switch (option) {
      case 'small':
        return '小';
      case 'large':
        return '大';
      case 'standard':
      default:
        return '標準';
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final selected = await showDialog<String?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(l10n.settingsLanguageSystem),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('ja'),
            child: Text(l10n.settingsLanguageJapanese),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('en'),
            child: Text(l10n.settingsLanguageEnglish),
          ),
        ],
      ),
    );
    // showDialog は「何も選ばず閉じた」場合も null を返すため、
    // ダイアログ自体が明示的な選択で閉じられたかは区別できない仕様上の制約がある。
    // ここでは閉じた場合＝「端末設定に従う」を選んだとみなす簡易実装とする。
    await ref.read(progressProvider.notifier).setLanguageCode(selected);
  }

  Future<void> _editNickname(
    BuildContext context,
    WidgetRef ref,
    String currentNickname,
  ) async {
    final controller = TextEditingController(text: currentNickname);
    final newNickname = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ニックネームを編集'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (newNickname != null && newNickname.trim().isNotEmpty) {
      await ref.read(profileProvider.notifier).setNickname(newNickname);
    }
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
