import 'package:flutter/material.dart';

class AppColors {
  static const background  = Color(0xFFF2F2F0);
  static const card        = Color(0xFFFFFFFF);
  static const cardDark    = Color(0xFF111111);
  static const textPrimary = Color(0xFF111111);
  static const textMuted   = Color(0xFF999999);
  static const textHint    = Color(0xFFBBBBBB);
  static const border      = Color(0xFFE8E8E8);
  static const tag         = Color(0xFFF2F2F0);
}

class AppTextStyles {
  static const screenTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 1.5,
  );

  static const cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const cardMeta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const statNumber = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    fontFamily: 'DMMono',
  );

  static const statLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  static const greeting = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.textMuted,
  );

  static const tagText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'DMSans',
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      surface:    AppColors.card,
      primary:    AppColors.cardDark,
      onPrimary:  AppColors.card,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.background,
      indicatorColor:  Colors.transparent,
      labelTextStyle:  WidgetStatePropertyAll(TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFamily: 'DMSans',
      )),
    ),
  );
}