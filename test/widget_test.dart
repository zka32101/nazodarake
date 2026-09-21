import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

    await tester.tap(find.text('統計を見る'));
    await tester.pumpAndSettle();

    expect(find.text('統計'), findsWidgets);
    expect(find.textContaining('クリア数'), findsOneWidget);
  });
}
