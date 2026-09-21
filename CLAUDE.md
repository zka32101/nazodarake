# Claude.md - nazodarake (なぞだらけ)

## プロジェクト概要

「なぞだらけ」は、なぞなぞ・暗号解読・観察系・ひらめき・計算パズル・言葉遊び・論理パズルなど複数ジャンルの謎を楽しめる謎解きゲームアプリです。Phase 2 でコイン経済・ストーリー演出・SNSシェア・デイリーチャレンジ・実績システムを追加し、コンテンツも100問・11ステージに拡張しました。

- **言語**: Dart (Flutter)
- **状態管理**: Riverpod (flutter_riverpod)
- **構成**: 単一 Flutter アプリ
- **主な用途**: 謎解き・脳トレゲームの提供

姉妹プロジェクトである `yourwish`（SNS配信ゲーム群）・`shared_core`（学習系アプリ共通パッケージ）と技術スタックの親和性を持たせるため、同じく Flutter + Riverpod で実装しています。

## ディレクトリ構成

```
nazodarake/
├── lib/
│   ├── main.dart                       # アプリエントリポイント・テーマ設定・実績ポップアップ配線
│   ├── models/
│   │   ├── puzzle_model.dart           # Puzzle モデル・ジャンル/難易度Enum・正誤判定
│   │   └── achievement_model.dart      # Achievement 定義(10種)・達成判定ロジック
│   ├── data/
│   │   ├── puzzles_data.dart           # 謎解きコンテンツ本体(100問、11ステージ)
│   │   └── story_data.dart             # ナビゲーターキャラ「ナゾウ」・ステージ導入ストーリー
│   ├── providers/
│   │   ├── game_provider.dart          # 出題中の状態管理・ステージ解放判定・ヒントのコイン消費
│   │   ├── progress_provider.dart      # 進捗・コイン・実績・デイリーストリークの永続化
│   │   ├── achievement_provider.dart   # 実績の自動判定・ポップアップ通知用 StateNotifier
│   │   └── daily_challenge_provider.dart # 日付ベースで決定的にデイリー問題を選ぶロジック
│   ├── theme/
│   │   └── app_theme.dart              # Material3 テーマ(ライト/ダーク)
│   └── widgets/
│       ├── title_screen.dart           # タイトル画面(コイン表示・各モードへの導線)
│       ├── stage_select_screen.dart    # ステージ選択・クリア状況・コインアンロックUI
│       ├── puzzle_screen.dart          # 謎解き画面(問題・ヒント・回答・コイン表示)
│       ├── result_screen.dart          # 正解演出・解説表示・SNSシェアボタン
│       ├── daily_challenge_screen.dart # デイリーチャレンジ専用画面
│       ├── achievements_screen.dart    # 実績一覧・達成時ポップアップ(AchievementPopupListener)
│       ├── story_intro_dialog.dart     # ステージ導入時のミニストーリーダイアログ
│       ├── ad_reward_dialog.dart       # 広告視聴(モック)によるコイン獲得ダイアログ
│       ├── settings_screen.dart        # 設定(効果音・進捗リセット)
│       └── stats_screen.dart           # 統計(クリア数・正答率・コイン・実績数等)
├── test/                               # モデル・プロバイダー・ウィジェットテスト
├── pubspec.yaml
├── analysis_options.yaml
├── CLAUDE.md                           # このファイル
└── README.md                           # プロジェクト説明
```

## 主要機能

### 1. Puzzle モデル (`lib/models/puzzle_model.dart`)

1問分の謎データを表す不変クラス。`PuzzleGenre`（なぞなぞ/暗号解読/観察系/ひらめき/計算パズル/言葉遊び/論理パズル）と `PuzzleDifficulty`（easy/normal/hard）を持ち、`isCorrect()` で表記ゆれ（前後空白・全角/半角スペース・大文字小文字）を吸収した正誤判定を行う。

### 2. GameNotifier (`lib/providers/game_provider.dart`)

