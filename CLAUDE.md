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
│   ├── main.dart                       # アプリエントリポイント・オンボーディング分岐・実績ポップアップ配線
│   ├── models/
│   │   ├── puzzle_model.dart           # Puzzle モデル・ジャンル/難易度Enum・正誤判定
│   │   ├── achievement_model.dart      # Achievement 定義(10種)・達成判定ロジック
│   │   └── linked_puzzle_model.dart    # 連動謎モデル(LinkedPuzzleSet/LinkedFragmentPuzzle)
│   ├── data/
│   │   ├── puzzles_data.dart           # 謎解きコンテンツ本体(100問、11ステージ)
│   │   ├── story_data.dart             # ナビゲーターキャラ「ナゾウ」・ステージ導入ストーリー
│   │   └── linked_puzzles_data.dart    # 連動謎(ステージ12ボーナス)のデータ
│   ├── providers/
│   │   ├── game_provider.dart          # 出題中の状態管理・ステージ解放判定・ヒントのコイン消費
│   │   ├── progress_provider.dart      # 進捗・コイン・実績・デイリー・通知設定の永続化
│   │   ├── achievement_provider.dart   # 実績の自動判定・ポップアップ通知用 StateNotifier
│   │   ├── daily_challenge_provider.dart # 日付ベースで決定的にデイリー問題を選ぶロジック
│   │   ├── linked_puzzle_provider.dart # 連動謎の進行状態管理
│   │   ├── free_play_provider.dart     # フリープレイのジャンル/難易度フィルタロジック
│   │   ├── sound_provider.dart         # SoundService のDIプロバイダー
│   │   └── notification_provider.dart  # 通知トグルの操作をまとめるコントローラー
│   ├── services/
│   │   ├── sound_service.dart          # audioplayers による効果音再生(失敗時は無視)
│   │   └── notification_service.dart   # flutter_local_notifications によるリマインダー通知
│   ├── theme/
│   │   └── app_theme.dart              # Material3 テーマ(ライト/ダーク)
│   └── widgets/
│       ├── onboarding_screen.dart      # 初回起動チュートリアル(PageView 4枚)
│       ├── title_screen.dart           # タイトル画面(コイン表示・各モードへの導線)
│       ├── stage_select_screen.dart    # ステージ選択・クリア状況・コインアンロックUI
│       ├── puzzle_screen.dart          # 謎解き画面(問題・ヒント・回答・コイン表示)
│       ├── result_screen.dart          # 正解演出・解説表示・SNSシェアボタン
│       ├── daily_challenge_screen.dart # デイリーチャレンジ専用画面
│       ├── free_play_screen.dart       # ジャンル/難易度横断のフリープレイ画面
│       ├── linked_puzzle_screen.dart   # 連動謎(ボーナスステージ)画面
│       ├── achievements_screen.dart    # 実績一覧・達成時ポップアップ(AchievementPopupListener)
│       ├── story_intro_dialog.dart     # ステージ導入時のミニストーリーダイアログ
│       ├── ad_reward_dialog.dart       # 広告視聴(モック)によるコイン獲得ダイアログ
│       ├── settings_screen.dart        # 設定(効果音・通知・チュートリアル再表示・進捗リセット)
│       └── stats_screen.dart           # 統計(クリア数・正答率・コイン・実績数等)
├── assets/
│   ├── sounds/                         # 効果音配置用(実ファイル未同梱、README.md参照)
│   └── icon/                           # アイコン/スプラッシュ配置用(実画像未同梱、README.md参照)
├── test/                               # モデル・プロバイダー・ウィジェットテスト
├── .github/workflows/flutter-ci.yaml   # push/PR時のanalyze・test 自動実行CI
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

## Phase 3: 連動謎・オンボーディング・フリープレイ・通知・音声/アイコン基盤・CI

Phase 3 で以下7項目を追加実装した。

### 1. 連動謎/連動ステージ要素 (`lib/models/linked_puzzle_model.dart`, `lib/data/linked_puzzles_data.dart`, `lib/providers/linked_puzzle_provider.dart`, `lib/widgets/linked_puzzle_screen.dart`)

