import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sound_service.dart';
import 'progress_provider.dart';

/// アプリ全体で共有する [SoundService] のインスタンスを提供する。
/// [ProgressState.soundEnabled] の変更を監視し、自動で反映する。
final soundProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  service.setEnabled(ref.read(progressProvider).soundEnabled);
  ref.listen<ProgressState>(progressProvider, (previous, next) {
    if (previous?.soundEnabled != next.soundEnabled) {
      service.setEnabled(next.soundEnabled);
    }
  });
  ref.onDispose(service.dispose);
  return service;
});
