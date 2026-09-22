import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// なぞだらけ アプリ全体の Material3 テーマ定義。
/// ライト / ダーク両対応。
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF5C4DFF);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return _baseTheme(colorScheme);
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return _baseTheme(colorScheme);
  }

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.mPlusRounded1cTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
      ),
    );
  }
}

/// アクセシビリティ対応：設定画面で選べる文字サイズ（小/標準/大）を
/// 実際の [TextScaler] 倍率にマッピングするヘルパー。
///
/// 端末のシステム設定によるテキストスケールに追従しすぎるとレイアウトが
/// 崩れる箇所があるため、アプリ内設定を優先しつつ [maxScaleFactor] /
/// [minScaleFactor] で極端な値をクランプしている。
class AppTextScale {
  AppTextScale._();

  static const double small = 0.85;
  static const double standard = 1.0;
  static const double large = 1.2;

  /// レイアウト崩れを防ぐための下限・上限。
  static const double minScaleFactor = 0.8;
  static const double maxScaleFactor = 1.3;

  /// ['small', 'standard', 'large'] のいずれか（未知の値/nullは標準扱い）
  /// から倍率を返す。
  static double factorFor(String? option) {
    switch (option) {
      case 'small':
        return small;
      case 'large':
        return large;
      case 'standard':
      default:
        return standard;
    }
  }

  /// [option] に対応する [TextScaler] を、レイアウト崩れ防止のため
  /// [minScaleFactor]〜[maxScaleFactor] の範囲にクランプして返す。
  static TextScaler scalerFor(String? option) {
    final factor = factorFor(option);
    return TextScaler.linear(factor).clamp(
      minScaleFactor: minScaleFactor,
      maxScaleFactor: maxScaleFactor,
    );
  }
}
