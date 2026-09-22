import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';

const _prefsKey = 'nazodarake_profile_v1';

/// ローカル完結のユーザープロフィールを管理する StateNotifier。
///
/// サーバーとの通信は行わず、shared_preferences にのみ保存する。
/// 将来的にサーバー同期（フレンド機能のオンライン化など）を行う場合は、
/// [setNickname] 等の更新メソッド内でAPI呼び出しを追加する想定。
class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(UserProfile(friendCode: _generateFriendCode())) {
    _load();
  }

  SharedPreferences? _prefs;

  static String _generateFriendCode() {
    final random = Random();
    final code = List.generate(4, (_) => random.nextInt(10)).join();
    return 'NAZO-${code.padLeft(4, '0')}';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _prefs = prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = UserProfile.fromJson(decoded, state.friendCode);
        return;
      } catch (_) {
        // 破損データの場合は初期状態のまま。
      }
    }
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    if (!mounted) return;
    _prefs = prefs;
    await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  Future<void> setNickname(String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(nickname: trimmed);
    await _persist();
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
