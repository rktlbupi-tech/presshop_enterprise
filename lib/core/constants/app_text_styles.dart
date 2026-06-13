import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Headings ─────────────────────────────────────────────
  static TextStyle get h1 => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get h4 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        fontFamily: 'Poppins',
      );

  // ── Label ────────────────────────────────────────────────
  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFamily: 'Poppins',
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        fontFamily: 'Poppins',
      );

  // ── Button ───────────────────────────────────────────────
  static TextStyle get button => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        fontFamily: 'Poppins',
        letterSpacing: 0.5,
      );

  // ── Input ────────────────────────────────────────────────
  static TextStyle get input => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get inputHint => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        fontFamily: 'Poppins',
      );

  static TextStyle get inputLabel => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFamily: 'Poppins',
      );

  // ── Caption ──────────────────────────────────────────────
  static TextStyle get caption => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        fontFamily: 'Poppins',
      );

  static TextStyle get overline => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        fontFamily: 'Poppins',
        letterSpacing: 1.2,
      );
}
