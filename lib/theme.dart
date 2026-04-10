import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NVColors {
  static const surface = Color(0xFF040D12);
  static const surfaceContainer = Color(0xFF131d22);
  static const surfaceContainerHigh = Color(0xFF1c2a30);
  static const surfaceContainerLow = Color(0xFF0a151a);
  static const surfaceVariant = Color(0xFF183D3D);
  static const primary = Color(0xFF93B1A6);
  static const primaryLight = Color(0xFFAFCDC2);
  static const secondary = Color(0xFF5C8374);
  static const onSurface = Color(0xFFD9E4EB);
  static const onSurfaceVariant = Color(0xFF93B1A6);
  static const outline = Color(0xFF5C8374);
}

class NVTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NVColors.surface,
        colorScheme: const ColorScheme.dark(
          surface: NVColors.surface,
          primary: NVColors.primary,
          secondary: NVColors.secondary,
          onSurface: NVColors.onSurface,
          outline: NVColors.outline,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: NVColors.surfaceContainerLow,
          foregroundColor: NVColors.primaryLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: NVColors.surfaceContainer.withOpacity(0.85),
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'SpaceGrotesk', color: NVColors.onSurface),
          displayMedium: TextStyle(fontFamily: 'SpaceGrotesk', color: NVColors.onSurface),
          headlineLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, color: NVColors.onSurface),
          headlineMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, color: NVColors.onSurface),
          titleLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, color: NVColors.onSurface),
          bodyLarge: TextStyle(color: NVColors.onSurface),
          bodyMedium: TextStyle(color: NVColors.onSurfaceVariant),
        ),
      );

  static Map<String, Color> languageColors = {
    'Python': const Color(0xFF3776AB),
    'JavaScript': const Color(0xFFF7DF1E),
    'TypeScript': const Color(0xFF007ACC),
    'Swift': const Color(0xFFF05333),
    'Dart': const Color(0xFF0175C2),
    'Rust': const Color(0xFFCE422B),
    'Go': const Color(0xFF00ADD8),
    'CSS': const Color(0xFF264DE4),
    'HTML': const Color(0xFFE34F26),
    'Kotlin': const Color(0xFF7F52FF),
  };

  static Color langColor(String lang) =>
      languageColors[lang] ?? NVColors.primary;
}
