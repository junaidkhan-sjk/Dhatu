import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ─── Neumorphic Color Constants ─────────────────────────────
  // Dark Neumorphism: Midnight Soft Slate & Navy
  static const Color darkCanvas = Color(0xFF0D1322);
  static const Color darkSurface = Color(0xFF131C31);
  static const Color darkHighlight = Color(0xFF1D2A47); // Top-left light reflection
  static const Color darkShadow = Color(0xFF060911);    // Bottom-right shadow
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkAccent = Color(0xFF38BDF8);    // Electric cyan/sky
  static const Color darkAccentAlt = Color(0xFF10B981); // Emerald
  static const Color darkAccentAmber = Color(0xFFF59E0B);

  // Light Neumorphism: Ceramic Soft Slate & Pure White
  static const Color lightCanvas = Color(0xFFE8EEF5);
  static const Color lightSurface = Color(0xFFE8EEF5);
  static const Color lightHighlight = Color(0xFFFFFFFF); // Top-left crisp white reflection
  static const Color lightShadow = Color(0xFFB8C5D6);    // Bottom-right soft drop shadow
  static const Color lightTextPrimary = Color(0xFF061E18);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightAccent = Color(0xFF0F766E);    // Deep Teal
  static const Color lightAccentAlt = Color(0xFF059669); // Emerald
  static const Color lightAccentAmber = Color(0xFFD97706);

  // ─── Neumorphic BoxDecorations ──────────────────────────────
  static BoxDecoration neuRaised({
    required bool isDark,
    double radius = 20,
    Color? customSurface,
    double depth = 6,
    double blur = 14,
    Border? border,
  }) {
    final surface = customSurface ?? (isDark ? darkSurface : lightSurface);
    final shadowColor = isDark ? darkShadow.withOpacity(0.85) : lightShadow.withOpacity(0.9);
    final highlightColor = isDark ? darkHighlight.withOpacity(0.55) : lightHighlight.withOpacity(0.95);

    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.6),
        width: 1,
      ),
      boxShadow: [
        // Bottom-Right Dark Shadow
        BoxShadow(
          color: shadowColor,
          offset: Offset(depth, depth),
          blurRadius: blur,
          spreadRadius: 0,
        ),
        // Top-Left Light Highlight
        BoxShadow(
          color: highlightColor,
          offset: Offset(-depth * 0.8, -depth * 0.8),
          blurRadius: blur * 0.9,
          spreadRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration neuInset({
    required bool isDark,
    double radius = 16,
    Color? customSurface,
  }) {
    final surface = customSurface ?? (isDark ? const Color(0xFF0B101D) : const Color(0xFFDFE6F0));
    final borderColor = isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFCBD5E1);

    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.4) : const Color(0xFFB0BDCF).withOpacity(0.5),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ],
    );
  }

  static BoxDecoration neuButton({
    required bool isDark,
    double radius = 16,
    Color? accentColor,
    bool isPressed = false,
  }) {
    if (accentColor != null) {
      return BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.35 : 0.25),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      );
    }

    return neuRaised(
      isDark: isDark,
      radius: radius,
      depth: isPressed ? 2 : 5,
      blur: isPressed ? 6 : 12,
    );
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dhatu_dark_mode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dhatu_dark_mode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // ─── ThemeData Definitions ─────────────────────────────────
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkCanvas,
      cardColor: darkSurface,
      primaryColor: darkAccent,
      colorScheme: const ColorScheme.dark(
        primary: darkAccent,
        secondary: darkAccentAlt,
        surface: darkSurface,
        background: darkCanvas,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCanvas,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      fontFamily: 'Roboto',
    );
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightCanvas,
      cardColor: lightSurface,
      primaryColor: lightAccent,
      colorScheme: const ColorScheme.light(
        primary: lightAccent,
        secondary: lightAccentAlt,
        surface: lightSurface,
        background: lightCanvas,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCanvas,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      fontFamily: 'Roboto',
    );
  }
}
