import 'package:flutter/material.dart';
import 'package:nazodarake/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ranking_model.dart';
import '../providers/friend_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/progress_provider.dart';

/// ローカル完結のランキング画面。
///
/// サーバーへの通信は行わず、自分の進捗データ（クリア数・コイン）と
/// ローカルのフレンドリストのみを使って順位を計算する。
/// 将来的にサーバー同期を行う場合は、[buildRanking] への入力を
/// バックエンドから取得したグローバル/フレンドのスコア一覧に
/// 差し替えるだけで済むよう設計している。
class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final progress = ref.watch(progressProvider);
    final friends = ref.watch(friendProvider).friends;

    final ranking = buildRanking(
      myNickname: profile.nickname,
      myClearedCount: progress.clearedPuzzleIds.length,
      myCoins: progress.coins,
      friends: friends,
    );

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.titleRanking)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)!.rankingDisclaimer,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ranking.length,
              itemBuilder: (context, index) {
                final entry = ranking[index];
                final rank = index + 1;
                return Card(
                  color: entry.isMe
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('$rank'),
                    ),
                    title: Text(
                      entry.isMe ? '${entry.nickname}（自分）' : entry.nickname,
                      style: TextStyle(
                        fontWeight:
                            entry.isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'クリア数: ${entry.clearedCount}問 / コイン: ${entry.coins}枚',
                    ),
                    trailing: Text(
                      'Score: ${entry.score}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
