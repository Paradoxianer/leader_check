import 'package:flutter/material.dart';

/// Farben und Textstile der App.
///
/// Die Palette ist bewusst gedämpft: ein tiefes Blaugrün als Grundton, dazu
/// genau zwei Signalfarben — Bernstein für Risiko, Salbei für den gesunden
/// Pol. Das Ergebnis soll wie eine Standortbestimmung wirken, nicht wie eine
/// Ampel, die einen abstraft.
class AppColors {
  const AppColors._();

  static const Color ink = Color(0xFF14262B);
  static const Color surface = Color(0xFFF3F1EC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF2E6B6B);
  static const Color risk = Color(0xFFC97B2E);
  static const Color healthy = Color(0xFF6E8F62);
  static const Color muted = Color(0xFF6C7B7F);

  /// Farbe für einen Skalenwert 0–100 auf einer Risikoskala.
  static Color forRisk(double percent) {
    if (percent < 30) return healthy;
    if (percent < 55) return const Color(0xFFB2A14A);
    return risk;
  }
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.risk,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    ),
    textTheme: base.textTheme
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
        .copyWith(
          displaySmall: const TextStyle(
            fontSize: 34,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
          headlineSmall: const TextStyle(
            fontSize: 22,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          titleMedium: const TextStyle(
            fontSize: 17,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          bodyLarge: const TextStyle(
            fontSize: 17,
            height: 1.45,
            color: AppColors.ink,
          ),
          bodyMedium: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.ink,
          ),
          labelSmall: const TextStyle(
            fontSize: 12,
            height: 1.3,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// Maximale Inhaltsbreite. Ohne das wird die Weboberfläche auf großen
/// Bildschirmen unlesbar breit.
const double kContentMaxWidth = 620;
