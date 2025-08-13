import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static const String _fontFamily = 'HostGrotesk';

  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(fontFamily: _fontFamily),
    displayMedium: TextStyle(fontFamily: _fontFamily),
    displaySmall: TextStyle(fontFamily: _fontFamily),
    headlineLarge: TextStyle(fontFamily: _fontFamily),
    headlineMedium: TextStyle(fontFamily: _fontFamily),
    headlineSmall: TextStyle(fontFamily: _fontFamily),
    titleLarge: TextStyle(fontFamily: _fontFamily),
    titleMedium: TextStyle(fontFamily: _fontFamily),
    titleSmall: TextStyle(fontFamily: _fontFamily),
    bodyLarge: TextStyle(fontFamily: _fontFamily),
    bodyMedium: TextStyle(fontFamily: _fontFamily),
    bodySmall: TextStyle(fontFamily: _fontFamily),
    labelLarge: TextStyle(fontFamily: _fontFamily),
    labelMedium: TextStyle(fontFamily: _fontFamily),
    labelSmall: TextStyle(fontFamily: _fontFamily),
  );

  static TextStyle get title => textTheme.headlineLarge!.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static TextStyle get title2 => textTheme.headlineMedium!.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static TextStyle get body => textTheme.bodyMedium!.copyWith(
    fontSize: 16,
    color: AppColors.primaryText,
  );

  static TextStyle get labelButtonSmall => textTheme.bodyMedium!.copyWith(
    fontSize: 16,
    color: AppColors.primaryText,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get button => textTheme.labelLarge!.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static TextStyle get buttonText => textTheme.labelLarge!.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    color: AppColors.primary,
  );

  static TextStyle get link => textTheme.bodyMedium!.copyWith(
    fontSize: 14,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  static TextStyle get buttonPrimary => textTheme.labelLarge!.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
