import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/puzzles_data.dart';
import '../models/puzzle_model.dart';

/// 日付を 'yyyy-MM-dd' 形式の文字列にする（intl 非依存の軽量実装）。
String formatDateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// [date] の前日の日付キーを返す。
String formatPreviousDateKey(DateTime date) {
  final previous = date.subtract(const Duration(days: 1));
  return formatDateKey(previous);
}

/// 日付を決定的なシードに変換する（同じ日は常に同じ値になる）。
int _dateSeed(DateTime date) {
  return date.year * 10000 + date.month * 100 + date.day;
}

/// 指定した日付に対応するデイリーチャレンジの謎を、決定的に1問選ぶ。
/// 同じ日付を渡せば必ず同じ謎が返る。
Puzzle dailyPuzzleForDate(DateTime date) {
  final seed = _dateSeed(date);
  final index = seed % allPuzzles.length;
  return allPuzzles[index];
}

/// 今日の日付（時刻を切り捨てたローカル日付）。
DateTime todayDateOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// 今日のデイリーチャレンジの謎を返す Provider。
final todayDailyPuzzleProvider = Provider<Puzzle>((ref) {
  return dailyPuzzleForDate(todayDateOnly());
});

/// 今日の日付キー（'yyyy-MM-dd'）を返す Provider。
final todayDateKeyProvider = Provider<String>((ref) {
  return formatDateKey(todayDateOnly());
});
