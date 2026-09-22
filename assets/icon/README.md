# アプリアイコン / スプラッシュ画像について

`flutter_launcher_icons` と `flutter_native_splash` の設定を `pubspec.yaml` に追加済みですが、
これらのパッケージは通常 **1024x1024 の PNG画像** を起点にアイコン一式・スプラッシュ画像を生成します。

**本リポジトリには実際の画像バイナリ（PNG）は同梱されていません。**
不正な・破損したバイナリを用意するよりも、明記だけに留めています。

## リリース前に必要な作業

1. デザイナー（または生成AIツール等）が作成した、以下の画像を用意する:
   - `assets/icon/icon.png` （1024x1024、透過なし推奨、アプリアイコン用）
   - `assets/icon/splash.png` （スプラッシュ画面中央に表示するロゴ、透過PNG推奨）
2. 画像を配置後、以下を実行してアイコン・スプラッシュ画面を生成する:
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```
3. `pubspec.yaml` の `flutter_launcher_icons:` / `flutter_native_splash:` セクションの
   パス・背景色が要件と合っているか確認する。

現状のプレースホルダー設定は「謎解き」をイメージした虫眼鏡/鍵モチーフのアイコンを想定した
コメントのみで、実画像は未生成です。
