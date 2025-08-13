import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppStyles {
  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme();

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

  static TextStyle get link => textTheme.bodyMedium!.copyWith(
    fontSize: 14,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
}
