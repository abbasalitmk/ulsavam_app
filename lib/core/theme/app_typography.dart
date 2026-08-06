import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle displayLarge = GoogleFonts.hankenGrotesk(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.8,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLarge = GoogleFonts.hankenGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.hankenGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.6,
    color: AppColors.onSurfaceVariant,
  );
}
