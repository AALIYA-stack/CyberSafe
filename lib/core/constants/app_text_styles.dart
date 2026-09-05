import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ==========================================================
  // HEADINGS
  // ==========================================================

  static const TextStyle headingLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  // ==========================================================
  // TITLES
  // ==========================================================

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ==========================================================
  // BODY
  // ==========================================================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // ==========================================================
  // BUTTON
  // ==========================================================

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ==========================================================
  // LABEL
  // ==========================================================

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  // ==========================================================
  // CAPTION
  // ==========================================================

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
  );
}