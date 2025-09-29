import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.inter().fontFamily,
        hintColor: AppColors.gray.shade5,
        appBarTheme: _appBarTheme,
        inputDecorationTheme: _inputDecorationTheme,
        textTheme: _textTheme,
        cupertinoOverrideTheme: _cupertinoTheme,
        bottomNavigationBarTheme: _bottomNavigationBarTheme,
        switchTheme: _switchTheme,
        cardColor: AppColors.gray.shade1,
        cardTheme: CardThemeData(
          color: AppColors.gray.shade1,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: AppColors.gray.shade2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.gray.shade2,
          thickness: 1,
          space: 1,
          indent: 1,
          endIndent: 1,
        ),
      );

  static AppBarTheme get _appBarTheme => AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.gray.shade1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.gray.shade9,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        toolbarTextStyle: TextStyle(
          color: AppColors.blue.shade5,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        hintStyle: TextStyle(
          color: AppColors.gray.shade5,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(
          color: AppColors.red.shade4,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 1, color: AppColors.gray.shade2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 1, color: AppColors.blue.shade5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 1, color: AppColors.gray.shade2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 1, color: AppColors.gray.shade1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 1, color: AppColors.red.shade4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 1, color: AppColors.red.shade7),
        ),
      );

  static TextTheme get _textTheme => TextTheme(
        // for TextField
        bodyLarge: TextStyle(
          color: AppColors.gray.shade9,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        // for Text
        bodyMedium: TextStyle(
          color: AppColors.gray.shade9,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );

  static CupertinoThemeData get _cupertinoTheme => CupertinoThemeData(
        primaryColor: AppColors.blue.shade5,
        textTheme: const CupertinoTextThemeData(
          actionTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.gray.shade9,
        unselectedItemColor: AppColors.gray.shade5,
        selectedIconTheme: const IconThemeData(size: 20),
        unselectedIconTheme: const IconThemeData(size: 20),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      );

  static SwitchThemeData get _switchTheme => SwitchThemeData(
        splashRadius: 20,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.all(AppColors.gray.shade9),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      );
}
