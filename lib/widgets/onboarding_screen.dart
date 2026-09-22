import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/story_data.dart';
import '../providers/progress_provider.dart';

/// オンボーディングの1スライド分のデータ。
class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

const List<_OnboardingSlide> _slides = [
  _OnboardingSlide(
    icon: Icons.extension_rounded,
    title: 'ようこそ、なぞだらけへ！',
    description:
        'なぞなぞ・暗号解読・観察系・ひらめき・計算パズル・言葉遊び・論理パズルなど、'
        '7ジャンルの謎が全150問以上楽しめる謎解きゲームです。',
  ),
  _OnboardingSlide(
    icon: Icons.lightbulb_rounded,
    title: 'ヒント機能',
    description:
        '悩んだときは、問題画面のヒントボタンをタップ。'
        '1つ目のヒントは無料、2つ目以降はコインを使って開放できます。',
  ),
  _OnboardingSlide(
    icon: Icons.monetization_on_rounded,
    title: 'コインでできること',
    description:
        '謎をクリアするとコインを獲得できます。'
        'ヒントの開放や、ステージ6以降のアンロックにコインを使いましょう。'
        '広告視聴（モック）でコインを増やすこともできます。',
  ),
  _OnboardingSlide(
    icon: Icons.today_rounded,
    title: 'デイリーチャレンジ・実績',
    description:
        '毎日1問挑戦できる「デイリーチャレンジ」で連続記録に挑戦しよう。'
        'ナゾウと一緒に、実績コンプリートを目指してみてね！',
  ),
];

/// 初回起動時（または設定画面からの再表示）に表示するチュートリアル画面。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.isReplay = false, this.onFinished});

  /// 設定画面からの再表示かどうか（true の場合は完了時に単に画面を閉じる）。
  final bool isReplay;

  /// 初回起動フローで、完了後に次の画面へ遷移するためのコールバック。
  final VoidCallback? onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!widget.isReplay) {
      await ref.read(progressProvider.notifier).markOnboardingSeen();
    }
    if (!mounted) return;
    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.isReplay)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('スキップ'),
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          slide.icon,
                          size: 96,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (index == 0) ...[
                          const SizedBox(height: 12),
                          Text(
                            'ナビゲーター: $navigatorName',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentPage ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(isLast ? 'はじめる' : '次へ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
