import 'package:flutter/material.dart';

abstract final class TrueGroundColors {
  static const Color background = Color(0xFFF6F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFECEFEA);
  static const Color primary = Color(0xFF214E45);
  static const Color primaryContainer = Color(0xFFD9E8E2);
  static const Color ink = Color(0xFF1E2926);
  static const Color inkMuted = Color(0xFF52605C);
  static const Color outline = Color(0xFFBBC5C1);
  static const Color error = Color(0xFF9D2C2C);
}

abstract final class TrueGroundSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class TrueGroundRadii {
  static const double card = 20;
  static const double control = 14;
}

abstract final class TrueGroundIcons {
  static const IconData home = Icons.home_outlined;
  static const IconData homeSelected = Icons.home_rounded;
  static const IconData loop = Icons.refresh_rounded;
  static const IconData practice = Icons.self_improvement_outlined;
  static const IconData practiceSelected = Icons.self_improvement_rounded;
  static const IconData support = Icons.people_outline_rounded;
  static const IconData supportSelected = Icons.people_rounded;
  static const IconData profile = Icons.person_outline_rounded;
  static const IconData profileSelected = Icons.person_rounded;
  static const IconData loading = Icons.hourglass_top_rounded;
  static const IconData empty = Icons.inbox_outlined;
  static const IconData error = Icons.error_outline_rounded;
}

abstract final class TrueGroundTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: TrueGroundColors.primary,
      onPrimary: Colors.white,
      primaryContainer: TrueGroundColors.primaryContainer,
      onPrimaryContainer: TrueGroundColors.ink,
      surface: TrueGroundColors.surface,
      onSurface: TrueGroundColors.ink,
      error: TrueGroundColors.error,
      onError: Colors.white,
      outline: TrueGroundColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TrueGroundColors.background,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: TrueGroundColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: TrueGroundColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: TrueGroundColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: TrueGroundColors.inkMuted,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        backgroundColor: TrueGroundColors.surface,
        indicatorColor: TrueGroundColors.primaryContainer,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TrueGroundColors.primary,
      ),
      cardTheme: CardThemeData(
        color: TrueGroundColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          side: const BorderSide(color: TrueGroundColors.outline),
        ),
      ),
    );
  }
}
