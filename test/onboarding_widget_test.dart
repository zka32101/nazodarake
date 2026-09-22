import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // 初回起動を想定し、進捗データなし（オンボーディング未表示）の状態にする。
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('初回起動時はオンボーディングが表示され、完了するとタイトル画面に遷移する', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NazodarakeApp()),
    );
    await tester.pumpAndSettle();

    // オンボーディングの1枚目が表示されている。
    expect(find.text('ようこそ、なぞだらけへ！'), findsOneWidget);
    expect(find.text('なぞだらけ'), findsNothing);

    // 「スキップ」でタイトル画面へ。
    await tester.tap(find.text('スキップ'));
    await tester.pumpAndSettle();

    expect(find.text('なぞだらけ'), findsOneWidget);
    expect(find.text('ゲームをはじめる'), findsOneWidget);
  });

  testWidgets('次へボタンでスライドを進められ、最後で「はじめる」に変わる', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NazodarakeApp()),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();
    }

    expect(find.text('はじめる'), findsOneWidget);
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();

    expect(find.text('ゲームをはじめる'), findsOneWidget);
  });
}
