# なぞだらけ

謎解き・脳トレゲームアプリ。Flutter (Dart) + Riverpod で実装されています。

## 概要

「なぞだらけ」は、なぞなぞ・暗号解読・観察系・ひらめき・計算パズル・言葉遊び・論理パズルなど複数ジャンルの謎を、17のステージに分けて楽しめる謎解きゲームアプリです。段階的ヒント機能、ローカル進捗保存、正解時の演出に加え、コイン経済・ストーリー演出・SNSシェア・デイリーチャレンジ・実績システム・日本語/英語の多言語対応・ローカル完結のランキング/フレンド機能を備え、東京謎解きゲーム・なぞとも・Wonderland等の人気謎解きアプリと肩を並べる機能セットを目指しています。

## コンテンツ数

- 全 **150問**（ステージ1〜5: 8問×5ステージ＝40問／ステージ6〜11: 10問×6ステージ＝60問／ステージ13〜17: 10問×5ステージ＝50問）＋ 連動謎ボーナス（ステージ12: 断片謎4問＋最終回答1問）
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
- 10種類の実績（初クリア、ステージ1制覇、ノーヒントクリア、10問連続正解、全ジャンル制覇、50問クリア、全問(150問)クリア、デイリー7日連続、コイン500枚所持、ステージ10クリア）
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


## Phase 4 で追加した機能

### フルコンテンツ拡充
- ステージ13〜17を新設し、10問×5ステージ＝50問を追加（合計17ステージ・150問＋連動謎ボーナス）
- 新ステージのステージ導入ストーリー（`lib/data/story_data.dart`）を追加
- 既存の `stageUnlockCost` の式（`50 × (ステージ番号 - 5)`）はそのまま新ステージにも適用される設計

### ローカル完結のフレンド/ランキング機能
- 外部バックエンド（Firebase等）は使用せず、`shared_preferences` のみで完結するモック実装
- `lib/models/profile_model.dart` / `lib/providers/profile_provider.dart`: ニックネーム・フレンドコードを管理するユーザープロフィール
- `lib/models/friend_model.dart` / `lib/providers/friend_provider.dart`: ダミーフレンドデータ＋フレンドコード入力によるローカル追加（実際のサーバー通信は行わない）
- `lib/models/ranking_model.dart`: 自分とフレンドのスコア（クリア数×100＋コイン）を降順に並べる純粋関数 `buildRanking()`
- `lib/widgets/ranking_screen.dart` / `lib/widgets/friends_screen.dart`: ランキング画面・フレンド管理画面
- **将来的な拡張**: サーバー同期を行う場合は `FriendNotifier.addFriendByCode` をAPI呼び出しに置き換え、`buildRanking()` への入力をバックエンド取得値に差し替えるだけで対応できるよう設計している（コード内コメント参照）

### 多言語対応（日本語 / 英語）
- `flutter_localizations` + `intl` を導入し、`lib/l10n/app_ja.arb` / `lib/l10n/app_en.arb` でUI文言をARB形式管理
- `pubspec.yaml` の `flutter: generate: true` により、`flutter pub get` 時に `AppLocalizations` が自動生成される
- タイトル・ステージ選択・謎解き・結果・設定・統計・実績・ランキング・フレンドの主要画面文言を対応
- 端末の言語設定に自動追従するほか、設定画面から「端末の設定に従う／日本語／English」を手動選択可能（`ProgressState.languageCode` として永続化）
- 謎の問題文・答え自体は日本語のみ（翻訳対象は固定UI文言のみ）

### ストア公開準備ドキュメント
- `docs/store_listing.md` を新規作成
  - アプリ名・簡潔な説明文（日英）、ストア用長文説明、対象年齢層
  - 必要なスクリーンショット一覧
  - プライバシーポリシーの雛形（進捗データはローカル保存のみで外部送信なしという方針を明記）
  - リリースチェックリスト

### 実機ビルド設定の整備
- 本リポジトリには現時点で `android/` `ios/` ディレクトリがまだ生成されていないため、実際のプラットフォーム設定ファイル編集は次のステップとして残している
- 実機ビルドを行う場合は、まず `flutter create --platforms=android,ios .` を実行してプラットフォームディレクトリを生成したうえで、`android/app/build.gradle` の `applicationId` と `ios/Runner/Info.plist` の Bundle Identifier / 表示名を、それぞれ `com.nazodarake.app` / 「なぞだらけ」に設定してください（詳細は `docs/store_listing.md` のリリースチェックリストを参照）
- 署名設定（Android keystore, iOS 配布用証明書）は本番鍵を用意できる環境で別途行う必要があります

### スコープ外とした項目
- mp3等の実音声バイナリ・実画像（アイコン/スプラッシュ）バイナリの生成・配置は、Phase 3に引き続きスコープ外としています（`assets/sounds/README.md`, `assets/icon/README.md` を参照）

## Phase 5 で追加した機能

### 通知機能のテスト強化
- `lib/services/notification_service.dart` の `requestPermission` /
  `scheduleDailyReminder` / `cancelDailyReminder` / `initialize` について、
  `flutter_local_notifications` が使用する `MethodChannel`
  （`dexterous.com/flutter/local_notifications`）をモックしたユニットテスト
  を `test/notification_service_test.dart` に追加
- `shouldRemindDailyChallenge()` の日付境界・null・年またぎ等のエッジケース
  テストを拡充

### ストア掲載用スクリーンショット自動生成
- `integration_test/store_screenshots_test.dart` を新規追加し、主要画面
  （タイトル・ステージ選択・謎解き・結果・実績・統計・ランキング）を
  `matchesGoldenFile` でPNG書き出しできるようにした
