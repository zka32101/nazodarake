/// フレンド（自分以外のプレイヤー）を表すローカル完結モデル。
///
/// 本実装では外部サーバーとの通信を一切行わず、あらかじめ用意した
/// ダミーデータと、ユーザーが「フレンドコード」を入力して追加した
/// ローカルレコードのみを扱う。将来的にサーバー同期を行う場合は、
/// [FriendNotifier] 内の `addFriendByCode` をAPI呼び出しに置き換え、
/// このモデルに `userId` 等のサーバー側キーを追加する想定。
class Friend {
  const Friend({
    required this.id,
    required this.nickname,
    required this.friendCode,
    required this.clearedCount,
    required this.coins,
    this.isDummy = true,
  });

  /// ローカルでの一意なID。
  final String id;

  final String nickname;

  final String friendCode;

  /// ランキング表示用のダミー統計：クリア数。
  final int clearedCount;

  /// ランキング表示用のダミー統計：コイン数。
  final int coins;

  /// あらかじめ用意されたダミーフレンドかどうか（統計データは固定値）。
  final bool isDummy;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'friendCode': friendCode,
        'clearedCount': clearedCount,
        'coins': coins,
        'isDummy': isDummy,
      };

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      friendCode: json['friendCode'] as String,
      clearedCount: json['clearedCount'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      isDummy: json['isDummy'] as bool? ?? true,
    );
  }
}

/// あらかじめ用意されたダミーフレンドのデータセット。
/// 実際のサーバー通信は行わず、ローカルランキングの見え方を確認するための
/// サンプルとして提供する。
const List<Friend> seedDummyFriends = [
  Friend(
    id: 'dummy_001',
    nickname: 'なぞ子',
    friendCode: 'NAZO-0001',
    clearedCount: 42,
    coins: 380,
  ),
  Friend(
    id: 'dummy_002',
    nickname: 'ひらめき太郎',
    friendCode: 'NAZO-0002',
    clearedCount: 88,
    coins: 910,
  ),
  Friend(
    id: 'dummy_003',
    nickname: 'あんごう博士',
    friendCode: 'NAZO-0003',
    clearedCount: 15,
    coins: 120,
  ),
  Friend(
    id: 'dummy_004',
    nickname: 'ロジックさん',
    friendCode: 'NAZO-0004',
    clearedCount: 130,
    coins: 1500,
  ),
];
