import 'package:flutter/material.dart';
import 'package:nazodarake/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/friend_provider.dart';
import '../providers/profile_provider.dart';

/// フレンドリスト画面（完全ローカル完結・モック実装）。
///
/// フレンドコードを入力して「追加」できるが、実際のサーバー通信は
/// 行わず、コードから決定的に生成されたダミーのフレンドがローカルに
/// 追加されるだけである。将来的にサーバー同期を実装する場合は、
/// [FriendNotifier.addFriendByCode] をAPI呼び出しに置き換える想定。
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final friendState = ref.watch(friendProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.titleFriends)),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.badge_rounded),
              title: Text(AppLocalizations.of(context)!.friendsYourCode),
              subtitle: Text(profile.friendCode),
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'コピー（このアプリ内では表示のみ）',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('フレンドコード: ${profile.friendCode}')),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.friendsCodeInputLabel,
                      hintText: '例: NAZO-1234',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final code = _codeController.text;
                    final added =
                        await ref.read(friendProvider.notifier).addFriendByCode(code);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          added ? 'フレンドを追加しました（ローカルのみ）' : '追加できませんでした（コード未入力か重複）',
                        ),
                      ),
                    );
                    if (added) _codeController.clear();
                  },
                  child: Text(AppLocalizations.of(context)!.friendsAddButton),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '※ サーバー通信は行われません。追加したフレンドは端末内にのみ保存されます。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: friendState.friends.length,
              itemBuilder: (context, index) {
                final friend = friendState.friends[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(friend.nickname),
                    subtitle: Text(
                      '${friend.friendCode} ・ クリア${friend.clearedCount}問 ・ ${friend.coins}コイン',
                    ),
                    trailing: friend.isDummy
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () => ref
                                .read(friendProvider.notifier)
                                .removeFriend(friend.id),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