- `integration_test/` 配下に配置しているため、通常の `flutter test`
  （CIが実行するコマンド）では走査されず、CIの成否には影響しない設計
- 使い方・生成コマンドの詳細は `docs/store_listing.md`「7. スクリーンショット
  自動生成スクリプト」を参照

### アクセシビリティ対応
- 設定画面に「文字サイズ」設定（小/標準/大）を追加し、`ProgressState.textScaleOption`
  として永続化。`lib/theme/app_theme.dart` の `AppTextScale` でレイアウト崩れ
  を防ぐ範囲（0.8〜1.3倍）にクランプした `TextScaler` へ変換し、
  `main.dart` の `MaterialApp.builder` でアプリ全体に適用
- 正誤フィードバックはもともと色（緑/赤系のコンテナ色）だけでなく、
  アイコン（✓ = `check_circle_rounded` 系 / ✗ = `close_rounded`）と
  文言（「正解！」「残念、正解ではありません」等）でも判別できる実装で
  あることを確認済み（色覚多様性への配慮）
- コイン残高表示・不正解フィードバック等に `Semantics` ラベルを、
  文字サイズ設定・ヒント表示ボタン・回答送信ボタンに `Tooltip` /
  `Semantics` を追加し、スクリーンリーダーでの読み上げ内容を明確化

### パフォーマンス確認
- ステージ選択画面 (`stage_select_screen.dart`) ・フリープレイ画面
  (`free_play_screen.dart`) は既に `ListView.builder` による遅延構築を
  使用していることを確認済み（150問超のデータでも表示中の要素のみ構築）
- `filterPuzzles()` は Riverpod の `Provider`（`filteredFreePlayPuzzlesProvider`）
  経由で呼び出されており、依存する `StateProvider`（ジャンル/難易度）が
  変化した時のみ再計算される設計になっていることを確認済み。追加の
  メモ化対応は不要と判断した

### プラットフォームディレクトリ（android/ios）について
- 本Phaseの作業環境には Flutter SDK が導入されておらず、`flutter create`
  を実行して `android/` `ios/` を生成・検証することができなかったため、
  未検証のプロジェクト一式を手動ででっち上げることは避け、対応を見送った
- 実施手順は `docs/store_listing.md`「8. Phase 5 での方針」に明記した
  （`flutter create --platforms=android,ios --org com.nazodarake .` の実行、
  bundle id `com.nazodarake.app` / 表示名「なぞだらけ」への設定）

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
│   ├── linked_puzzle_model.dart       # 連動謎モデル(LinkedPuzzleSet/LinkedFragmentPuzzle)
│   ├── profile_model.dart             # ユーザープロフィール(ニックネーム/フレンドコード)
│   ├── friend_model.dart              # フレンドモデル(ローカル完結・ダミーデータ)
│   └── ranking_model.dart             # ランキング計算(buildRanking純粋関数)
├── data/
│   ├── puzzles_data.dart              # 謎解きコンテンツ本体(150問・17ステージ)
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
│   ├── notification_provider.dart     # 通知トグルの操作をまとめるコントローラー
│   ├── profile_provider.dart          # ユーザープロフィールの永続化
│   └── friend_provider.dart           # フレンドリストの永続化(ローカル完結モック)
├── services/
│   ├── sound_service.dart             # audioplayers を用いた効果音再生(失敗時は無視)
│   └── notification_service.dart      # flutter_local_notifications を用いたリマインダー通知
├── theme/
│   └── app_theme.dart                 # Material3テーマ(ライト/ダーク、AppTextScaleによる文字サイズ設定対応)
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
    ├── settings_screen.dart           # 設定画面(ニックネーム編集・言語切替・文字サイズ設定を含む)
    ├── stats_screen.dart              # 統計画面
    ├── ranking_screen.dart            # ローカル完結ランキング画面
    └── friends_screen.dart            # フレンド管理画面(ローカル完結モック)

assets/
├── sounds/                            # 効果音配置用(README.md に実ファイル未同梱の旨を記載)
└── icon/                              # アプリアイコン/スプラッシュ配置用(同上)

lib/l10n/
├── app_ja.arb                          # 日本語UI文言(テンプレート/正)
└── app_en.arb                          # 英語UI文言

docs/
└── store_listing.md                    # ストア公開準備ドキュメント(スクリーンショット自動生成の使い方を含む)

test/
├── puzzle_model_test.dart             # モデル・正誤判定のテスト
├── game_provider_test.dart            # ゲーム進行プロバイダーのテスト
├── coin_and_achievement_test.dart     # コイン消費・実績判定のテスト
├── daily_challenge_test.dart          # デイリーチャレンジの日付ロジックのテスト
├── linked_puzzle_test.dart            # 連動謎の正誤判定・データ整合性のテスト
├── free_play_filter_test.dart         # フリープレイ絞り込みロジックのテスト
├── onboarding_and_notification_test.dart # オンボーディング/通知フラグ・リマインダー判定のテスト
├── onboarding_widget_test.dart        # オンボーディング画面遷移のウィジェットテスト
├── notification_service_test.dart     # NotificationServiceのMethodChannelモックテスト・日付エッジケース
├── widget_test.dart                   # 画面遷移のウィジェットテスト
├── ranking_test.dart                  # ランキングのソートロジックのテスト
└── phase4_provider_test.dart          # 言語設定・プロフィール・フレンド機能のテスト

integration_test/
└── store_screenshots_test.dart        # ストア掲載用スクリーンショット生成(通常のflutter testでは実行されない)

.github/workflows/
└── flutter-ci.yaml                    # push/PR時に analyze・test を自動実行するCI(test/配下のみが対象)
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
- flutter_localizations + intl (日本語/英語の多言語対応、ARBファイルから自動生成)

## ライセンス

個人開発プロジェクトです。
