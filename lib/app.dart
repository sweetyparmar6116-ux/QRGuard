import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';

/// Root widget for QRGuard.
///
/// Sets up the [MaterialApp] with the dark theme and named route table.
/// No business logic lives here — this file owns app-level wiring only.
class QRGuardApp extends StatelessWidget {
  const QRGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRGuard',
      debugShowCheckedModeBanner: false,
      theme: QRGuardTheme.dark(),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.scan: (_) => const ScannerScreen(),
        AppRoutes.history: (_) => const HistoryScreen(),
        // Result screens are pushed directly with decoded content and, for
        // history details, an optional stored analysis result.
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Route names
// ---------------------------------------------------------------------------

/// Centralised named-route constants.
///
/// Use these everywhere instead of raw strings so typos are caught at
/// compile time rather than at runtime.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String scan = '/scan';
  static const String result = '/result';
  static const String history = '/history';
}

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------

/// All visual design tokens for QRGuard in one place.
///
/// Colours, radii, and text styles are defined here so every screen
/// and widget can reference them consistently without magic numbers.
class QRGuardTheme {
  QRGuardTheme._();

  // --- Colour palette ---

  /// Deep navy — primary scaffold background.
  static const Color navy = Color(0xFF0A1628);

  /// Slightly lighter navy — used for surfaces such as app bars and cards.
  static const Color navyLight = Color(0xFF132038);

  /// Card background — sits above [navyLight] surfaces.
  static const Color card = Color(0xFF1A2D48);

  /// Teal accent — primary interactive colour.
  static const Color teal = Color(0xFF00BFA5);

  /// Teal at ~12 % opacity — used for icon container fills.
  static const Color tealSubtle = Color(0x1E00BFA5);

  /// Teal at ~30 % opacity — used for icon container borders.
  static const Color tealBorder = Color(0x4D00BFA5);

  /// Foreground colour on top of [teal] surfaces (buttons, etc.).
  static const Color onTeal = Color(0xFF000000);

  /// Primary text — near-white for strong contrast on dark backgrounds.
  static const Color textPrimary = Color(0xFFF0F4F8);

  /// Secondary text — muted blue-grey for supporting copy.
  static const Color textSecondary = Color(0xFF8FA8C0);

  /// Secondary text at ~35 % opacity — used for empty-state icons.
  static const Color textFaded = Color(0x598FA8C0);

  /// Subtle divider line between sections.
  static const Color divider = Color(0xFF1E3352);

  // Risk-level colours — always paired with a text label (never colour alone).

  /// Safe — no configured warning indicators triggered.
  static const Color safe = Color(0xFF4CAF50);

  /// Caution — one or more moderate warning indicators triggered.
  static const Color caution = Color(0xFFFFB300);

  /// High Risk — multiple or strong warning indicators triggered.
  static const Color highRisk = Color(0xFFEF5350);

  // --- Border radii ---

  /// Small radius (10) — compact chips or tags.
  static const double radiusSm = 10;

  /// Medium radius (14) — buttons and input fields.
  static const double radiusMd = 14;

  /// Large radius (20) — cards and sheets.
  static const double radiusLg = 20;

  /// Extra-large radius (28) — the icon container on the home screen.
  static const double radiusXl = 28;

  // ---------------------------------------------------------------------------

  /// Returns the single [ThemeData] instance used throughout the app.
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: teal,
      onPrimary: onTeal,
      secondary: teal,
      onSecondary: onTeal,
      surface: navyLight,
      onSurface: textPrimary,
      error: highRisk,
      onError: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: navy,
      dividerColor: divider,
      textTheme: _textTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: onTeal,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: teal,
          side: const BorderSide(color: teal, width: 1.5),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: highRisk, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: highRisk, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static TextTheme _textTheme() {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: textPrimary,
      ),
    );
  }
}
