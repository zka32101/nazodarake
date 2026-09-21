# なぞだらけ

謎解き・脳トレゲームアプリ。Flutter (Dart) + Riverpod で実装されています。

## 概要

「なぞだらけ」は、なぞなぞ・暗号解読・観察系・ひらめき・計算パズルなど複数ジャンルの謎を、5つのステージに分けて楽しめる謎解きゲームアプリです。段階的ヒント機能、ローカル進捗保存、正解時の演出など、人気の謎解きアプリ（東京謎解きゲーム、なぞとも、Wonderland等）を参考にした機能を備えています。

## コンテンツ数

- 全 **40問**（5ステージ × 8問）
- ジャンル: なぞなぞ・暗号解読・観察系・ひらめき・計算パズル（5ジャンル）
- 難易度: ★☆☆（easy）〜 ★★★（hard）の3段階

## 主要機能

- **ステージ制の進行管理**: ステージ1から順に解放され、前のステージを全問クリアすると次のステージが解放される
- **段階的ヒント機能**: 各問題に複数段階のテキストヒントを用意。詰まったら少しずつヒントを開示できる
- **ローカル進捗保存**: `shared_preferences` を使い、クリア状況・ヒント使用状況・正誤カウントをアプリを閉じても保持
- **正解演出**: 正解すると専用の結果画面でアニメーション演出と解説を表示
- **複数ジャンルの謎**: なぞなぞ・暗号解読（シーザー暗号や置換暗号）・観察系（図形や漢字パズル）・ひらめき（フェルミ推定・論理パズル）・計算パズルを網羅
- **自由入力/選択肢の両対応**: 問題によって自由記述形式・選択肢形式を使い分け
- **ダーク/ライトテーマ対応**: Material Design 3 に基づき、システム設定に応じて自動切り替え
- **統計画面**: クリア数・正答率・正解/不正解の回数・使用ヒント数を可視化
- **設定画面**: 効果音のオン/オフ、進捗のリセット機能

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
├── main.dart                     # アプリエントリポイント
├── models/
│   └── puzzle_model.dart         # 謎データモデル・正誤判定ロジック
├── data/
│   └── puzzles_data.dart         # 謎解きコンテンツ本体(40問)
├── providers/
│   ├── game_provider.dart        # 出題中の状態管理(Riverpod)
│   └── progress_provider.dart    # ローカル進捗永続化(Riverpod)
├── theme/
│   └── app_theme.dart            # Material3テーマ(ライト/ダーク)
└── widgets/
    ├── title_screen.dart         # タイトル画面
    ├── stage_select_screen.dart  # ステージ選択画面
    ├── puzzle_screen.dart        # 謎解き画面
    ├── result_screen.dart        # 正解演出・結果画面
    ├── settings_screen.dart      # 設定画面
    └── stats_screen.dart         # 統計画面

test/
├── puzzle_model_test.dart        # モデル・正誤判定のテスト
├── game_provider_test.dart       # ゲーム進行プロバイダーのテスト
└── widget_test.dart              # 画面遷移のウィジェットテスト
```

## 技術スタック

- Flutter (Dart)
- flutter_riverpod (状態管理)
- shared_preferences (ローカル永続化)
- google_fonts (フォント)

## ライセンス

個人開発プロジェクトです。