出題中の状態（現在の問題、ヒント開示段階、直前の正誤フィードバック）を管理する `StateNotifier`。正解・不正解・ヒント使用の度に `progressProvider` へ記録を委譲する。`revealNextHint()` は最初のヒントは無料、2つ目以降はコインが不足していると `false` を返して開放しない。ステージのアンロック判定（クリア判定＋コインアンロック判定）・クリア済み判定・クリア数もこのファイルの Provider 群で提供する。

### 3. ProgressNotifier (`lib/providers/progress_provider.dart`)

`shared_preferences` を使い、クリア済み問題ID・ヒント使用回数・正誤カウント・効果音設定に加えて、コイン残高・コインでアンロック済みのステージ・獲得済み実績ID・連続正解記録・デイリーチャレンジのストリークと履歴を JSON でシリアライズして永続化する。

主なメソッド:
- `markCleared(id)`: クリア記録＋コイン加算＋連続正解カウント更新
- `canAffordHint(hintLevel)` / `spendCoinsForHint(hintLevel)`: ヒントのコイン消費判定・実消費
- `addCoinsFromAd()`: 広告視聴（モック）によるコイン付与
- `unlockStageWithCoins(stage)`: コインを消費してステージ6以降をアンロック
- `recordDailyChallengeCleared(today, yesterday)`: デイリーチャレンジのストリーク更新
- `unlockAchievements(ids)`: 実績IDの永続化

### 4. コイン/課金要素

- 謎を1問クリアするごとに `coinsPerClear`(10)コインを獲得
- ヒントは1つ目無料、2つ目以降は `hintCostCoins`(5)コインを消費
- 「広告を見てコインを獲得」ダイアログ（`ad_reward_dialog.dart`）は実際の広告SDKを統合せず、数秒待機後に `coinsPerAdView`(30)コインを付与するモック処理
- ステージ6以降は `stageUnlockCost(stage)` = `50 × (stage - 5)` コインでアンロック可能（前ステージのクリアも必要）

### 5. ストーリー/世界観 (`lib/data/story_data.dart`, `lib/widgets/story_intro_dialog.dart`)

ナビゲーターキャラクター「ナゾウ」（なぞだらけの島に住むフクロウ）が同行する設定。各ステージ挑戦前に `StoryIntroDialog` でミニストーリーを表示し、タイトル画面にもストーリー性のあるキャッチコピーを表示する。

### 6. SNSシェア機能 (`lib/widgets/result_screen.dart`)

`share_plus` パッケージの `SharePlus.instance.share(ShareParams(text: ...))` を用いて、結果画面からクリア結果をテキストでシェアできる。

### 7. デイリーチャレンジ (`lib/providers/daily_challenge_provider.dart`, `lib/widgets/daily_challenge_screen.dart`)

`dailyPuzzleForDate(date)` が日付から決定的なシード値を計算し、`allPuzzles` から1問を選ぶ（同じ日は必ず同じ問題）。クリアすると `recordDailyChallengeCleared` で連続挑戦日数（ストリーク）を更新する。前日にもクリアしていればストリーク加算、そうでなければ1にリセット。

### 8. 実績/バッジシステム (`lib/models/achievement_model.dart`, `lib/providers/achievement_provider.dart`, `lib/widgets/achievements_screen.dart`)

`allAchievements` に10種類の実績を定義（初クリア／ステージ1制覇／ノーヒントクリア／10問連続正解／全ジャンル制覇／50問クリア／全100問クリア／デイリー7日連続／コイン500枚所持／ステージ10クリア）。`evaluateNewlyUnlockedAchievements(state)` が純粋関数として新規達成分のIDを返し、`AchievementNotifier` が `progressProvider` の変化を監視して自動的に永続化・ポップアップ表示のトリガーを行う。`AchievementPopupListener` を `main.dart` の `MaterialApp.builder` に配線し、アプリ全体のどの画面でも達成通知が表示されるようにしている。

### 9. コンテンツ (`lib/data/puzzles_data.dart`)

- ステージ1〜5: 8問×5ステージ＝40問（初期リリース分）
- ステージ6〜11: 10問×6ステージ＝60問（Phase 2 追加分。ステージ11はボーナスステージ）
- 合計 **100問・11ステージ**

