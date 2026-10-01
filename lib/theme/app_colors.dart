import 'package:flutter/material.dart';

/// GreenBin Material 3 Color Palette based on the Figma Eco-Green design system.
class AppColors {
  // Brand Primary & Eco Greens
  static const Color primary = Color(0xFF1B5E20); // Deep Forest Green
  static const Color primaryLight = Color(0xFF2E7D32); // Emerald Green
  static const Color primaryDark = Color(0xFF0D330E);
  static const Color primaryContainer = Color(0xFFE8F5E9); // Soft Eco Mint
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0D330E);

  // Secondary & Accents
  static const Color secondary = Color(0xFF00796B); // Deep Sage / Teal
  static const Color secondaryContainer = Color(0xFFE0F2F1);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF004D40);

  // Tertiary
  static const Color tertiary = Color(0xFFD97706); // Warm Earth Amber
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Neutrals - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAF8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F2);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEDF2F0);
  static const Color dividerLight = Color(0xFFEEF2F0);

  // Neutrals - Dark Mode
  static const Color backgroundDark = Color(0xFF111713);
  static const Color surfaceDark = Color(0xFF18221B);
  static const Color surfaceVariantDark = Color(0xFF212E25);
  static const Color borderDark = Color(0xFF2D3C32);
  static const Color dividerDark = Color(0xFF243028);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFF8FAFC);

  // Status / Lifecycle Colors
  static const Color statusPending = Color(0xFFEA580C);
  static const Color statusPendingBg = Color(0xFFFFF7ED);

  static const Color statusConfirmed = Color(0xFF0284C7);
  static const Color statusConfirmedBg = Color(0xFFF0F9FF);

  static const Color statusInTransit = Color(0xFF7C3AED);
  static const Color statusInTransitBg = Color(0xFFF5F3FF);

  static const Color statusCompleted = Color(0xFF16A34A);
  static const Color statusCompletedBg = Color(0xFFF0FDF4);

  static const Color statusCancelled = Color(0xFFDC2626);
  static const Color statusCancelledBg = Color(0xFFFEF2F2);
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // Waste Category Accent Colors
  static const Color plasticCategory = Color(0xFF2563EB); // Royal Blue
  static const Color paperCategory = Color(0xFFD97706); // Amber
  static const Color glassCategory = Color(0xFF0D9488); // Teal
  static const Color metalCategory = Color(0xFF64748B); // Slate
  static const Color ewasteCategory = Color(0xFF7C3AED); // Violet
  static const Color organicCategory = Color(0xFF16A34A); // Emerald

  // Visual Effects & Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintCardGradient = LinearGradient(
    colors: [Color(0xFFF1F8F3), Color(0xFFE8F5E9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
