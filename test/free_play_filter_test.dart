import 'package:flutter_test/flutter_test.dart';
import 'package:nazodarake/models/puzzle_model.dart';
import 'package:nazodarake/providers/free_play_provider.dart';

void main() {
  final samplePuzzles = <Puzzle>[
    const Puzzle(
      id: 'p1',
      stage: 1,
      genre: PuzzleGenre.riddle,
      question: 'Q1',
      answer: 'A1',
      hints: ['h'],
      difficulty: PuzzleDifficulty.easy,
    ),
    const Puzzle(
      id: 'p2',
      stage: 2,
      genre: PuzzleGenre.calculation,
      question: 'Q2',
      answer: 'A2',
      hints: ['h'],
      difficulty: PuzzleDifficulty.hard,
    ),
    const Puzzle(
      id: 'p3',
      stage: 3,
      genre: PuzzleGenre.riddle,
      question: 'Q3',
      answer: 'A3',
      hints: ['h'],
      difficulty: PuzzleDifficulty.hard,
    ),
  ];

  group('filterPuzzles', () {
    test('引数なしなら全件を返す', () {
      expect(filterPuzzles(samplePuzzles).length, 3);
    });

    test('ジャンルで絞り込める', () {
      final result = filterPuzzles(samplePuzzles, genre: PuzzleGenre.riddle);
      expect(result.map((p) => p.id), ['p1', 'p3']);
    });

    test('難易度で絞り込める', () {
      final result =
          filterPuzzles(samplePuzzles, difficulty: PuzzleDifficulty.hard);
      expect(result.map((p) => p.id), ['p2', 'p3']);
    });

    test('ジャンルと難易度の両方で絞り込める', () {
      final result = filterPuzzles(
        samplePuzzles,
        genre: PuzzleGenre.riddle,
        difficulty: PuzzleDifficulty.hard,
      );
      expect(result.map((p) => p.id), ['p3']);
    });

    test('該当なしの場合は空リストを返す', () {
      final result = filterPuzzles(
        samplePuzzles,
        genre: PuzzleGenre.logic,
      );
      expect(result, isEmpty);
    });
  });
}
