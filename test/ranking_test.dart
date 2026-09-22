import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/models/friend_model.dart';
import 'package:nazodarake/models/ranking_model.dart';

void main() {
  group('buildRanking', () {
    test('スコア降順に並び、自分の行が isMe=true になる', () {
      const friends = [
        Friend(
          id: 'f1',
          nickname: 'Aさん',
          friendCode: 'NAZO-0001',
          clearedCount: 10,
          coins: 100,
        ),
        Friend(
          id: 'f2',
          nickname: 'Bさん',
          friendCode: 'NAZO-0002',
          clearedCount: 50,
          coins: 10,
        ),
      ];

      final ranking = buildRanking(
        myNickname: '自分',
        myClearedCount: 20,
        myCoins: 500,
        friends: friends,
      );

      expect(ranking.length, 3);
      // スコア: 自分=20*100+500=2500, Aさん=10*100+100=1100, Bさん=50*100+10=5010
      expect(ranking[0].nickname, 'Bさん');
      expect(ranking[1].nickname, '自分');
      expect(ranking[1].isMe, isTrue);
      expect(ranking[2].nickname, 'Aさん');
    });

    test('スコアが同点の場合はニックネームの辞書順で並ぶ', () {
      const friends = [
        Friend(
          id: 'f1',
          nickname: 'ZZZ',
          friendCode: 'NAZO-0001',
          clearedCount: 5,
          coins: 0,
        ),
        Friend(
          id: 'f2',
          nickname: 'AAA',
          friendCode: 'NAZO-0002',
          clearedCount: 5,
          coins: 0,
        ),
      ];

      final ranking = buildRanking(
        myNickname: 'MMM',
        myClearedCount: 100, // 自分は圧倒的に上位
        myCoins: 0,
        friends: friends,
      );

      expect(ranking.first.nickname, 'MMM');
      expect(ranking[1].nickname, 'AAA');
      expect(ranking[2].nickname, 'ZZZ');
    });

    test('フレンドが0人でも自分の1件だけのランキングが返る', () {
      final ranking = buildRanking(
        myNickname: '自分',
        myClearedCount: 0,
        myCoins: 0,
        friends: const [],
      );
      expect(ranking.length, 1);
      expect(ranking.single.isMe, isTrue);
    });
  });
}
