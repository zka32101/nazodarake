# なぞだらけ

謎解き・脳トレゲームアプリ。Flutter (Dart) + Riverpod で実装されています。

## 概要

「なぞだらけ」は、なぞなぞ・暗号解読・観察系・ひらめき・計算パズル・言葉遊び・論理パズルなど複数ジャンルの謎を、11のステージに分けて楽しめる謎解きゲームアプリです。段階的ヒント機能、ローカル進捗保存、正解時の演出に加え、コイン経済・ストーリー演出・SNSシェア・デイリーチャレンジ・実績システムを備え、東京謎解きゲーム・なぞとも・Wonderland等の人気謎解きアプリと肩を並べる機能セットを目指しています。

## コンテンツ数

- 全 **100問**（ステージ1〜5: 8問×5ステージ＝40問／ステージ6〜11: 10問×6ステージ＝60問）＋ 連動謎ボーナス（ステージ12: 断片謎4問＋最終回答1問）
- ジャンル: なぞなぞ・暗号解読・観察系・ひらめき・計算パズル・言葉遊び・論理パズル（7ジャンル）
- 難易度: ★☆☆（easy）〜 ★★★（hard）の3段階

## 主要機能

### コアゲームプレイ
- **ステージ制の進行管理**: ステージ1〜5は前のステージを全問クリアすると解放。ステージ6以降は前ステージクリアに加え、コインでのアンロックが必要
- **段階的ヒント機能**: 各問題に複数段階のテキストヒントを用意。1つ目のヒントは無料、2つ目以降はコインを消費して開示
- **ローカル進捗保存**: `shared_preferences` を使い、クリア状況・ヒント使用状況・正誤カウント・コイン・実績・デイリーストリークをアプリを閉じても保持
- **正解演出**: 正解すると専用の結果画面でアニメーション演出・解説・SNSシェアボタンを表示

### コイン/課金要素
- クリアするたびにコインを獲得（1問クリアで10コイン）
- 「広告を見てコインを獲得」モックダイアログ（実SDK非統合、数秒待ってから30コイン付与するシミュレーション）
- ステージ6以降はコインでアンロック（コスト: `50 × (ステージ番号 - 5)`）
- コインが足りない場合は広告視聴フローへ誘導

### ストーリー/世界観
- ナビゲーターキャラクター「ナゾウ」（なぞだらけの島に住むフクロウ）が同行
- 各ステージ挑戦前にミニストーリーダイアログを表示
- タイトル画面にストーリー性のあるキャッチコピーを表示

### SNSシェア機能
- `share_plus` を用いて、結果画面からクリア結果をテキストでシェア可能

### デイリーチャレンジ
- 日替わりで1問だけ出題される専用モード（タイトル画面から遷移）
- 日付ベースで決定的に問題を選択（同じ日は必ず同じ問題）
- 連続挑戦日数（ストリーク）を記録し、7日連続達成で実績を獲得

### 実績/バッジシステム
- 10種類の実績（初クリア、ステージ1制覇、ノーヒントクリア、10問連続正解、全ジャンル制覇、50問クリア、全100問クリア、デイリー7日連続、コイン500枚所持、ステージ10クリア）
- 実績達成時にポップアップ通知（スナックバー）で演出
- 実績一覧画面で獲得済み/未獲得を可視化

### その他
- **自由入力/選択肢の両対応**: 問題によって自由記述形式・選択肢形式を使い分け
- **ダーク/ライトテーマ対応**: Material Design 3 に基づき、システム設定に応じて自動切り替え
- **統計画面**: クリア数・正答率・コイン・連続正解記録・デイリーストリーク・獲得実績数を可視化
- **設定画面**: 効果音・通知のオン/オフ、チュートリアル再表示、進捗のリセット機能

## Phase 3 で追加した機能

### 連動謎（ボーナスステージ12）
- 複数の断片謎（3〜5問）を解いて得られる文字を正しい順に組み合わせ、最終回答を導く新形式
- `LinkedPuzzleSet` / `LinkedFragmentPuzzle`（`lib/models/linked_puzzle_model.dart`）で表現し、`lib/data/linked_puzzles_data.dart` にステージ12「ナゾウの正体」を定義
- タイトル画面の「連動謎ボーナス」から挑戦可能

### チュートリアル/オンボーディング
- 初回起動時に4枚のスライド（PageView）で操作方法を紹介
- `shared_preferences`（`ProgressState.hasSeenOnboarding`）で表示済みフラグを永続化し、2回目以降はスキップ
- 設定画面の「あそびかたをもう一度見る」からいつでも再表示可能

### フリープレイ（絞り込みモード）
- タイトル画面の「フリープレイ（絞り込み）」から、ジャンル・難易度を横断的に絞り込んで好きな問題に挑戦できる
- 絞り込みロジックは `filterPuzzles()`（`lib/providers/free_play_provider.dart`）に純粋関数として実装しテスト可能にしている

### リマインダー通知
- `flutter_local_notifications` を用い、デイリーチャレンジ未挑戦時に毎日20時ごろ通知するリマインダー機能を追加
- 設定画面の「デイリーチャレンジ通知」トグルで有効化（初回は通知権限をリクエスト）
- 権限リクエスト・スケジュール処理はすべて `lib/services/notification_service.dart` の `NotificationService` に実装。実機での動作確認はできない前提のため、全操作を `try-catch` で保護しクラッシュしないようにしている

