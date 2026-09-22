import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/providers/friend_provider.dart';
import 'package:nazodarake/providers/profile_provider.dart';
import 'package:nazodarake/providers/progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('言語設定の永続化', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('初期状態では languageCode は null（端末設定に従う）', () {
      final state = container.read(progressProvider);
      expect(state.languageCode, isNull);
    });

    test('setLanguageCode で言語を切り替えられる', () async {
      await container.read(progressProvider.notifier).setLanguageCode('en');
      expect(container.read(progressProvider).languageCode, 'en');

      await container.read(progressProvider.notifier).setLanguageCode('ja');
      expect(container.read(progressProvider).languageCode, 'ja');
    });

    test('setLanguageCode(null) で端末設定に戻せる', () async {
      await container.read(progressProvider.notifier).setLanguageCode('en');
      await container.read(progressProvider.notifier).setLanguageCode(null);
      expect(container.read(progressProvider).languageCode, isNull);
    });

    test('言語設定を変更しても他の進捗データはリセットされない', () async {
      await container.read(progressProvider.notifier).markCleared('p1');
      await container.read(progressProvider.notifier).setLanguageCode('en');
      final state = container.read(progressProvider);
      expect(state.clearedPuzzleIds, contains('p1'));
      expect(state.languageCode, 'en');
    });
  });

  group('ProfileNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('setNickname でニックネームを変更できる', () async {
      await container.read(profileProvider.notifier).setNickname('テスト太郎');
      expect(container.read(profileProvider).nickname, 'テスト太郎');
    });

    test('空文字のニックネームは無視される', () async {
      final before = container.read(profileProvider).nickname;
      await container.read(profileProvider.notifier).setNickname('   ');
      expect(container.read(profileProvider).nickname, before);
    });

    test('フレンドコードは自動生成され、NAZO-から始まる', () {
      final code = container.read(profileProvider).friendCode;
      expect(code, startsWith('NAZO-'));
    });
  });

  group('FriendNotifier（完全ローカル・モック実装）', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('初期状態にダミーフレンドが含まれる', () {
      final friends = container.read(friendProvider).friends;
      expect(friends, isNotEmpty);
      expect(friends.every((f) => f.isDummy), isTrue);
    });

    test('フレンドコードを入力するとローカルにフレンドが追加される', () async {
      final added =
          await container.read(friendProvider.notifier).addFriendByCode('MYCODE-1');
      expect(added, isTrue);
      final friends = container.read(friendProvider).friends;
      expect(friends.any((f) => f.friendCode == 'MYCODE-1'), isTrue);
    });

    test('同じフレンドコードは重複追加されない', () async {
      await container.read(friendProvider.notifier).addFriendByCode('DUP-1');
      final added =
          await container.read(friendProvider.notifier).addFriendByCode('DUP-1');
      expect(added, isFalse);
    });

    test('空文字のコードは追加されない', () async {
      final added = await container.read(friendProvider.notifier).addFriendByCode('  ');
      expect(added, isFalse);
    });

    test('removeFriend で追加したフレンドを削除できる', () async {
      await container.read(friendProvider.notifier).addFriendByCode('REMOVE-ME');
      final friends = container.read(friendProvider).friends;
      final target = friends.firstWhere((f) => f.friendCode == 'REMOVE-ME');
      await container.read(friendProvider.notifier).removeFriend(target.id);
      expect(
        container.read(friendProvider).friends.any((f) => f.id == target.id),
        isFalse,
      );
    });
  });
}
