import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 効果音の種類。
enum SoundEffect {
  correct,
  wrong,
  tap,
  achievement,
}

extension on SoundEffect {
  /// `assets/sounds/` 配下に配置すべきファイル名。
  ///
  /// 本実装では実際の音声バイナリは同梱していないため、再生を試みても
  /// ファイルが存在しない場合がある。[SoundService] 側で例外を握りつぶす
  /// ことで、アセット未配置でもアプリがクラッシュしないようにしている。
  String get assetPath {
    switch (this) {
      case SoundEffect.correct:
        return 'sounds/correct.mp3';
      case SoundEffect.wrong:
        return 'sounds/wrong.mp3';
      case SoundEffect.tap:
        return 'sounds/tap.mp3';
      case SoundEffect.achievement:
        return 'sounds/achievement.mp3';
    }
  }
}

/// 効果音・BGM再生を担うサービス。
///
/// 実際の音声ファイル（mp3等）は本リポジトリには同梱されていない。
/// `assets/sounds/` に本番用の音声ファイルを配置するまでの間も、
/// このサービスは再生失敗を全て無視してアプリがクラッシュしないよう
/// 設計されている（`try-catch` で [AudioPlayer] の例外を握りつぶす）。
class SoundService {
  SoundService();

  AudioPlayer? _player;
  bool _enabled = true;

  /// 効果音のON/OFF（設定画面の「効果音」トグルと連動させる）。
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> _play(SoundEffect effect) async {
    if (!_enabled) return;
    try {
      // AudioPlayer の生成自体も、プラットフォームチャンネル未対応の環境
      // （ユニットテスト等）では失敗しうるため try-catch の内側で行う。
      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.play(AssetSource(effect.assetPath));
    } catch (error, stackTrace) {
      // 音声ファイルが未配置、またはプラットフォームが未対応の場合でも
      // アプリの動作自体に影響を与えないよう、例外は握りつぶしログのみ出す。
      debugPrint('SoundService: failed to play ${effect.name}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> playCorrect() => _play(SoundEffect.correct);
  Future<void> playWrong() => _play(SoundEffect.wrong);
  Future<void> playTap() => _play(SoundEffect.tap);
  Future<void> playAchievement() => _play(SoundEffect.achievement);

  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {
      // dispose 失敗も無視する。
    }
  }
}
