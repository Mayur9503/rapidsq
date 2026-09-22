import 'package:flutter/material.dart';

/// Civic Operational Dispatch color palette from DESIGN.md
class AppColors {
  AppColors._();

  // Primary Emergency Accent (Strictly rationed for high-priority emergency actions)
  static const Color primary = Color(0xFF93000B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFB91C1C);
  static const Color onPrimaryContainer = Color(0xFFFFCDC7);
  static const Color primaryFixed = Color(0xFFFFDAD6);
  static const Color primaryFixedDim = Color(0xFFFFB4AB);
  static const Color onPrimaryFixed = Color(0xFF410002);
  static const Color onPrimaryFixedVariant = Color(0xFF93000B);

  // Surface & Canvas (Crisp neutral high-legibility backgrounds)
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);

  // Content & Typography
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF5B403D);
  static const Color outline = Color(0xFF8F6F6C);
  static const Color outlineVariant = Color(0xFFE4BEB9);
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inverseOnSurface = Color(0xFFEFF1F3);

  // Secondary (Deep Slate for structural buttons, labels, and secondary actions)
  static const Color secondary = Color(0xFF565E74);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDAE2FD);
  static const Color onSecondaryContainer = Color(0xFF5C647A);
  static const Color secondaryFixed = Color(0xFFDAE2FD);
  static const Color onSecondaryFixed = Color(0xFF131B2E);

  // Tertiary (Unit Emerald for validated responder connections, telemetry, positive states)
  static const Color tertiary = Color(0xFF00513A);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF006C4E);
  static const Color onTertiaryContainer = Color(0xFF8DEBC2);
  static const Color tertiaryFixed = Color(0xFF97F5CC);
  static const Color tertiaryFixedDim = Color(0xFF7BD8B1);
  static const Color onTertiaryFixed = Color(0xFF002115);
  static const Color onTertiaryFixedVariant = Color(0xFF00513A);

  // Telemetry Amber (Queue buffering, search beacons)
  static const Color amber = Color(0xFFD97706);
  static const Color amberContainer = Color(0xFFFEF3C7);

  // Statutory Emergency Alert (Error / Red)
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Border precision
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
}