複数の謎（断片謎）を解いて得られる文字を正しい順に組み合わせ、最終回答を導く新形式。`LinkedFragmentPuzzle`（1つの断片謎・正解時に得られる文字）と `LinkedPuzzleSet`（断片謎のリスト＋最終回答）の2モデルを新設し、既存の `Puzzle` モデルは変更していない（正誤判定ロジックは同一のため重複実装だが、責務を分離するためあえて独立させている）。ステージ12「ナゾウの正体」として4問の断片謎＋最終回答1問を実装し、タイトル画面の「連動謎ボーナス」から挑戦できる。`ProgressState` に `clearedLinkedFragmentIds` / `clearedLinkedSetIds` を追加し、断片・最終回答それぞれの正解でコイン報酬を付与する。

### 2. チュートリアル/オンボーディング (`lib/widgets/onboarding_screen.dart`)

初回起動時に4枚のスライド（`PageView`）でヒント機能・コイン・デイリーチャレンジ等の基本操作を説明する。`ProgressState.hasSeenOnboarding`（`shared_preferences` 永続化）が false の間は `main.dart` の `AppEntryPoint` がオンボーディングを表示し、完了（またはスキップ）でタイトル画面へ遷移する。設定画面の「あそびかたをもう一度見る」から `isReplay: true` で再表示可能（この場合は完了してもフラグを変更せず、単に画面を閉じるだけ）。

### 3. 難易度選択/フィルタ機能（フリープレイ） (`lib/providers/free_play_provider.dart`, `lib/widgets/free_play_screen.dart`)

ステージ進行とは独立して、ジャンル・難易度で全100問を横断的に絞り込んでプレイできる「フリープレイ」画面を追加。絞り込みロジックは `filterPuzzles()` という純粋関数に集約し、UI（`ChoiceChip`）から独立してテストできるようにしている。選択した謎は既存の `PuzzleScreen` にそのまま渡して出題し、クリア記録・コイン報酬は通常プレイと共通の `ProgressNotifier` に反映される。

### 4. リマインダー通知 (`lib/services/notification_service.dart`, `lib/providers/notification_provider.dart`)

`flutter_local_notifications` + `timezone` を用い、デイリーチャレンジ未挑戦時に毎日20時ごろ通知するローカル通知を実装。`NotificationService` が権限リクエスト（iOS/Android 13+）・`zonedSchedule` によるスケジュール・キャンセルを担当し、実機/エミュレータでの動作確認ができない前提のため全操作を `try-catch` で保護し、失敗してもアプリの他機能に影響しないようにしている。「今日まだ挑戦していないか」の判定ロジックは `shouldRemindDailyChallenge()` という純粋関数として分離しテスト可能にしている（現状の通知自体は日次の固定時刻に発火する方式で、発火時点でのアプリ内判定と組み合わせて拡張できる設計）。設定画面に通知ON/OFFのトグルを追加し、`ProgressState.notificationsEnabled` で永続化する。

### 5. 効果音・BGM基盤 (`lib/services/sound_service.dart`, `lib/providers/sound_provider.dart`)

`audioplayers` を導入し、正解・不正解・実績解除時（ボタンタップ用の再生メソッドも用意）の効果音再生ロジックを `SoundService` に実装。`assets/sounds/` に `correct.mp3` 等のファイルを配置する前提だが、**本リポジトリには実際の音声バイナリは同梱していない**。ファイルが存在しない状態で再生を試みても `try-catch` で例外を握りつぶしログ出力のみ行うため、アプリはクラッシュしない。`ProgressState.soundEnabled`（既存の設定画面トグル）と連動させ、OFF時は再生自体を行わない。詳細な配置手順は `assets/sounds/README.md` に記載。

### 6. アプリアイコン/スプラッシュ画面設定基盤