各問題は `question`（問題文）、`answer`（正解）、`hints`（段階的ヒントのリスト）、`difficulty`、`genre`、任意で `options`（選択肢）・`explanation`（解説）を持つ。

### 10. UI コンポーネント (`lib/widgets/`)

- `title_screen.dart`: ナビゲーター名・コイン残高表示、ゲーム開始・デイリーチャレンジ・実績・統計・設定への導線
- `stage_select_screen.dart`: ステージごとのクリア状況・アンロック状況・コインアンロックボタンを表示
- `puzzle_screen.dart`: 問題表示、自由入力/選択肢の回答UI、段階的ヒントボタン（コインコスト表示）、コイン残高表示
- `result_screen.dart`: 正解時のアニメーション演出・解説表示・SNSシェアボタン・次の問題への導線
- `daily_challenge_screen.dart`: 日替わり問題の出題・ストリーク表示
- `achievements_screen.dart`: 実績一覧(獲得済み/未獲得)・達成時ポップアップ配線用ウィジェット
- `story_intro_dialog.dart`: ステージ導入時のミニストーリー表示
- `ad_reward_dialog.dart`: 広告視聴(モック)ダイアログ
- `settings_screen.dart`: 効果音のオン/オフ、進捗リセット
- `stats_screen.dart`: クリア数・正答率・コイン・連続正解記録・デイリーストリーク・獲得実績数の統計表示

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
6. 新しいステージ（12以降）を追加する場合は、`stageIntroStory`（`lib/data/story_data.dart`）にミニストーリーを追加し、`stageUnlockCost`（`lib/providers/progress_provider.dart`）の費用体系との整合性を確認する

### 設計原則

- **状態管理は Riverpod に統一**: `StateNotifierProvider` を用い、UI とロジックを分離する
- **永続化は shared_preferences 経由のみ**: 進捗・コイン・実績・デイリーストリークは `ProgressNotifier` を通じてのみ読み書きする
- **謎データはイミュータブル**: `Puzzle` は `const` コンストラクタを持つ不変クラスとして扱う
- **正誤判定はモデル側に集約**: 表記ゆれの吸収ロジックは `Puzzle.isCorrect()` に閉じ込め、UI 側では直接文字列比較しない
- **実績判定は純粋関数に集約**: `evaluateNewlyUnlockedAchievements()` はUIやI/Oに依存しない純粋関数とし、テストしやすくする
- **日付ロジックは決定的に**: デイリーチャレンジの出題は `DateTime` から導出したシード値のみに依存し、同じ日付なら同じ結果になることを保証する

## 参考にした競合アプリ

- 東京謎解きゲーム
- なぞとも
- Wonderland

これらのアプリを比較し、コンテンツ量（100問・11ステージ）、段階的ヒント、ステージ制進行、複数ジャンル（7ジャンル）、ローカル進捗保存、正解演出、統計画面に加えて、コイン経済・広告リワード・ステージのコインアンロック・ストーリー演出・SNSシェア・デイリーチャレンジ・実績システムを実装し、機能面での差別化を図っています。

## 実装状況

| 機能 | 状態 |
|---|---|
| Puzzleモデル・正誤判定 | ✅ 完成 |
| 謎解きコンテンツ(100問・11ステージ) | ✅ 完成 |
| GameNotifier(出題・ヒント・正誤・コイン消費) | ✅ 完成 |
| ProgressNotifier(ローカル永続化・コイン・実績・デイリー) | ✅ 完成 |
| コイン経済(クリア報酬・広告リワード・ステージアンロック) | ✅ 完成 |
| ストーリー/世界観(ナビゲーター・ステージ導入ストーリー) | ✅ 完成 |
| SNSシェア機能(share_plus) | ✅ 完成 |
| デイリーチャレンジ(決定的出題・ストリーク) | ✅ 完成 |
| 実績/バッジシステム(10種・自動判定・ポップアップ) | ✅ 完成 |
| タイトル/ステージ選択/謎解き/結果/デイリー/実績/設定/統計画面 | ✅ 完成 |
| ライト/ダークテーマ | ✅ 完成 |
| モデル・プロバイダー・ウィジェットテスト | ✅ 完成 |

**最終更新**: 2026-09-21
