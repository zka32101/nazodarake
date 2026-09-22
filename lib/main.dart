import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'widgets/achievements_screen.dart';
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
      home: const TitleScreen(),
    );
  }
}
