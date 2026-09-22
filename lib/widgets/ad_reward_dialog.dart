import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/progress_provider.dart';

/// 「広告視聴風」のモックダイアログ。
/// 実際の広告SDKは統合せず、数秒待ってからコインを付与するシミュレーションを行う。
class AdRewardDialog extends ConsumerStatefulWidget {
  const AdRewardDialog({super.key});

  /// ダイアログを表示する。
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdRewardDialog(),
    );
  }

  @override
  ConsumerState<AdRewardDialog> createState() => _AdRewardDialogState();
}

enum _AdState { idle, playing, rewarded }

class _AdRewardDialogState extends ConsumerState<AdRewardDialog> {
  _AdState _state = _AdState.idle;

  Future<void> _watchAd() async {
    setState(() => _state = _AdState.playing);
    // 実際の広告SDKの代わりに数秒待つモック処理。
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await ref.read(progressProvider.notifier).addCoinsFromAd();
    if (!mounted) return;
    setState(() => _state = _AdState.rewarded);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('広告を見てコインを獲得'),
      content: switch (_state) {
        _AdState.idle => const Text(
            '広告（モック）を視聴すると、コインが $coinsPerAdView 枚もらえます。\n'
            '※本実装ではテスト用のシミュレーションです。',
          ),
        _AdState.playing => const SizedBox(
            height: 80,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('広告を再生中...'),
                ],
              ),
            ),
          ),
        _AdState.rewarded => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text('コインを $coinsPerAdView 枚獲得しました！'),
            ],
          ),
      },
      actions: [
        if (_state == _AdState.idle)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('やめる'),
          ),
        if (_state == _AdState.idle)
          FilledButton.icon(
            onPressed: _watchAd,
            icon: const Icon(Icons.play_circle_rounded),
            label: const Text('広告を見る'),
          ),
        if (_state == _AdState.rewarded)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
      ],
    );
  }
}
