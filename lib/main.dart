import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/progress_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/achievements_screen.dart';
import 'widgets/onboarding_screen.dart';
import 'widgets/title_screen.dart';

void main() {
  runApp(const ProviderScope(child: NazodarakeApp()));
}

/// アプリ全体で共有する ScaffoldMessenger のキー。
/// [AchievementPopupListener] のように `MaterialApp.builder` の外側から
/// SnackBar を表示したい場合に、context に依存せずアクセスするために使う。
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// なぞだらけ アプリのルートウィジェット。
class NazodarakeApp extends StatelessWidget {
  const NazodarakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'なぞだらけ',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) =>
          AchievementPopupListener(child: child ?? const SizedBox.shrink()),
      home: const AppEntryPoint(),
    );
  }
}

/// アプリ起動直後のエントリーポイント。
///
/// [ProgressState] は shared_preferences から非同期にロードされるため、
/// ロード完了まではタイトル画面を表示し、初回起動（[ProgressState.hasSeenOnboarding]
/// が false）の場合のみオンボーディングを挟む。
class AppEntryPoint extends ConsumerWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSeenOnboarding = ref.watch(
      progressProvider.select((state) => state.hasSeenOnboarding),
    );
    if (!hasSeenOnboarding) {
      return OnboardingScreen(
        onFinished: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const TitleScreen()),
          );
        },
      );
    }
    return const TitleScreen();
  }
}
