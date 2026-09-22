import 'friend_model.dart';

/// ランキングの1エントリ（自分 or フレンド）。
class RankingEntry {
  const RankingEntry({
    required this.id,
    required this.nickname,
    required this.clearedCount,
    required this.coins,
    required this.isMe,
  });

  final String id;
  final String nickname;
  final int clearedCount;
  final int coins;
  final bool isMe;

  /// ランキングで使用する総合スコア。
  /// クリア数を重視しつつ、コインも僅かに加味する設計。
  /// （将来サーバー同期する場合も、このスコア計算式は共通で使う想定）
  int get score => clearedCount * 100 + coins;
}

/// 自分の統計とフレンド一覧から、スコア降順のローカルランキングを構築する
/// 純粋関数。UIやI/Oに依存せず単体テストしやすい形にしている。
List<RankingEntry> buildRanking({
  required String myNickname,
  required int myClearedCount,
  required int myCoins,
  required List<Friend> friends,
}) {
  final entries = <RankingEntry>[
    RankingEntry(
      id: 'me',
      nickname: myNickname,
      clearedCount: myClearedCount,
      coins: myCoins,
      isMe: true,
    ),
    for (final friend in friends)
      RankingEntry(
        id: friend.id,
        nickname: friend.nickname,
        clearedCount: friend.clearedCount,
        coins: friend.coins,
        isMe: false,
      ),
  ];

  entries.sort((a, b) {
    final scoreDiff = b.score.compareTo(a.score);
    if (scoreDiff != 0) return scoreDiff;
    // スコアが同点の場合はニックネームの辞書順で安定した並びにする。
    return a.nickname.compareTo(b.nickname);
  });

  return entries;
}
