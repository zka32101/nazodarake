import '../models/linked_puzzle_model.dart';
import '../models/puzzle_model.dart';

/// ステージ12「連動謎（ボーナス）」のデータ。
///
/// 4問の断片謎を解いて得られる文字を正しい順に組み合わせると、
/// 最終回答「シマフクロウ」（ナゾウの正体）が導き出される。
const LinkedPuzzleSet stage12LinkedPuzzleSet = LinkedPuzzleSet(
  id: 'linked_s12',
  stage: 12,
  title: 'ナゾウの正体',
  description:
      '4つの断片謎を解くと、それぞれ1〜3文字のカタカナが手に入る。\n'
      '手に入れた文字を出題順につなげると、ナゾウの正体を表す言葉になるはずだ。',
  fragments: [
    LinkedFragmentPuzzle(
      id: 'linked_s12_01',
      genre: PuzzleGenre.calculation,
      question: '次の計算をしてください。 3 × 4 - 5 = ？',
      answer: '7',
      fragment: 'シ',
      hints: ['掛け算を先に計算します', '3×4=12', '12-5を計算しよう'],
      difficulty: PuzzleDifficulty.easy,
      explanation: '3×4-5=7。正解すると断片「シ」が手に入ります。',
    ),
    LinkedFragmentPuzzle(
      id: 'linked_s12_02',
      genre: PuzzleGenre.wordplay,
      question:
          '「まつ（松）」の最初の文字を、50音表で1つ後ろにずらすと何になる？（ひらがな1文字で回答）',
      answer: 'み',
      fragment: 'マ',
      hints: ['「ま」行を思い出そう', 'あ・い・う・え・お の並びと同じ順番でずらします', '「ま」の次は「み」'],
      difficulty: PuzzleDifficulty.normal,
      explanation:
          '「ま」を1つ後ろにずらすと「み」。この謎の断片は「マ」（「まつ」の頭文字のカタカナ）です。',
    ),
    LinkedFragmentPuzzle(
      id: 'linked_s12_03',
      genre: PuzzleGenre.observation,
      question:
          '「ふ・く・ろ・う」の4文字のうち、ひらがな五十音表で「は行」に属する文字はどれ？'
          '（ひらがな1文字で回答）',
      answer: 'ふ',
      fragment: 'フ',
      hints: ['は・ひ・ふ・へ・ほ、を思い出そう', '4文字の中で「は行」は1つだけ', '一番最初の文字です'],
      difficulty: PuzzleDifficulty.easy,
      explanation: '「ふ」は「は行」に属します。この謎の断片は「フ」です。',
    ),
    LinkedFragmentPuzzle(
      id: 'linked_s12_04',
      genre: PuzzleGenre.riddle,
      question:
          '夜になると活動を始め、「ホーホー」と鳴く、ナゾウと同じ種類の鳥は何？（カタカナで回答）',
      answer: 'フクロウ',
      fragment: 'クロウ',
      hints: ['ナゾウ自身がこの鳥です', '夜行性の鳥として知られています', '「森の忍者」とも呼ばれる鳥です'],
      difficulty: PuzzleDifficulty.easy,
      explanation:
          'ナゾウは「フクロウ」です。この謎の断片は「クロウ」（「フクロウ」の3〜4文字目）です。',
    ),
  ],
  finalAnswer: 'シマフクロウ',
  finalExplanation:
      '「シ」「マ」「フ」「クロウ」をつなげると「シマフクロウ」。'
      'ナゾウの本当の種族は、北の島々に伝わる伝説の大きなフクロウ'
      '「シマフクロウ」だったのです。',
);

/// 連動謎セットの一覧（将来的に複数セットを追加できるように配列で保持）。
const List<LinkedPuzzleSet> allLinkedPuzzleSets = [stage12LinkedPuzzleSet];

/// ステージ番号から連動謎セットを取得する（存在しない場合はnull）。
LinkedPuzzleSet? linkedPuzzleSetForStage(int stage) {
  for (final set in allLinkedPuzzleSets) {
    if (set.stage == stage) return set;
  }
  return null;
}
