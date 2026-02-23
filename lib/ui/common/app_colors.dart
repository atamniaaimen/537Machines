import 'package:flutter/material.dart';

class AppColors {
  // 537 Machines — Primary Green
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryLight = Color(0xFFA3E4B8);
  static const Color primaryDark = Color(0xFF1A9B4F);
  static const Color primaryPale = Color(0xFFE8F8EF);

  // Darks
  static const Color dark = Color(0xFF2D3436);
  static const Color darker = Color(0xFF1A1D22);
  static const Color darkest = Color(0xFF0F1114);

  // Grays
  static const Color gray50 = Color(0xFFFAFBFB);
  static const Color gray100 = Color(0xFFF0F3F2);
  static const Color gray150 = Color(0xFFE8ECEB);
  static const Color gray200 = Color(0xFFDFE6E9);
  static const Color gray300 = Color(0xFFB2BEC3);
  static const Color gray400 = Color(0xFF7F8C8D);
  static const Color gray500 = Color(0xFF636E72);

  // Semantic
  static const Color danger = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);

  // Condition badge colors
  static const Color conditionNew = Color(0xFFE8F8EF);
  static const Color conditionNewText = Color(0xFF1A9B4F);
  static const Color conditionUsed = Color(0xFFFEF3E2);
  static const Color conditionUsedText = Color(0xFFE67E22);
  static const Color conditionRefurb = Color(0xFFEBF5FB);
  static const Color conditionRefurbText = Color(0xFF2980B9);

  // Core surfaces
  static const Color background = Color(0xFFF0F3F2);
  static const Color surface = Color(0xFFFFFFFF);

  // Backward-compat aliases
  static const Color accent = primaryDark;
  static const Color error = danger;
  static const Color success = primaryDark;
  static const Color textPrimary = dark;
  static const Color textSecondary = gray500;
  static const Color textHint = gray300;
  static const Color divider = gray150;
  static const Color cardShadow = Color(0x1A000000);
}
