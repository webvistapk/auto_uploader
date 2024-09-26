import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:sizer/sizer.dart';

class AppTextStyles {
  static TextStyle poppinsRegular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 14,
      color: color ?? AppColors.black,
      fontWeight: fontWeight ?? FontWeight.normal,
      letterSpacing: letterSpacing ?? 0,
    );
  }

  static TextStyle poppinsSemiBold({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 15,
      color: color ?? AppColors.black,
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? 0,
    );
  }

  static TextStyle poppinsBold({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 18,
      color: color ?? AppColors.black,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing ?? 0,
    );
  }

  static TextStyle poppinsMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 17,
      color: color ?? AppColors.black,
      fontWeight: fontWeight ?? FontWeight.w500,
      letterSpacing: letterSpacing ?? 0,
    );
  }
}
