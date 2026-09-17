import 'package:flutter/material.dart';

abstract final class TrueGroundColors {
  static const Color background = Color(0xFFF3F1F0);
  static const Color surface = Color(0xFFFCFBFA);
  static const Color surfaceMuted = Color(0xFFF0F0EE);
  static const Color primary = Color(0xFF14375C);
  static const Color primaryContainer = Color(0xFFDDEBED);
  static const Color heroBlue = Color(0xFF245D8A);
  static const Color heroIconBlue = Color(0xFF267BB4);
  static const Color teal = Color(0xFF3E8790);
  static const Color iconWash = Color(0xFFE5EFF0);
  static const Color ink = Color(0xFF152D4A);
  static const Color inkMuted = Color(0xFF5E6878);
  static const Color outline = Color(0xFFD8D7D4);
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
      navigationBarTheme: NavigationBarThemeData(
        height: 84,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12.5,
            height: 1,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: TrueGroundColors.primary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: selected ? 26 : 24,
            color: TrueGroundColors.primary,
          );
        }),
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
