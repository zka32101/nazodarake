import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

/// アプリが対応する言語一覧（日本語・英語）。
const List<Locale> supportedLocales = [Locale('ja'), Locale('en')];

/// なぞだらけ アプリのルートウィジェット。
class NazodarakeApp extends ConsumerWidget {
  const NazodarakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 設定画面で手動選択した言語（'ja'/'en'）。null なら端末設定に従う。
    final languageCode = ref.watch(
      progressProvider.select((state) => state.languageCode),
    );
    return MaterialApp(
      title: 'なぞだらけ',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: languageCode == null ? null : Locale(languageCode),
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
