import 'package:flutter/material.dart';
import 'package:nazodarake/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/linked_puzzles_data.dart';
import '../data/story_data.dart';
import '../providers/progress_provider.dart';
import 'achievements_screen.dart' show AchievementsScreen;
import 'daily_challenge_screen.dart';
import 'free_play_screen.dart';
import 'friends_screen.dart';
import 'linked_puzzle_screen.dart';
import 'ranking_screen.dart';
import 'settings_screen.dart';
import 'stage_select_screen.dart';
import 'stats_screen.dart';

/// アプリ起動時のタイトル画面。
class TitleScreen extends ConsumerWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final coins = ref.watch(progressProvider).coins;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          title: const Text(navigatorName),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Semantics(
                  label: '所持コイン $coins 枚',
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('$coins'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.extension_rounded,
                    size: 96,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'なぞだらけ',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    titleTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StageSelectScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.titleStartGame),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DailyChallengeScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.today_rounded),
                      label: Text(l10n.titleDailyChallenge),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FreePlayScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.tune_rounded),
                      label: Text(l10n.titleFreePlay),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LinkedPuzzleScreen(
                              set: stage12LinkedPuzzleSet,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.link_rounded),
                      label: Text(l10n.titleLinkedBonus),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: Text(l10n.titleAchievements),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: Text(l10n.titleStats),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RankingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.leaderboard_rounded),
                      label: Text(l10n.titleRanking),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FriendsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people_alt_rounded),
                      label: Text(l10n.titleFriends),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_rounded),
                    label: Text(l10n.titleSettings),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
