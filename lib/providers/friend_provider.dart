import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/friend_model.dart';

const _prefsKey = 'nazodarake_friends_v1';

/// フレンドリストの状態。
class FriendState {
  const FriendState({this.friends = seedDummyFriends});

  final List<Friend> friends;

  FriendState copyWith({List<Friend>? friends}) {
    return FriendState(friends: friends ?? this.friends);
  }
}

/// フレンドリストを管理する StateNotifier（完全ローカル完結・モック実装）。
///
/// 実際のサーバー通信は一切行わない。[addFriendByCode] は入力された
/// フレンドコードをもとに、それらしいダミーの統計情報を持つフレンドを
/// ローカルに追加するだけのモック処理である。
/// 将来的にサーバー同期を行う場合は、ここでバックエンドAPIを呼び出して
/// 実在するユーザーの検索・追加リクエスト送信を行う形に置き換える想定
/// （フレンドリクエストの承認フロー、オンラインランキングとの統合など）。
class FriendNotifier extends StateNotifier<FriendState> {
  FriendNotifier() : super(const FriendState()) {
    _load();
  }

  SharedPreferences? _prefs;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _prefs = prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List;
      final friends = decoded
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList();
      state = FriendState(friends: friends);
    } catch (_) {
      // 破損データの場合は初期状態（ダミーデータ）のまま。
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    if (!mounted) return;
    _prefs = prefs;
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.friends.map((f) => f.toJson()).toList()),
    );
  }

  /// フレンドコードを入力してフレンドを追加するモック処理。
  /// 実際のサーバー検索は行わず、コードから決定的な疑似フレンドを生成する。
  /// 既に同じコードのフレンドが存在する場合は何もしない。
  Future<bool> addFriendByCode(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return false;
    if (state.friends.any((f) => f.friendCode.toUpperCase() == trimmed)) {
      return false;
    }
    final seed = trimmed.codeUnits.fold<int>(0, (a, b) => a + b);
    final mockFriend = Friend(
      id: 'added_${DateTime.now().millisecondsSinceEpoch}',
      nickname: 'フレンド($trimmed)',
      friendCode: trimmed,
      clearedCount: seed % 150,
      coins: (seed * 7) % 2000,
      isDummy: false,
    );
    state = state.copyWith(friends: [...state.friends, mockFriend]);
    await _persist();
    return true;
  }

  Future<void> removeFriend(String id) async {
    state = state.copyWith(
      friends: state.friends.where((f) => f.id != id).toList(),
    );
    await _persist();
  }
}

final friendProvider = StateNotifierProvider<FriendNotifier, FriendState>((ref) {
  return FriendNotifier();
});
