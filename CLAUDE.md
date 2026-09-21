# Claude.md - nazodarake (なぞだらけ)

## プロジェクト概要

「なぞだらけ」は、なぞなぞ・暗号解読・観察系・ひらめき・計算パズルなど複数ジャンルの謎を楽しめる謎解きゲームアプリです。

- **言語**: Dart (Flutter)
- **状態管理**: Riverpod (flutter_riverpod)
- **構成**: 単一 Flutter アプリ
- **主な用途**: 謎解き・脳トレゲームの提供

姉妹プロジェクトである `yourwish`（SNS配信ゲーム群）・`shared_core`（学習系アプリ共通パッケージ）と技術スタックの親和性を持たせるため、同じく Flutter + Riverpod で実装しています。

## ディレクトリ構成

```
nazodarake/
├── lib/
│   ├── main.dart                     # アプリエントリポイント・テーマ設定
│   ├── models/
│   │   └── puzzle_model.dart         # Puzzle モデル・ジャンル/難易度Enum・正誤判定
│   ├── data/
│   │   └── puzzles_data.dart         # 謎解きコンテンツ本体(40問、5ステージ)
│   ├── providers/
│   │   ├── game_provider.dart        # 出題中の状態管理・ステージ解放判定
│   │   └── progress_provider.dart    # shared_preferences によるローカル進捗永続化
│   ├── theme/
│   │   └── app_theme.dart            # Material3 テーマ(ライト/ダーク)
│   └── widgets/
│       ├── title_screen.dart         # タイトル画面
│       ├── stage_select_screen.dart  # ステージ選択・クリア状況表示
│       ├── puzzle_screen.dart        # 謎解き画面(問題・ヒント・回答)
│       ├── result_screen.dart        # 正解演出・解説表示
│       ├── settings_screen.dart      # 設定(効果音・進捗リセット)
│       └── stats_screen.dart         # 統計(クリア数・正答率等)
├── test/                             # モデル・プロバイダー・ウィジェットテスト
├── pubspec.yaml
├── analysis_options.yaml
├── CLAUDE.md                         # このファイル
└── README.md                         # プロジェクト説明
```

## 主要機能

### 1. Puzzle モデル (`lib/models/puzzle_model.dart`)

1問分の謎データを表す不変クラス。`PuzzleGenre`（なぞなぞ/暗号解読/観察系/ひらめき/計算パズル）と `PuzzleDifficulty`（easy/normal/hard）を持ち、`isCorrect()` で表記ゆれ（前後空白・全角/半角スペース・大文字小文字）を吸収した正誤判定を行う。

### 2. GameNotifier (`lib/providers/game_provider.dart`)

出題中の状態（現在の問題、ヒント開示段階、直前の正誤フィードバック）を管理する `StateNotifier`。正解・不正解・ヒント使用の度に `progressProvider` へ記録を委譲する。ステージのアンロック判定・クリア済み判定・クリア数もこのファイルの Provider 群で提供する。

使用例:
```dart
ref.read(gameProvider.notifier).startPuzzle(puzzle);
final correct = ref.read(gameProvider.notifier).submitAnswer(userInput);
ref.read(gameProvider.notifier).revealNextHint();
```

### 3. ProgressNotifier (`lib/providers/progress_provider.dart`)

`shared_preferences` を使い、クリア済み問題ID・ヒント使用回数・正誤カウント・効果音設定を JSON でシリアライズして永続化する。アプリを再起動しても進捗が保持される。

### 4. コンテンツ (`lib/data/puzzles_data.dart`)

5ステージ×8問＝40問の謎解きコンテンツ。各問題は `question`（問題文）、`answer`（正解）、`hints`（段階的ヒントのリスト）、`difficulty`、`genre`、任意で `options`（選択肢）・`explanation`（解説）を持つ。

### 5. UI コンポーネント (`lib/widgets/`)

- `title_screen.dart`: ゲーム開始・統計・設定への導線
- `stage_select_screen.dart`: ステージごとのクリア状況・アンロック状況を表示
- `puzzle_screen.dart`: 問題表示、自由入力/選択肢の回答UI、段階的ヒントボタン、不正解時のフィードバック表示
- `result_screen.dart`: 正解時のアニメーション演出・解説表示・次の問題への導線
- `settings_screen.dart`: 効果音のオン/オフ、進捗リセット
- `stats_screen.dart`: クリア数・正答率・正解/不正解回数・ヒント使用回数の統計表示

## セットアップ

```bash
flutter pub get
flutter run
```

## 開発ガイド

### テスト実行

```bash
flutter analyze
flutter test
```

### 新しい謎を追加する場合

1. `lib/data/puzzles_data.dart` の `allPuzzles` リストに `Puzzle` インスタンスを追加する
2. `id` は `s<ステージ番号>_<連番>` の形式で一意にする
3. `hints` は最低1つ以上、段階的に答えに近づく内容にする
4. 選択肢形式の場合は `options` に正解を必ず含める
5. `test/puzzle_model_test.dart` のデータセット系テストが通ることを確認する

### 設計原則

- **状態管理は Riverpod に統一**: `StateNotifierProvider` を用い、UI とロジックを分離する
- **永続化は shared_preferences 経由のみ**: 進捗データは `ProgressNotifier` を通じてのみ読み書きする
- **謎データはイミュータブル**: `Puzzle` は `const` コンストラクタを持つ不変クラスとして扱う
- **正誤判定はモデル側に集約**: 表記ゆれの吸収ロジックは `Puzzle.isCorrect()` に閉じ込め、UI 側では直接文字列比較しない

## 参考にした競合アプリ

- 東京謎解きゲーム
- なぞとも
- Wonderland

これらのアプリを参考に、段階的ヒント・ステージ制進行・複数ジャンルの謎・ローカル進捗保存・正解演出・統計画面などの機能を実装しています。

## 実装状況

| 機能 | 状態 |
|---|---|
| Puzzleモデル・正誤判定 | ✅ 完成 |
| 謎解きコンテンツ(40問・5ステージ) | ✅ 完成 |
| GameNotifier(出題・ヒント・正誤) | ✅ 完成 |
| ProgressNotifier(ローカル永続化) | ✅ 完成 |
| タイトル/ステージ選択/謎解き/結果/設定/統計画面 | ✅ 完成 |
| ライト/ダークテーマ | ✅ 完成 |
| モデル・プロバイダー・ウィジェットテスト | ✅ 完成 |

**最終更新**: 2026-09-21
