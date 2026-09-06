import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeStyleMode { neomorphism, glassmorphism }

class ThemeManager extends ChangeNotifier {
  static const String _modeKey = 'theme_style_mode';
  static const String _colorKey = 'theme_primary_color';
  static const String _isDarkKey = 'theme_is_dark';

  ThemeStyleMode _styleMode = ThemeStyleMode.neomorphism;
  Color _primaryColor = const Color(0xFF4CAF50); // Default Green
  bool _isDarkMode = false;

  ThemeStyleMode get styleMode => _styleMode;
  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;

  ThemeManager() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load style mode
    final modeIndex = prefs.getInt(_modeKey);
    if (modeIndex != null) {
      _styleMode = ThemeStyleMode.values[modeIndex];
    }
    
    // Load color
    final colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    
    // Load dark mode
    _isDarkMode = prefs.getBool(_isDarkKey) ?? false;
    
    notifyListeners();
  }

  Future<void> setStyleMode(ThemeStyleMode mode) async {
    _styleMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
  }
  
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkKey, _isDarkMode);
  }

  // --- Dynamic Color Generation & Contrast Checking ---
  
  Color get backgroundColor {
    if (_styleMode == ThemeStyleMode.neomorphism) {
      return _isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E5EC);
    } else {
      // Glassmorphism needs a background to float over.
      // We will provide a base color, but typically the app will have a gradient or image background.
      return _isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF0F4F8);
    }
  }

  Color get textColor {
    return _isDarkMode ? Colors.white : Colors.black87;
  }
  
  Color get subtitleColor {
     return _isDarkMode ? Colors.white70 : Colors.black54;
  }

  // Ensure WCAG-AA contrast for text on primary color
  Color get onPrimaryColor {
    // Simple luminance check (could be expanded for strict WCAG formula)
    return _primaryColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  // Neumorphic specific colors
  Color get shadowLight {
    return _isDarkMode ? const Color(0xFF383838) : Colors.white;
  }

  Color get shadowDark {
    return _isDarkMode ? const Color(0xFF202020) : const Color(0xFFA3B1C6);
  }
}
