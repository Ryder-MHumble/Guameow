import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFFFF9BBE);
  static const Color secondary = Color(0xFFFFD1DC);
  static const Color accent = Color(0xFFA3D8FF);
  static const Color background = Color(0xFFFFF5F7);
  
  // Fortune colors
  static const Color fortuneGood = Color(0xFF4CAF50);    // 上签颜色
  static const Color fortuneMiddle = Color(0xFF9C27B0);  // 中签颜色
  static const Color fortuneBad = Color(0xFFE91E63);     // 下签颜色
  static const Color fortuneText = Color(0xFF333333);    // 正文颜色
  static const Color fortuneHint = Color(0xFF666666);    // 提示文字颜色

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'ZenMaruGothic',
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get bodyStyle => TextStyle(
        fontWeight: FontWeight.w300,
        color: Colors.black87,
      );

  // Shadows
  static BoxShadow get softShadow => BoxShadow(
        color: Colors.pink.withOpacity(0.1),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  // Border Radius
  static const double smallRadius = 12;
  static const double mediumRadius = 24;
  static const double largeRadius = 36;

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        textTheme: TextTheme(
          displayLarge: titleStyle.copyWith(fontSize: 32),
          displayMedium: titleStyle.copyWith(fontSize: 28),
          displaySmall: titleStyle.copyWith(fontSize: 24),
          bodyLarge: bodyStyle.copyWith(fontSize: 16),
          bodyMedium: bodyStyle.copyWith(fontSize: 14),
          bodySmall: bodyStyle.copyWith(fontSize: 12),
        ),
      );
}
