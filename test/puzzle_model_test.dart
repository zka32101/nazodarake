import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/data/puzzles_data.dart';
import 'package:nazodarake/models/puzzle_model.dart';

void main() {
  group('Puzzle.isCorrect', () {
    test('完全一致で正解と判定される', () {
      const puzzle = Puzzle(
        id: 'test_1',
        stage: 1,
        genre: PuzzleGenre.riddle,
        question: 'テスト問題',
        answer: 'こたえ',
        hints: ['ヒント1'],
        difficulty: PuzzleDifficulty.easy,
      );
      expect(puzzle.isCorrect('こたえ'), isTrue);
    });

    test('前後の空白を無視して正解判定する', () {
      const puzzle = Puzzle(
        id: 'test_2',
        stage: 1,
        genre: PuzzleGenre.riddle,
        question: 'テスト問題',
        answer: 'こたえ',
        hints: ['ヒント1'],
        difficulty: PuzzleDifficulty.easy,
      );
      expect(puzzle.isCorrect('  こたえ  '), isTrue);
      expect(puzzle.isCorrect('　こたえ　'), isTrue);
    });

    test('大文字小文字を無視して正解判定する(英語)', () {
      const puzzle = Puzzle(
        id: 'test_3',
        stage: 1,
        genre: PuzzleGenre.cipher,
        question: 'Test',
        answer: 'HELLO',
        hints: ['ヒント1'],
        difficulty: PuzzleDifficulty.normal,
      );
      expect(puzzle.isCorrect('hello'), isTrue);
      expect(puzzle.isCorrect('Hello'), isTrue);
    });

    test('空文字は不正解になる', () {
      const puzzle = Puzzle(
        id: 'test_4',
        stage: 1,
        genre: PuzzleGenre.riddle,
        question: 'テスト問題',
        answer: 'こたえ',
        hints: ['ヒント1'],
        difficulty: PuzzleDifficulty.easy,
      );
      expect(puzzle.isCorrect(''), isFalse);
      expect(puzzle.isCorrect('   '), isFalse);
    });

    test('間違った答えは不正解になる', () {
      const puzzle = Puzzle(
        id: 'test_5',
        stage: 1,
        genre: PuzzleGenre.riddle,
        question: 'テスト問題',
        answer: 'こたえ',
        hints: ['ヒント1'],
        difficulty: PuzzleDifficulty.easy,
      );
      expect(puzzle.isCorrect('ちがうこたえ'), isFalse);
    });

    test('isFreeInput は options が null のとき true', () {
      const freeInputPuzzle = Puzzle(
        id: 'test_6',
        stage: 1,
        genre: PuzzleGenre.riddle,
        question: 'テスト問題',
        answer: 'こたえ',
        hints: ['ヒント1'],
        difficulty: PuzzleDifficulty.easy,
      );
      const optionsPuzzle = Puzzle(
        id: 'test_7',
        stage: 1,
        genre: PuzzleGenre.observation,
        question: 'テスト問題',
        options: ['A', 'B'],
        answer: 'A',
        hints: ['ヒント1'],
        difficulty: PuzzleDifficulty.easy,
      );
      expect(freeInputPuzzle.isFreeInput, isTrue);
      expect(optionsPuzzle.isFreeInput, isFalse);
    });
  });

  group('allPuzzles データセット', () {
    test('合覈30問以上のパズルが存在する', () {
      expect(allPuzzles.length, greaterThanOrEqualTo(30));
    });

    test('全てのIDが一意である', () {
      final ids = allPuzzles.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('5ステージ以上が存在する', () {
      expect(allStageNumbers.length, greaterThanOrEqualTo(5));
    });

    test('全問にヒントが1つ以上設定されている', () {
      for (final puzzle in allPuzzles) {
        expect(puzzle.hints, isNotEmpty, reason: '${puzzle.id} にヒントがありません');
      }
    });

    test('選択肢問題は正解が選択肢に含まれている', () {
      for (final puzzle in allPuzzles) {
        if (puzzle.options != null) {
          expect(
            puzzle.options!.contains(puzzle.answer),
            isTrue,
            reason: '${puzzle.id} の正解が選択肢にありません',
          );
        }
      }
    });

    test('groupPuzzlesByStage はステージごとに正しく分類する', () {
      final grouped = groupPuzzlesByStage();
      for (final entry in grouped.entries) {
        for (final puzzle in entry.value) {
          expect(puzzle.stage, entry.key);
        }
      }
    });
  });
}
