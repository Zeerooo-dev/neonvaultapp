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

  /// Official / recognisable brand colours for each language.
  static const Map<String, Color> languageColors = {
    'Python':      Color(0xFF3776AB),
    'JavaScript':  Color(0xFFF7DF1E),
    'TypeScript':  Color(0xFF007ACC),
    'Swift':       Color(0xFFF05333),
    'Dart':        Color(0xFF0175C2),
    'Rust':        Color(0xFFCE422B),
    'Go':          Color(0xFF00ADD8),
    'CSS':         Color(0xFF264DE4),
    'HTML':        Color(0xFFE34F26),
    'Kotlin':      Color(0xFF7F52FF),
    // ── New languages ──
    'Java':        Color(0xFFED8B00),
    'C':           Color(0xFF5C6BC0),
    'C++':         Color(0xFF00599C),
    'C#':          Color(0xFF9B4F96),
    'PHP':         Color(0xFF777BB4),
    'Ruby':        Color(0xFFCC342D),
    'Scala':       Color(0xFFDC322F),
    'R':           Color(0xFF2166AC),
    'Shell':       Color(0xFF4EAA25),
    'Bash':        Color(0xFF4EAA25),
    'PowerShell':  Color(0xFF012456),
    'SQL':         Color(0xFFE38C00),
    'GraphQL':     Color(0xFFE10098),
    'YAML':        Color(0xFFCB171E),
    'JSON':        Color(0xFF8BC34A),
    'Markdown':    Color(0xFF083FA1),
    'XML':         Color(0xFFFF6600),
    'Lua':         Color(0xFF2C2D72),
    'Perl':        Color(0xFF39457E),
    'Haskell':     Color(0xFF5E5086),
    'Elixir':      Color(0xFF6E4A7E),
    'Clojure':     Color(0xFF5881D8),
    'Dockerfile':  Color(0xFF2496ED),
    'Terraform':   Color(0xFF7B42BC),
    'Assembly':    Color(0xFF6E4C13),
  };

  static Color langColor(String lang) =>
      languageColors[lang] ?? NVColors.primary;

  /// Maps a language name to its highlight.js mode identifier.
  static String highlightLang(String lang) {
    switch (lang.toLowerCase()) {
      case 'javascript':  return 'javascript';
      case 'typescript':  return 'typescript';
      case 'python':      return 'python';
      case 'dart':        return 'dart';
      case 'swift':       return 'swift';
      case 'kotlin':      return 'kotlin';
      case 'java':        return 'java';
      case 'c':           return 'c';
      case 'c++':         return 'cpp';
      case 'c#':          return 'cs';
      case 'go':          return 'go';
      case 'rust':        return 'rust';
      case 'php':         return 'php';
      case 'ruby':        return 'ruby';
      case 'scala':       return 'scala';
      case 'r':           return 'r';
      case 'shell':
      case 'bash':        return 'bash';
      case 'powershell':  return 'powershell';
      case 'sql':         return 'sql';
      case 'graphql':     return 'graphql';
      case 'yaml':        return 'yaml';
      case 'json':        return 'json';
      case 'markdown':    return 'markdown';
      case 'xml':         return 'xml';
      case 'html':        return 'xml';
      case 'css':         return 'css';
      case 'lua':         return 'lua';
      case 'perl':        return 'perl';
      case 'haskell':     return 'haskell';
      case 'elixir':      return 'elixir';
      case 'clojure':     return 'clojure';
      case 'dockerfile':  return 'dockerfile';
      default:            return 'plaintext';
    }
  }
}
