import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // オンボーディング表示済みとしてタイトル画面から始まるようにする
    // （オンボーディング自体のテストは onboarding_and_notification_test.dart 等を参照）。
    // languageCode を明示的に 'ja' に固定し、テスト実行環境のロケール設定に
    // 依存せず常に日本語UIでテストできるようにする。
    SharedPreferences.setMockInitialValues({
      'nazodarake_progress_v1': jsonEncode({
        'hasSeenOnboarding': true,
        'languageCode': 'ja',
      }),
    });
  });

  testWidgets('タイトル画面が表示される', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NazodarakeApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('なぞだらけ'), findsOneWidget);
    expect(find.text('ゲームをはじめる'), findsOneWidget);
  });

  testWidgets('「ゲームをはじめる」を押すとステージ選択画面に遷移する', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NazodarakeApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ゲームをはじめる'));
    await tester.pumpAndSettle();

    expect(find.text('ステージ選択'), findsOneWidget);
    expect(find.textContaining('ステージ 1'), findsOneWidget);
  });

  testWidgets('統計画面に遷移できる', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NazodarakeApp()),
    );
    await tester.pumpAndSettle();

    // タイトル画面のボタン数が多く、テスト用ビューポートでは
    // 「統計を見る」が画面外にあるためスクロールしてから操作する。
    await tester.ensureVisible(find.text('統計を見る'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('統計を見る'));
    await tester.pumpAndSettle();

    expect(find.text('統計'), findsWidgets);
    expect(find.textContaining('クリア数'), findsOneWidget);
  });
}
