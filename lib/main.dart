import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'widgets/title_screen.dart';

void main() {
  runApp(const ProviderScope(child: NazodarakeApp()));
}

/// なぞだらけ アプリのルートウィジェット。
class NazodarakeApp extends StatelessWidget {
  const NazodarakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'なぞだらけ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const TitleScreen(),
    );
  }
}