### 効果音・BGM基盤
- `audioplayers` を導入し、正解・不正解・実績解除時に効果音を再生するロジックを追加（`lib/services/sound_service.dart`）
- **実際の音声ファイル（mp3等）は本リポジトリには同梱されていません。** リリース前に `assets/sounds/` へ配置してください（詳細は `assets/sounds/README.md` を参照）
- 音声ファイルが存在しない場合でも `try-catch` で例外を握りつぶし、アプリはクラッシュしません

### アプリアイコン/スプラッシュ画面設定基盤
- `flutter_launcher_icons` / `flutter_native_splash` の設定を `pubspec.yaml` に追加済み
- **実際のアイコン・スプラッシュ画像（1024x1024 PNG等）は本リポジトリには同梱されていません。** リリース前にデザイナー作成の画像へ差し替えてください（詳細は `assets/icon/README.md` を参照）

### CI（GitHub Actions）
- `.github/workflows/flutter-ci.yaml` を追加し、`main` への push / PR 時に `flutter pub get && flutter analyze && flutter test` を自動実行

## セットアップ

```bash
# 依存関係のインストール
flutter pub get

# アプリの実行
flutter run

# 静的解析
flutter analyze

# テストの実行
flutter test
```

動作には Flutter SDK 3.x 系（Dart SDK >=3.3.0）が必要です。

## ディレクトリ構成

```
lib/
├── main.dart                          # アプリエントリポイント・オンボーディング分岐
├── models/
│   ├── puzzle_model.dart              # 謎データモデル・正誤判定ロジック
│   ├── achievement_model.dart         # 実績定義・達成判定ロジック
│   └── linked_puzzle_model.dart       # 連動謎モデル(LinkedPuzzleSet/LinkedFragmentPuzzle)
├── data/
│   ├── puzzles_data.dart              # 謎解きコンテンツ本体(100問・11ステージ)
│   ├── story_data.dart                # ナビゲーターキャラ・ステージ導入ストーリー
│   └── linked_puzzles_data.dart       # 連動謎(ステージ12)のデータ
├── providers/
│   ├── game_provider.dart             # 出題中の状態管理・ヒントのコイン消費
│   ├── progress_provider.dart         # 進捗・コイン・実績・デイリー・通知設定の永続化(Riverpod)
│   ├── achievement_provider.dart      # 実績の自動判定・ポップアップ通知
│   ├── daily_challenge_provider.dart  # デイリーチャレンジの日付ロジック
│   ├── linked_puzzle_provider.dart    # 連動謎の進行状態管理
│   ├── free_play_provider.dart        # フリープレイの絞り込みロジック
│   ├── sound_provider.dart            # 効果音サービスのDIプロバイダー
│   └── notification_provider.dart     # 通知トグルの操作をまとめるコントローラー
├── services/
│   ├── sound_service.dart             # audioplayers を用いた効果音再生(失敗時は無視)
│   └── notification_service.dart      # flutter_local_notifications を用いたリマインダー通知
├── theme/
│   └── app_theme.dart                 # Material3テーマ(ライト/ダーク)
└── widgets/
    ├── onboarding_screen.dart         # 初回起動チュートリアル(PageView 4枚)
    ├── title_screen.dart              # タイトル画面
    ├── stage_select_screen.dart       # ステージ選択・コインアンロック画面
    ├── puzzle_screen.dart             # 謎解き画面
    ├── result_screen.dart             # 正解演出・SNSシェア画面
    ├── daily_challenge_screen.dart    # デイリーチャレンジ画面
    ├── free_play_screen.dart          # ジャンル/難易度横断のフリープレイ画面
    ├── linked_puzzle_screen.dart      # 連動謎(ボーナスステージ)画面
    ├── achievements_screen.dart       # 実績一覧・ポップアップ通知
    ├── story_intro_dialog.dart        # ステージ導入ミニストーリー
    ├── ad_reward_dialog.dart          # 広告視聴(モック)ダイアログ
    ├── settings_screen.dart           # 設定画面
    └── stats_screen.dart              # 統計画面

assets/
├── sounds/                            # 効果音配置用(README.md に実ファイル未同梱の旨を記載)
└── icon/                              # アプリアイコン/スプラッシュ配置用(同上)

test/
├── puzzle_model_test.dart             # モデル・正誤判定のテスト
├── game_provider_test.dart            # ゲーム進行プロバイダーのテスト
├── coin_and_achievement_test.dart     # コイン消費・実績判定のテスト
├── daily_challenge_test.dart          # デイリーチャレンジの日付ロジックのテスト
├── linked_puzzle_test.dart            # 連動謎の正誤判定・データ整合性のテスト
├── free_play_filter_test.dart         # フリープレイ絞り込みロジックのテスト
├── onboarding_and_notification_test.dart # オンボーディング/通知フラグ・リマインダー判定のテスト
├── onboarding_widget_test.dart        # オンボーディング画面遷移のウィジェットテスト
└── widget_test.dart                   # 画面遷移のウィジェットテスト

.github/workflows/
└── flutter-ci.yaml                    # push/PR時に analyze・test を自動実行するCI
```

## 技術スタック

- Flutter (Dart)
- flutter_riverpod (状態管理)
- shared_preferences (ローカル永続化)
- google_fonts (フォント)
- share_plus (SNSシェア)
- audioplayers (効果音再生 / 実音声ファイルは別途配置が必要)
- flutter_local_notifications + timezone (ローカル通知)
- flutter_launcher_icons / flutter_native_splash (アイコン・スプラッシュ設定基盤 / 実画像は別途配置が必要)

## ライセンス

個人開発プロジェクトです。
