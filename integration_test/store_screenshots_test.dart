// ストア掲載用スクリーンショットの自動生成テスト。
//
// 主要画面（タイトル・ステージ選択・謎解き・結果・実績・統計・ランキング）を
// flutter_test の `matchesGoldenFile` 機構で PNG として書き出す仅組み。
//
// 【重要】このファイルは `integration_test/` 配下に置いており、
// `flutter test`（引数なし）では `test/` ディレクトリしか走査されないため
// CI (`.github/workflows/flutter-ci.yaml`) では実行されない。
// ゴールデン画像の比較は環境（フォント・ OS等）依存で不安定になりやすいため、
// このテストはあくまで「新規生成モード」での実行を主目的としている。
//
// 使い方は docs/store_listing.md を参照。
//
// 生成（更新）コマンド:
//   flutter test integration_test/store_screenshots_test.dart --update-goldens
//
// 生成された PNG は
//   integration_test/failures/ (比較失敗時)
//   または --update-goldens 実行時は各テストファイル横の
//   `goldens/` ディレクトリに保存される。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:nazodarake/data/puzzles_data.dart';
import 'package:nazodarake/l10n/generated/app_localizations.dart';
import 'package:nazodarake/theme/app_theme.dart';
import 'package:nazodarake/widgets/achievements_screen.dart';
import 'package:nazodarake/widgets/puzzle_screen.dart';
import 'package:nazodarake/widgets/ranking_screen.dart';
import 'package:nazodarake/widgets/result_screen.dart';
import 'package:nazodarake/widgets/stage_select_screen.dart';
import 'package:nazodarake/widgets/stats_screen.dart';
import 'package:nazodarake/widgets/title_screen.dart';

/// ストアスクリーンショット想定サイズ（スマートフォン縦向き相当）。
const _screenshotSize = Size(414, 896);

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('ja'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

Future<void> _captureScreen(
  WidgetTester tester,
  Widget screen,
  String goldenName,
) async {
  tester.view.physicalSize = _screenshotSize * tester.view.devicePixelRatio;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_wrap(screen));
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$goldenName.png'),
  );
}

void main() {
  group('ストア掲載用スクリーンショット', () {
    testWidgets('タイトル画面', (tester) async {
      await _captureScreen(tester, const TitleScreen(), 'title_screen');
    });

    testWidgets('ステージ選択画面', (tester) async {
      await _captureScreen(
        tester,
        const StageSelectScreen(),
        'stage_select_screen',
      );
    });

    testWidgets('謎解き画面', (tester) async {
      await _captureScreen(
        tester,
        PuzzleScreen(puzzles: [allPuzzles.first]),
        'puzzle_screen',
      );
    });

    testWidgets('結果画面', (tester) async {
      await _captureScreen(
        tester,
        ResultScreen(puzzle: allPuzzles.first, isLastPuzzle: false),
        'result_screen',
      );
    });

    testWidgets('実績画面', (tester) async {
      await _captureScreen(
        tester,
        const AchievementsScreen(),
        'achievements_screen',
      );
    });

    testWidgets('統計画面', (tester) async {
      await _captureScreen(tester, const StatsScreen(), 'stats_screen');
    });

    testWidgets('ランキング画面', (tester) async {
      await _captureScreen(tester, const RankingScreen(), 'ranking_screen');
    });
  });
}
