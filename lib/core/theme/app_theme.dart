import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.darkBlue,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppStyles.textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.darkBlue,
        secondary: AppColors.secondaryText,
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: AppStyles.title.copyWith(color: Colors.black),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.darkBlue,
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        hintStyle: TextStyle(color: AppColors.secondaryText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.cardBackground),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.inputBorder, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => AppColors.white,
        ),
        checkColor: WidgetStateProperty.resolveWith<Color>(
          (states) => AppColors.primaryText,
        ),
        side: const BorderSide(color: Colors.black, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        splashRadius: 20,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.inputBorder,
        thickness: 1,
        indent: 20,
        endIndent: 20,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryText,
        unselectedLabelColor: AppColors.secondaryText,
        indicatorColor: AppColors.background,
        dividerColor: AppColors.inputBorder,
        dividerHeight: 2,

        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.darkBlue, width: 2),
        ),
      ),
    );
  }
}
