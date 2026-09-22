/// ユーザー自身のローカルプロフィール。
///
/// 現状はニックネームとフレンドコードのみを保持するローカル完結モデル。
/// 将来的にサーバー同期（例: Firebase等）を導入する場合は、ここに
/// `userId` や `lastSyncedAt` などのフィールドを追加し、
/// [ProfileNotifier] からバックエンドAPIを呼び出す形に拡張する想定。
class UserProfile {
  const UserProfile({
    this.nickname = 'なぞ解き旅人',
    required this.friendCode,
  });

  /// 画面表示用のニックネーム（設定画面から編集可能）。
  final String nickname;

  /// 他ユーザーがフレンド追加時に入力する自分のコード（ローカル生成の疑似ID）。
  final String friendCode;

  UserProfile copyWith({String? nickname, String? friendCode}) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      friendCode: friendCode ?? this.friendCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'friendCode': friendCode,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json, String fallbackCode) {
    return UserProfile(
      nickname: json['nickname'] as String? ?? 'なぞ解き旅人',
      friendCode: json['friendCode'] as String? ?? fallbackCode,
    );
  }
}
