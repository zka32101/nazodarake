/// 謎解きのジャンル。
enum PuzzleGenre {
  riddle, // なぞなぞ
  cipher, // 暗号解読
  observation, // 観察系
  inspiration, // ひらめき
  calculation, // 計算パズル
}

extension PuzzleGenreLabel on PuzzleGenre {
  String get label {
    switch (this) {
      case PuzzleGenre.riddle:
        return 'なぞなぞ';
      case PuzzleGenre.cipher:
        return '暗号解読';
      case PuzzleGenre.observation:
        return '観察系';
      case PuzzleGenre.inspiration:
        return 'ひらめき';
      case PuzzleGenre.calculation:
        return '計算パズル';
    }
  }
}

/// 謎の難易度。
enum PuzzleDifficulty {
  easy,
  normal,
  hard,
}

extension PuzzleDifficultyLabel on PuzzleDifficulty {
  String get label {
    switch (this) {
      case PuzzleDifficulty.easy:
        return '★☆☆';
      case PuzzleDifficulty.normal:
        return '★★☆';
      case PuzzleDifficulty.hard:
        return '★★★';
    }
  }
}

/// 1問分の謎データモデル。
///
/// [options] が null の場合は自由入力形式、
/// 値がある場合は選択肢形式として扱う。
class Puzzle {
  const Puzzle({
    required this.id,
    required this.stage,
    required this.genre,
    required this.question,
    required this.answer,
    required this.hints,
    required this.difficulty,
    this.options,
    this.hasImage = false,
    this.explanation,
  });

  /// 一意なID（例: 's1_01'）。
  final String id;

  /// 所属するステージ番号（1始まり）。
  final int stage;

  /// ジャンル。
  final PuzzleGenre genre;

  /// 問題文。
  final String question;

  /// 正解（自由入力の場合は完全一致・トリム・ひらがな/カタカナ等を
  /// [isCorrect] 側で緩めに判定する）。選択肢形式の場合は正解の選択肢文字列。
  final String answer;

  /// 段階的ヒント（1段階目、2段階目...の順）。
  final List<String> hints;

  /// 難易度。
  final PuzzleDifficulty difficulty;

  /// 選択肢（nullなら自由入力形式）。
  final List<String>? options;

  /// 画像を伴う問題かどうか（本実装ではテキストベースの図解で代替）。
  final bool hasImage;

  /// 正解後に表示する解説文（あれば）。
  final String? explanation;

  bool get isFreeInput => options == null;

  /// ユーザー入力に対する正誤判定。
  /// 前後の空白除去・全角/半角スペース除去・大文字小文字の統一を行う。
  bool isCorrect(String userInput) {
    final normalizedInput = _normalize(userInput);
    final normalizedAnswer = _normalize(answer);
    if (normalizedInput.isEmpty) return false;
    return normalizedInput == normalizedAnswer;
  }

  static String _normalize(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('　', '')
        .toLowerCase();
  }
}