`flutter_launcher_icons` / `flutter_native_splash` を `dev_dependencies` に追加し、`pubspec.yaml` に設定セクションを用意した。ただし両パッケージは通常1024×1024のPNG画像を起点にするため、**不正な/破損したバイナリを生成することは避け、実画像は未同梱のまま**としている。リリース前に デザイナー作成の `assets/icon/icon.png`（アイコン用）・`assets/icon/splash.png`（スプラッシュ用）に差し替えたうえで、`dart run flutter_launcher_icons` / `dart run flutter_native_splash:create` を実行する必要がある（詳細は `assets/icon/README.md`）。

### 7. CI設定 (`.github/workflows/flutter-ci.yaml`)

`main` ブランチへの push・PR時に `flutter pub get && flutter analyze && flutter test` を自動実行する GitHub Actions ワークフローを新規追加した（`subosito/flutter-action@v2` で stable チャンネルの Flutter SDK をセットアップ）。

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
| 連動謎/連動ステージ(ステージ12ボーナス) | ✅ 完成(Phase 3) |
| チュートリアル/オンボーディング | ✅ 完成(Phase 3) |
| フリープレイ(ジャンル/難易度フィルタ) | ✅ 完成(Phase 3) |
| リマインダー通知(flutter_local_notifications) | ✅ 完成(Phase 3、実機動作確認は未実施) |
| 効果音・BGM基盤(audioplayers) | ✅ 実装完了(Phase 3、実音声ファイルは別途配置が必要) |
| アプリアイコン/スプラッシュ設定基盤 | ✅ 設定のみ完了(Phase 3、実画像は別途用意が必要) |
| CI(GitHub Actions) | ✅ 完成(Phase 3) |

## Phase 5: 実機ビルド基盤・アクセシビリティ・テスト/ストア準備強化

Phase 5 では以下5項目に取り組んだ（環境制約により一部は方針の明記に留めた）。

1. **android/ios プラットフォームディレクトリ**: 作業環境に Flutter SDK が
   導入されておらず `flutter create` を実行できなかったため、未検証の
   プロジェクト一式を手動生成することは避け、`docs/store_listing.md`
   「8. Phase 5 での方針」に具体的な実行コマンド（
   `flutter create --platforms=android,ios --org com.nazodarake .`）と
   bundle id (`com.nazodarake.app`) / 表示名（なぞだらけ）の設定手順を
   明記するに留めた。
2. **通知の実挙動テスト強化**: `test/notification_service_test.dart` を
   新規追加し、`flutter_local_notifications` の `MethodChannel`
   （`dexterous.com/flutter/local_notifications`）をモックして
   `requestPermission` / `scheduleDailyReminder` / `cancelDailyReminder` /
   `initialize` の呼び出し・例外安全性を検証。`shouldRemindDailyChallenge()`
   の日付境界・null・年またぎ等のエッジケースも拡充した。
3. **ストア掲載用スクリーンショット自動生成**: `integration_test/
   store_screenshots_test.dart` を新規追加し、主要画面を
   `matchesGoldenFile` でPNG化できるようにした。`integration_test/` に
   配置することで通常の `flutter test`（CIが実行するコマンド）の対象外
   とし、CIの安定性に影響しない設計とした。使い方は
   `docs/store_listing.md` に追記済み。
4. **アクセシビリティ対応**: `ProgressState.textScaleOption`
   （small/standard/large）を追加し、`lib/theme/app_theme.dart` の
   `AppTextScale` で 0.8〜1.3 倍にクランプした `TextScaler` へ変換。
   `main.dart` の `MaterialApp.builder` でアプリ全体に適用し、設定画面に
   `SegmentedButton` によるUIを追加した。正誤フィードバックは既存実装で
   色に加えアイコン・文言で判別可能であることを確認済み。コイン表示・
   ヒントボタン等に `Semantics` / `Tooltip` を追加した。
5. **パフォーマンス最適化**: ステージ選択・フリープレイ画面は既に
   `ListView.builder` による遅延構築を使用していることを確認。
   `filterPuzzles()` も Riverpod の `Provider` 経由で依存する
   `StateProvider` 変化時のみ再計算される設計であることを確認し、
   追加のメモ化対応は不要と判断した。

**進捗**: 2026-09-22 Phase 5 実装完了（android/ios生成のみ環境制約により方針明記に留める）✅

**最終更新**: 2026-09-22
