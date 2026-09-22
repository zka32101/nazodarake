import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/data/linked_puzzles_data.dart';
import 'package:nazodarake/models/linked_puzzle_model.dart';
import 'package:nazodarake/models/puzzle_model.dart';

void main() {
  group('LinkedFragmentPuzzle.isCorrect', () {
    test('完全一致で正解と判定される', () {
      const fragment = LinkedFragmentPuzzle(
        id: 'f1',
        genre: PuzzleGenre.calculation,
        question: 'テスト',
        answer: '7',
        fragment: 'シ',
        hints: ['ヒント'],
        difficulty: PuzzleDifficulty.easy,
      );
      expect(fragment.isCorrect('7'), isTrue);
      expect(fragment.isCorrect(' 7 '), isTrue);
      expect(fragment.isCorrect('8'), isFalse);
    });

    test('空文字は不正解として扱う', () {
      const fragment = LinkedFragmentPuzzle(
        id: 'f2',
        genre: PuzzleGenre.riddle,
        question: 'テスト',
        answer: 'こたえ',
        fragment: 'コ',
        hints: ['ヒント'],
        difficulty: PuzzleDifficulty.easy,
      );
      expect(fragment.isCorrect(''), isFalse);
      expect(fragment.isCorrect('   '), isFalse);
    });
  });

  group('LinkedPuzzleSet', () {
    test('combinedFragments は断片を出題順に連結する', () {
      expect(stage12LinkedPuzzleSet.combinedFragments, 'シマフクロウ');
    });

    test('isFinalAnswerCorrect は最終回答と一致する場合のみ true', () {
      expect(
        stage12LinkedPuzzleSet.isFinalAnswerCorrect('シマフクロウ'),
        isTrue,
      );
      expect(
        stage12LinkedPuzzleSet.isFinalAnswerCorrect('  シマフクロウ  '),
        isTrue,
      );
      expect(
        stage12LinkedPuzzleSet.isFinalAnswerCorrect('フクロウ'),
        isFalse,
      );
    });

    test('全ての断片正解を組み合わせると最終回答と一致する（データ整合性チェック）', () {
      expect(
        stage12LinkedPuzzleSet.isFinalAnswerCorrect(
          stage12LinkedPuzzleSet.combinedFragments,
        ),
        isTrue,
      );
    });

    test('断片は3問以上ある', () {
      expect(stage12LinkedPuzzleSet.fragments.length, greaterThanOrEqualTo(3));
    });

    test('linkedPuzzleSetForStage はステージ番号から正しいセットを返す', () {
      expect(linkedPuzzleSetForStage(12), isNotNull);
      expect(linkedPuzzleSetForStage(12)!.id, 'linked_s12');
      expect(linkedPuzzleSetForStage(999), isNull);
    });
  });
}
