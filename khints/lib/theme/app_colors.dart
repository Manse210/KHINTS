import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color navy = Color(0xFF1A2340);
  static const Color navyDark = Color(0xFF111827);
  static const Color blue = Color(0xFF2E5FA3);
  static const Color accent = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFFEBF2FF);
  static const Color background = Color(0xFFF8FAFC);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color white = Colors.white;

  // Badge colors per type
  static const Color badgeDS = Color(0xFF3B82F6);   // Blue
  static const Color badgeEX = Color(0xFF22C55E);   // Green
  static const Color badgeCC = Color(0xFF8B5CF6);   // Purple
  static const Color badgeCO = Color(0xFFF97316);   // Orange
  static const Color badgeTD = Color(0xFFEAB308);   // Yellow

  // Department accent colors
  static const Color deptGI = Color(0xFF3B82F6);
  static const Color deptBio = Color(0xFF8B5CF6);
  static const Color deptMeca = Color(0xFF22C55E);
  static const Color deptGestion = Color(0xFFF97316);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  /// Returns the badge color for a document type
  static Color badgeColor(String type) {
    switch (type.toUpperCase()) {
      case 'DS':
        return badgeDS;
      case 'EX':
        return badgeEX;
      case 'CC':
        return badgeCC;
      case 'CO':
        return badgeCO;
      case 'TD':
        return badgeTD;
      default:
        return accent;
    }
  }
}
